//
//  InboxCollectionViewDataSource.m
//  NewInboxProject
//
//  Created by CPU11806 on 5/25/18.
//  Copyright © 2018 CPU11806. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InboxCollectionViewDataSource.h"
#import "InboxCollectionViewCell.h"
#import "InboxDataSourceItem.h"
#import "InboxDataLoader.h"
#import "AAPLAction.h"
#import "InboxCollectionViewController.h"
#import "TSHelper.h"
#import "InboxDataSourceItemsDiff.h"
#import "InboxDataSourceState.h"

@interface InboxCollectionViewDataSource()

@property (strong, nonatomic) InboxDataSourceState *queueDataSourceState;

@end

@implementation InboxCollectionViewDataSource {
    dispatch_queue_t _actionQueue;
    const char *_actionQueueName;
    InboxDataLoader *_itemsLoader;
}

#pragma mark lifeCycle
- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *actionQueueNameString = [TSHelper createDispatchQueueName:self];
        _actionQueueName = [actionQueueNameString UTF8String];
        _actionQueue = [TSHelper createDispatchQueue:self withName:_actionQueueName isSerial:YES];
        
        _queueDataSourceState = [[InboxDataSourceState alloc]init];
        _itemsLoader = [[InboxDataLoader alloc]initWithQueueState:_queueDataSourceState actionQueue:_actionQueue actionQueueName:_actionQueueName];
    }
    return self;
}

#pragma mark subClass
- (void)registerReusableViewsWithCollectionView:(UICollectionView *)collectionView {
    [super registerReusableViewsWithCollectionView:collectionView];
    [collectionView registerClass:[InboxCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([InboxCollectionViewCell class])];
}

- (void)loadContentWithProgress:(AAPLLoadingProgress *)progress {
    loadContentCompletion loadCompletion = ^(InboxDataSourceState* state, NSError* error) { // state here copy already
        
        [TSHelper dispatchOnMainQueue:^{
            if (progress.cancelled)
                return;
            
            if (error) {
                [progress doneWithError:error]; // this case check later: if there are being items and than loadError
                // placeholder: stateMachine -> didEnterState -> performInternalUpdate.. -> performBatchUpdate
                return;
            }
            
            // temporary put dataSourceDiff here
            if (!state || state.sections.count==0) {
                [progress updateWithNoContent:^(InboxCollectionViewDataSource *me) {
                    self.dataSourceDiff = [[InboxDataSourceItemsDiff alloc]initWithOldState:self.dataSourceState newState:state];
                    me.dataSourceState = state;
                    [self.dataSourceDiff implementAnimationCollectionView:self.collectionView];
                    // this is temporary. should only be diff for load content <kind of like that>
                }];
                return;
            }
    
            [progress updateWithContent:^(InboxCollectionViewDataSource *me){
                self.dataSourceDiff = [[InboxDataSourceItemsDiff alloc]initWithOldState:self.dataSourceState newState:state];
                me.dataSourceState = state;
                [self.dataSourceDiff implementAnimationCollectionView:self.collectionView];
                
            }];
        }];
    };
    
    [_itemsLoader loadContentWithCompletionHandle:loadCompletion];
}


#pragma mark subClass-state
- (void)didEnterLoadingState {
    id<InboxCollectionViewDataSourceDelegate> delegate = self.inboxDelegate;
    if ([delegate respondsToSelector:@selector(dataSourceDidEnterLoadingState:)]) {
        [delegate dataSourceDidEnterLoadingState:self];
    }
}

- (void)didExitLoadingState {
    id<InboxCollectionViewDataSourceDelegate> delegate = self.inboxDelegate;
    if ([delegate respondsToSelector:@selector(dataSourceDidExitLoadingState:)]) {
        [delegate dataSourceDidExitLoadingState:self];
    }
}

#pragma mark dataSource

- (NSInteger)numberOfSections {
    return self.dataSourceState.sections.count;
}

- (NSInteger)numberOfItemsInSection:(NSInteger)sectionIndex {
    NSArray *section = [self.dataSourceState.sections.allValues objectAtIndex:sectionIndex];
    return [section count];
}

- (BOOL)collectionView:(UICollectionView *)collectionView canEditItemAtIndexPath:(NSIndexPath *)indexPath {
    return true;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    InboxCollectionViewCell *cell = (InboxCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([InboxCollectionViewCell class]) forIndexPath:indexPath];
    InboxDataSourceItem *dataSourceItem = (InboxDataSourceItem*)[self.dataSourceState objectAtIndexPath:indexPath];
    
    [cell setObject:dataSourceItem];
    
    return cell;
}

- (NSArray<AAPLAction *> *)primaryActionsForItemAtIndexPath:(NSIndexPath *)indexPath {
    return @[
             [AAPLAction destructiveActionWithTitle:NSLocalizedString(@"Delete", @"Delete") selector:@selector(swipeToDeleteCell:)],
             [AAPLAction actionWithTitle:NSLocalizedString(@"Tickle", @"Tickle") selector:@selector(tickleCell:)],
             [AAPLAction actionWithTitle:NSLocalizedString(@"Confuse", @"Confuse") selector:@selector(tickleCell:)],
             [AAPLAction actionWithTitle:NSLocalizedString(@"Feed", @"Feed") selector:@selector(tickleCell:)]
             ];
}

#pragma mark actions

- (void)tickleCell:(id)sender {
    
}

#pragma mark update

- (void)updateDatasourceState {
    __block InboxDataSourceState *updateState = [_queueDataSourceState copy];
    [TSHelper dispatchOnMainQueue:^{
        [self performUpdate:^{
            self.dataSourceDiff = [[InboxDataSourceItemsDiff alloc]initWithOldState:self.dataSourceState newState:updateState];
            self.dataSourceState = updateState;
            [self.dataSourceDiff implementAnimationCollectionView:self.collectionView];
        }];
    }];
}

- (void)removeItemAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(&*self) weakself = self;
    dispatch_block_t block = ^{
        [weakself.queueDataSourceState removeItemAtIndexPath:indexPath];
        [weakself updateDatasourceState];
    };
    [TSHelper dispatchOnQueue:_actionQueue withName:_actionQueueName withTask:block];
}



@end
