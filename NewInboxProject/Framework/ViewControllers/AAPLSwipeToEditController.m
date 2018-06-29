/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A state machine that manages a UILongPressGestureRecognizer and a UIPanGestureRecognizer to handle swipe to edit as well as drag to reorder.
 */

#define DEBUG_SWIPE_TO_EDIT 0

#if DEBUG_SWIPE_TO_EDIT
#define SWIPE_LOG(FORMAT, ...) NSLog(@"»%@ " FORMAT, NSStringFromSelector(_cmd), __VA_ARGS__)
#else
#define SWIPE_LOG(FORMAT, ...)
#endif

#import "AAPLSwipeToEditController.h"
#import "AAPLCollectionViewCell_Private.h"
#import "AAPLCollectionViewLayout_Private.h"
#import "AAPLDataSource.h"
#import "AAPLStateMachine.h"
#import <libkern/OSAtomic.h>
#import <objc/message.h>

@interface AAPLGestureRecognizerWrapper : NSObject <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIGestureRecognizer *gestureRecognizer;
@property (nonatomic, weak) id<UIGestureRecognizerDelegate> target;
@property (nonatomic) SEL action;
@property (nonatomic) SEL shouldBegin;

+ (instancetype)wrapperWithGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer target:(id<UIGestureRecognizerDelegate>)target;

@end;

@implementation AAPLGestureRecognizerWrapper

+ (instancetype)wrapperWithGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer target:(id<UIGestureRecognizerDelegate>)target
{
    return [[self alloc] initWithGestureRecognizer:gestureRecognizer target:target action:NULL shouldBegin:NULL];
}

- (instancetype)initWithGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer target:(id<UIGestureRecognizerDelegate>)target action:(SEL)action shouldBegin:(SEL)shouldBegin
{
    NSParameterAssert(gestureRecognizer != nil);
    NSParameterAssert(target != nil);

    self = [super init];
    if (!self)
        return nil;

    _gestureRecognizer = gestureRecognizer;
    _target = target;
    _action = action;
    _shouldBegin = shouldBegin;

    gestureRecognizer.delegate = self;
    [gestureRecognizer addTarget:self action:@selector(handleAction:)];

    return self;
}

- (void)dealloc
{
    _gestureRecognizer.delegate = nil;
}

- (void)handleAction:(UIGestureRecognizer *)gestureRecognizer
{
    SEL action = self.action;
    if (!action)
        return;

    typedef BOOL (*ObjCMsgSendReturnBoolWithId)(id, SEL, id);
    ObjCMsgSendReturnBoolWithId doAction = (ObjCMsgSendReturnBoolWithId)objc_msgSend;

    doAction(self.target, action, gestureRecognizer);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    BOOL shouldRecognize = [self.target gestureRecognizer:gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer];
    
    return shouldRecognize;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (!self.shouldBegin)
        return NO;

    typedef BOOL (*ObjCMsgSendReturnBoolWithId)(id, SEL, id);
    ObjCMsgSendReturnBoolWithId shouldBegin = (ObjCMsgSendReturnBoolWithId)objc_msgSend;
    BOOL shouldBeginGesture = shouldBegin(self.target, self.shouldBegin, gestureRecognizer);
    NSLog(@"shouldBeginGesture: %ld",shouldBeginGesture);
    return shouldBeginGesture;
}

@end


NSString * const AAPLSwipeStateIdle = @"IdleState";
NSString * const AAPLSwipeStateEditing = @"EditingState";
NSString * const AAPLSwipeStateTracking = @"TrackingState";
NSString * const AAPLSwipeStateOpen = @"OpenState";


@interface AAPLSwipeToEditController () <AAPLStateMachineDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, readonly) AAPLDataSource *dataSource;
@property (nonatomic, strong) AAPLCollectionViewCell *editingCell;
@property (nonatomic, strong) AAPLGestureRecognizerWrapper *longPressWrapper;
@property (nonatomic, strong) AAPLGestureRecognizerWrapper *panWrapper;
@property (nonatomic, strong) AAPLGestureRecognizerWrapper *tapWrapper;
@property (nonatomic, strong) AAPLStateMachine *stateMachine;
@property (nonatomic, copy) NSString *currentState;
@end

@implementation AAPLSwipeToEditController
@synthesize editing = _editing;

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView
{
    
    self = [super init];
    if (!self)
        return nil;

    _collectionView = collectionView;

    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:nil action:NULL];
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:nil action:NULL];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:nil action:NULL];

    _longPressWrapper = [AAPLGestureRecognizerWrapper wrapperWithGestureRecognizer:longPressGestureRecognizer target:self];
    _panWrapper = [AAPLGestureRecognizerWrapper wrapperWithGestureRecognizer:panGestureRecognizer target:self];
    _tapWrapper = [AAPLGestureRecognizerWrapper wrapperWithGestureRecognizer:tapGestureRecognizer target:self];

    for (UIGestureRecognizer *recognizer in _collectionView.gestureRecognizers) {
        if ([recognizer isKindOfClass:[UIPanGestureRecognizer class]])
            [recognizer requireGestureRecognizerToFail:panGestureRecognizer];
        if ([recognizer isKindOfClass:[UILongPressGestureRecognizer class]])
            [recognizer requireGestureRecognizerToFail:longPressGestureRecognizer];
        // tap Gesture?
    }

    [collectionView addGestureRecognizer:panGestureRecognizer];
    [collectionView addGestureRecognizer:longPressGestureRecognizer];
    [collectionView addGestureRecognizer:tapGestureRecognizer];

    _stateMachine = [[AAPLStateMachine alloc] init];
    _stateMachine.delegate = self;
    _stateMachine.validTransitions = @{
                                       AAPLSwipeStateIdle : @[AAPLSwipeStateTracking, AAPLSwipeStateEditing],
                                       AAPLSwipeStateEditing : @[AAPLSwipeStateIdle],
                                       AAPLSwipeStateTracking : @[AAPLSwipeStateIdle, AAPLSwipeStateOpen],
                                       AAPLSwipeStateOpen : @[AAPLSwipeStateTracking, AAPLSwipeStateIdle],
                                       };
    _stateMachine.currentState = AAPLSwipeStateIdle;

    return self;
}

- (instancetype)init
{
    [NSException raise:NSInvalidArgumentException format:@"Don't call %@.", @(__PRETTY_FUNCTION__)];
    return nil;
}

- (AAPLDataSource *)dataSource
{
    AAPLDataSource *dataSource = (AAPLDataSource *)self.collectionView.dataSource;
    if ([dataSource isKindOfClass:[AAPLDataSource class]])
        return dataSource;
    else
        return nil;
}

- (NSString *)currentState
{
    return _stateMachine.currentState;
}

- (void)setCurrentState:(NSString *)currentState
{
    SWIPE_LOG(@"%@", currentState);
    _stateMachine.currentState = currentState;
}

- (BOOL)isIdle
{
    return [_stateMachine.currentState isEqualToString:AAPLSwipeStateIdle];
}

- (void)setEditing:(BOOL)editing
{ 
    if (_editing == editing)
        return;
    
    _editing = editing;
    
    
    AAPLCollectionViewLayout *layout = (AAPLCollectionViewLayout *)self.collectionView.collectionViewLayout;
    
    NSAssert([layout isKindOfClass:[AAPLCollectionViewLayout class]], @"Editing only supported when using a layout derived from AAPLCollectionViewLayout");
    
    if ([layout isKindOfClass:[AAPLCollectionViewLayout class]])
        layout.editing = editing;
    
    [layout invalidateLayout];
    [self.delegate swipeToEditController:self didSetEditing:editing];
}

- (NSIndexPath *)trackedIndexPath
{
    return [_collectionView indexPathForCell:_editingCell];
}

//- (void)setDelegate:(id<AAPLStateMachineDelegate>)delegate
//{
//    NSAssert(NO, @"you're not the boss of me");
//}

- (void)setEditingCell:(AAPLCollectionViewCell *)editingCell
{
    if (_editingCell == editingCell)
        return;
    _editingCell = editingCell;
}

- (void)shutActionPaneForEditingCellAnimated:(BOOL)animate
{
    // This basically backs out of the Open or EditOpen states
    NSString *currentState = self.currentState;

    void (^shut)() = ^{
        if ([currentState isEqualToString:AAPLSwipeStateOpen])
            self.currentState = AAPLSwipeStateIdle;
    };

    if (!animate)
        [UIView performWithoutAnimation:shut];
    else
        shut();
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSString *currentState = self.currentState;

    if (![currentState isEqualToString:AAPLSwipeStateIdle])
        self.currentState = AAPLSwipeStateIdle;
}

#pragma mark - Gesture Recognizer action methods

- (void)handleSwipePan:(UIPanGestureRecognizer *)recognizer
{
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            CGPoint position = [recognizer locationInView:_editingCell];
            CGFloat velocityX = [recognizer velocityInView:_editingCell].x;
            [_editingCell beginSwipeWithPosition:position velocity:velocityX];
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            CGPoint position = [recognizer locationInView:_editingCell];
            CGFloat velocityX = [recognizer velocityInView:_editingCell].x;
            [_editingCell updateSwipeWithPosition:position velocity:velocityX];
            self.currentState = AAPLSwipeStateTracking;
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            CGPoint position = [recognizer locationInView:_editingCell];
            
            if ([self.editingCell endSwipeWithPosition:position])
                self.currentState = AAPLSwipeStateOpen;
            else
                self.currentState = AAPLSwipeStateIdle;
            break;
        }
        case UIGestureRecognizerStateCancelled:
        {
            self.currentState = AAPLSwipeStateIdle;
            break;
        }
        default:
            break;
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer*)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            CGPoint cellLocation = [recognizer locationInView:self.editingCell];
            if (CGRectContainsPoint(self.editingCell.bounds, cellLocation))
                break;
            
            self.currentState = AAPLSwipeStateEditing;
            // Cancel the recognizer by disabling & re-enabling it. This prevents it from firing an end state notification.
            recognizer.enabled = NO;
            recognizer.enabled = YES;
            
            self.editing = true;
            
            break;
            
        }
            
        case UIGestureRecognizerStateCancelled:
            self.currentState = AAPLSwipeStateEditing;
            break;
            
        case UIGestureRecognizerStateEnded:
            self.currentState = AAPLSwipeStateEditing;
            break;
            
        default:
            break;
    }
}

- (void)handleTapOpenState:(UITapGestureRecognizer*)recognizer {
    self.currentState = AAPLSwipeStateIdle;
    // do any thing at didEnter .. didExit
}

- (void)handleTapEditingState:(UITapGestureRecognizer*)recognizer {
    
}

#pragma mark - State Transition methods

- (void)didExitTrackingState
{
    self.panWrapper.shouldBegin = NULL;
    self.panWrapper.action = NULL;
}

- (void)didEnterTrackingState
{
    // Toggle the long press gesture recogniser to ensure we don't get an accidental trigger if tracking doesn't last long enough.
    self.tapWrapper.shouldBegin = NULL;
    self.longPressWrapper.shouldBegin = NULL;

    self.panWrapper.action = @selector(handleSwipePan:);
}

- (void)didExitOpenState
{
    self.longPressWrapper.action = NULL;
    self.longPressWrapper.shouldBegin = NULL;

    self.panWrapper.shouldBegin = NULL;
    self.panWrapper.action = NULL;
}

- (void)didEnterOpenState
{
    self.longPressWrapper.shouldBegin = NULL;

    self.panWrapper.shouldBegin = @selector(panGestureRecognizerShouldBeginWhileOpen:);
    self.panWrapper.action = @selector(handleSwipePan:);
    
    self.tapWrapper.shouldBegin = @selector(tapGestureRecognizerShouldWhileOpen:);
    self.tapWrapper.action = @selector(handleTapOpenState:);

    _collectionView.scrollEnabled = NO;

    [self.editingCell openActionPaneAnimated:YES completionHandler:nil];
    // minhnht note: editingCell = nil?
}


- (void)didExitIdleState
{
    self.panWrapper.shouldBegin = NULL;
    self.panWrapper.action = NULL;
}

- (void)didEnterIdleState
{
    self.tapWrapper.shouldBegin = NULL;
    
    self.panWrapper.shouldBegin = @selector(panGestureRecognizerShouldBeginWhileIdle:);
    self.panWrapper.action = @selector(handleSwipePan:);
    
    self.longPressWrapper.shouldBegin = @selector(longGestureRecognizerShouldBeginWhileIdle:);
    self.longPressWrapper.action = @selector(handleLongPress:);

    _collectionView.scrollEnabled = YES;

    AAPLCollectionViewCell *cell = self.editingCell;
    self.editingCell = nil;

    [cell closeActionPaneAnimated:YES completionHandler:nil];
}

- (void)didExitEditingState {
    
}

- (void)didEnterEditingState {
    
    self.panWrapper.shouldBegin = NULL;
    self.tapWrapper.shouldBegin = @selector(tapGestureShouldBeginWhileEditing:);
    self.tapWrapper.action = @selector(handleTapEditingState:);
    
}


#pragma mark - UIGestureRecognizerDelegate
- (BOOL)panGestureRecognizerShouldBeginWhileIdle:(UIGestureRecognizer*)gestureRecognizer {
    
    UIPanGestureRecognizer *panGestureRecognizer = (UIPanGestureRecognizer *)gestureRecognizer;
    
    // only if it's a AAPLCollectionViewCell
    CGPoint position = [panGestureRecognizer locationInView:_collectionView];
    NSIndexPath *panCellPath = [_collectionView indexPathForItemAtPoint:position];
    CGPoint velocity = [panGestureRecognizer velocityInView:_collectionView];
    AAPLCollectionViewCell *cell = (AAPLCollectionViewCell *)[_collectionView cellForItemAtIndexPath:panCellPath];
    
    SWIPE_LOG(@"cell=%@", cell);
    
    if (![cell isKindOfClass:[AAPLCollectionViewCell class]])
        return NO;
    
    SWIPE_LOG(@"indexPath=%@ velocity=%@ cell=%@ editingCell=%@", panCellPath, NSStringFromCGPoint(velocity), cell, _editingCell);
    
    // only if there's enough x velocity
    if (fabs(velocity.y) >= fabs(velocity.x))
        return NO;
    
    NSArray *editActions;
    
    if (velocity.x < 0)
        editActions = [self.dataSource primaryActionsForItemAtIndexPath:panCellPath];
    else
        editActions = [self.dataSource secondaryActionsForItemAtIndexPath:panCellPath];
    
    SWIPE_LOG(@"edit actions = %@", editActions);
    
    if (!editActions.count)
        return NO;
    
    cell.editActions = editActions;
    cell.swipeType = (velocity.x < 0 ? AAPLCollectionViewCellSwipeTypePrimary : AAPLCollectionViewCellSwipeTypeSecondary);
    
    self.editingCell = cell;
    self.currentState = AAPLSwipeStateTracking;
    return YES;
}

- (BOOL)panGestureRecognizerShouldBeginWhileOpen:(UIGestureRecognizer*)gestureRecognizer {
    CGPoint position = [gestureRecognizer locationInView:_collectionView];
    NSIndexPath *panCellPath = [_collectionView indexPathForItemAtPoint:position];
    AAPLCollectionViewCell *cell = (AAPLCollectionViewCell *)[_collectionView cellForItemAtIndexPath:panCellPath];
    
    if (![cell isKindOfClass:[AAPLCollectionViewCell class]])
        return NO;
    // if (true -> updateStateMachine)
    
    return (cell == _editingCell);
}

- (BOOL)longGestureRecognizerShouldBeginWhileIdle:(UIGestureRecognizer*)gestureRecognizer {
    NSUInteger numberOfTouches = gestureRecognizer.numberOfTouches;
    for (NSUInteger touchIndex = 0; touchIndex < numberOfTouches; ++touchIndex) {
        CGPoint touchLocation = [gestureRecognizer locationOfTouch:touchIndex inView:_collectionView];
        NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:touchLocation];
        AAPLCollectionViewCell *cell = (AAPLCollectionViewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
        if (![cell isKindOfClass:[AAPLCollectionViewCell class]])
            return NO;
    }
    // updateStateMachine:
    
    return YES;
    
}

- (BOOL)tapGestureRecognizerShouldWhileOpen:(UIGestureRecognizer*)gestureRecognizer {
    
    NSUInteger numberOfTouches = gestureRecognizer.numberOfTouches;
    CGRect actionsViewRect = _editingCell.actionsViewRect;
    
    for (NSUInteger touchIndex = 0; touchIndex < numberOfTouches; ++touchIndex) {
        CGPoint touchLocation = [gestureRecognizer locationOfTouch:touchIndex inView:_editingCell];
        if (CGRectContainsPoint(actionsViewRect, touchLocation))
            return NO;
    }
    // update stateMachine:
    
    return YES;
}

- (BOOL)tapGestureShouldBeginWhileEditing:(UIGestureRecognizer*)gestureRecognizer {
    return false;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    SWIPE_LOG(@"gestureRecognizer:%@ otherRecognizer:%@", gestureRecognizer, otherGestureRecognizer);
    // with long: yes
    if (gestureRecognizer == self.longPressWrapper.gestureRecognizer || otherGestureRecognizer == self.longPressWrapper.gestureRecognizer)
        return true;
    
    return NO;
}

@end
