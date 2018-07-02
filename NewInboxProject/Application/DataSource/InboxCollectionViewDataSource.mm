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
#import "InboxCollectionViewCellItem.h"
#import "InboxDataSourceChangeSet.h"

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
        _itemsLoader = [[InboxDataLoader alloc]initWithActionQueue:_actionQueue actionQueueName:_actionQueueName];
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
            if (!state || state.sectionsDic.count==0) {
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
    return self.dataSourceState.sectionsDic.count;
}

- (NSInteger)numberOfItemsInSection:(NSInteger)sectionIndex {
    NSArray *section = [self.dataSourceState.sections objectAtIndex:sectionIndex];
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
             ]; // temp keep this flow
}

#pragma mark actions

- (void)tickleCell:(id)sender {
    
}

#pragma mark update

- (void)updateDatasourceState {
    __block InboxDataSourceState *updateState = [_queueDataSourceState copy]; // no need copy here. later
    [TSHelper dispatchOnMainQueue:^{
        [self performUpdate:^{
            self.dataSourceDiff = [[InboxDataSourceItemsDiff alloc]initWithOldState:self.dataSourceState newState:updateState];
            self.dataSourceState = updateState;
            [self.dataSourceDiff implementAnimationCollectionView:self.collectionView];
        }];
    }]; // call animation directly from here
}

// minhnht update

- (void)removeItemAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(&*self) weakself = self;
    dispatch_block_t block = ^{
        NSArray *removes = @[indexPath];
        InboxDataSourceChangeSet *changeSet = [[InboxDataSourceChangeSet alloc]initWithUpdates:nil removes:removes inserts:nil];
        [weakself applyChangeSet:changeSet];
    };
    [TSHelper dispatchOnQueue:_actionQueue withName:_actionQueueName withTask:block];
}

- (void)didSelectIndexPathInSwipeEditingState:(NSIndexPath *)indexPath {
    // update model <items>
    dispatch_block_t block = ^{
        id item = [[_queueDataSourceState objectAtIndexPath:indexPath] copy];
        if ([item isKindOfClass:[InboxCollectionViewCellItem class]]) {
            InboxCollectionViewCellItem *collectionViewCellItem = item;
            collectionViewCellItem.selectingInEditingState = !collectionViewCellItem.selectingInEditingState;
            NSLog(@"indexPath: %ld",indexPath.item);
            NSDictionary *updates = @{indexPath:item};
            InboxDataSourceChangeSet *changeSet = [[InboxDataSourceChangeSet alloc]initWithUpdates:updates removes:nil inserts:nil];
            [self applyChangeSet:changeSet];
        }
    };
    
    [TSHelper dispatchOnQueue:_actionQueue withName:_actionQueueName withTask:block];
}

- (void)deleteSelectingIndexPathsInSwipeEditingState {
    dispatch_block_t block = ^{
        NSArray *removes = [_queueDataSourceState selectingIndexPathInEditingState];
        InboxDataSourceChangeSet *changeSet = [[InboxDataSourceChangeSet alloc]initWithUpdates:nil removes:removes inserts:nil];
        [self applyChangeSet:changeSet];
    };
    [TSHelper dispatchOnQueue:_actionQueue withName:_actionQueueName withTask:block];
}

- (void)resetSelectingIndexPathsInSwipeEditingState {
    dispatch_block_t block = ^{
        NSMutableDictionary *updates = [NSMutableDictionary new];
        for (NSArray *section in _queueDataSourceState.sections) {
            for (id item in section) {
                if ([item isKindOfClass:[InboxCollectionViewCellItem class]]) {
                    InboxCollectionViewCellItem *collectionViewCellItem = item;
                    if (collectionViewCellItem.selectingInEditingState) {
                        
                        NSIndexPath *indexPath = [_queueDataSourceState indexPathForItem:item inSection:section];
                        if (indexPath) {
                            InboxCollectionViewCellItem *updateItem = [collectionViewCellItem copy];
                            updateItem.selectingInEditingState = false;
                            [updates setObject:updateItem forKey:indexPath];
                        }
                        
                    }
                }
            }
        }
        
        InboxDataSourceChangeSet *changeSet = [[InboxDataSourceChangeSet alloc]initWithUpdates:updates removes:nil inserts:nil];
        [self applyChangeSet:changeSet];
    };
    [TSHelper dispatchOnQueue:_actionQueue withName:_actionQueueName withTask:block];
}

- (void)applyChangeSet:(InboxDataSourceChangeSet*)changeSet {
    NSMutableDictionary *newSections = [NSMutableDictionary new];
    for (NSString *key in _queueDataSourceState.sectionsDic.allKeys) {
        NSMutableArray *section = [[_queueDataSourceState.sectionsDic objectForKey:key]mutableCopy];
        [newSections setObject:section forKey:key];
    }
    
    for (NSIndexPath *indexPath in changeSet.updates.allKeys) {
        NSMutableArray *section = [newSections.allValues objectAtIndex:indexPath.section];
        [section replaceObjectAtIndex:indexPath.item withObject:[changeSet.updates objectForKey:indexPath]];
    }
    
    for (NSIndexPath *indexPath in changeSet.orderedInsertsKey) {
        NSMutableArray *section = [newSections.allValues objectAtIndex:indexPath.section];
        [section insertObject:[changeSet.inserts objectForKey:indexPath]  atIndex:indexPath.item];
    }
    
    for (NSIndexPath *indexPath in changeSet.removes) {
        NSMutableArray *section = [newSections.allValues objectAtIndex:indexPath.section];
        [section removeObjectAtIndex:indexPath.item];
    }
    
//    for (NSArray *)
    
    _queueDataSourceState = [[InboxDataSourceState alloc]initWithSectionsDic:newSections];
    [self updateDatasourceState];
}

@end
