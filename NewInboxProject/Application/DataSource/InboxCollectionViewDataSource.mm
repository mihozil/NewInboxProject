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
#import "InboxCollectionViewCellModel.h"
#import "InboxDataSourceChangeSet.h"
#import "InboxCollectionViewUpdater.h"
#import "InboxSectionHeaderView.h"
#import "AAPLDataSource+Headers.h"

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
        _queueDataSourceState = state;
        
        [TSHelper dispatchOnMainQueue:^{
            if (progress.cancelled)
                return; // not yet determine; many completely remove progress
            [self loadContentCompleteWithState:state error:error];
        }];
    };
    
    [_itemsLoader loadContentWithCompletionHandle:loadCompletion];
}

- (void)loadContentCompleteWithState:(InboxDataSourceState*)state error:(NSError*)error {
    self.loadingError = error;
    
    if (error) {
        self.loadingState = AAPLLoadStateError;
        return;
    }
    
    // what about diff?
    if (!state || state.sectionsDic.count==0) {
        // update _queueState
        self.loadingState = AAPLLoadStateNoContent;
        return;
    }
    
    self.loadingState = AAPLLoadStateContentLoaded;
    [self applyDataSourceStateLoaded:state];
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

- (void)didEnterNoContentState {
    id<InboxCollectionViewDataSourceDelegate> delegate = self.inboxDelegate;
    if ([delegate respondsToSelector:@selector(dataSourceDidEnterNoContentState:)]) {
        [delegate dataSourceDidEnterNoContentState:self];
    }
}

- (void)didExitNoContentState {
    id<InboxCollectionViewDataSourceDelegate> delegate = self.inboxDelegate;
    if ([delegate respondsToSelector:@selector(dataSourceDidExitNoContentState:)]) {
        [delegate dataSourceDidExitNoContentState:self];
    }
}

- (void)didEnterErrorState {
    id<InboxCollectionViewDataSourceDelegate> delegate = self.inboxDelegate;
    if ([delegate respondsToSelector:@selector(dataSourceDidEnterErrorState:)]) {
        [delegate dataSourceDidEnterErrorState:self];
    }
}

- (void)didExitErrorState {
    id<InboxCollectionViewDataSourceDelegate> delegate = self.inboxDelegate;
    if ([delegate respondsToSelector:@selector(dataSourceDidExitErrorState:)]) {
        [delegate dataSourceDidExitErrorState:self];
    }
}

#pragma mark dataSource

- (NSInteger)numberOfSections {
    return self.dataSourceState.sections.count;
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

#pragma mark update

- (void)updateDatasourceStateAnimation:(BOOL)animation {
    __block InboxDataSourceState *updateState = _queueDataSourceState; // no need copy here. because when update or anything, _queueDataSourceState will be created again. updateState remain this state
    [TSHelper dispatchOnMainQueue:^{
        if (animation) {
            [self performUpdate:^{
                self.dataSourceDiff = [[InboxDataSourceItemsDiff alloc]initWithOldState:self.dataSourceState newState:updateState];
                self.dataSourceState = updateState;
                [self.dataSourceDiff implementAnimationCollectionView:self.collectionView];
            }];
        } else {
            [InboxCollectionViewUpdater forceReloadCollectionView:self.collectionView withUpdate:^{
                self.dataSourceState = updateState;
                [self.collectionView reloadData];
            } completion:nil];
        }
    }]; // call animation directly from here
}

- (void)performUpdate:(dispatch_block_t)update {
    [InboxCollectionViewUpdater performBatchUpdateCollectionView:self.collectionView withUpdate:update completion:nil];
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
        id item = [_queueDataSourceState objectAtIndexPath:indexPath];
        if ([item isKindOfClass:[InboxDataSourceItem class]]) {
            InboxDataSourceItem *newItem = [(InboxDataSourceItem*)item copy];
            InboxCollectionViewCellModel *cellItem = (InboxCollectionViewCellModel*)newItem.model;
            
            
            if ([cellItem isKindOfClass:[InboxCollectionViewCellModel class]]) {
                cellItem.selectingInEditingState = !cellItem.selectingInEditingState;
                
                NSDictionary *updates = @{indexPath:newItem};
                InboxDataSourceChangeSet *changeSet = [[InboxDataSourceChangeSet alloc]initWithUpdates:updates removes:nil inserts:nil];
                [self applyChangeSet:changeSet];
            }
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
                if ([item isKindOfClass:[InboxCollectionViewCellModel class]]) {
                    InboxCollectionViewCellModel *collectionViewCellItem = item;
                    if (collectionViewCellItem.selectingInEditingState) {
                        
                        NSIndexPath *indexPath = [_queueDataSourceState indexPathForItem:item inSection:section];
                        if (indexPath) {
                            InboxCollectionViewCellModel *updateItem = [collectionViewCellItem copy];
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
    NSMutableDictionary *newSectionsDic = [NSMutableDictionary new];
    NSMutableArray *newSections = [NSMutableArray new];
    NSArray *keys = @[InboxSectionChat, InboxSectionAddFriend];
    for (NSString *key in keys) {
        if ([_queueDataSourceState.sectionsDic objectForKey:key]) {
            NSMutableArray *section = [[_queueDataSourceState.sectionsDic objectForKey:key]mutableCopy];
            [newSectionsDic setObject:section forKey:key];
            [newSections addObject:section];
        }
    }
    
    for (NSIndexPath *indexPath in changeSet.updates.allKeys) {
        NSMutableArray *section = [newSections objectAtIndex:indexPath.section];
        //        NSLog(@"minhnht: indexPath - selecting: %ld %ld",indexPath.item,[[(InboxDataSourceItem*)[changeSet.updates objectForKey:indexPath] item]selectingInEditingState]);
        [section replaceObjectAtIndex:indexPath.item withObject:[changeSet.updates objectForKey:indexPath]];
    }
    
    for (NSIndexPath *indexPath in changeSet.orderedInsertKeys) {
        NSMutableArray *section = [newSections objectAtIndex:indexPath.section];
        [section insertObject:[changeSet.inserts objectForKey:indexPath]  atIndex:indexPath.item];
    }
    
    for (NSIndexPath *indexPath in changeSet.removes) {
        NSMutableArray *section = [newSections objectAtIndex:indexPath.section];
        [section removeObjectAtIndex:indexPath.item];
    }
    
    for (NSString *sectionKey in changeSet.orderedSectionKeys) {
        [newSectionsDic setObject:[changeSet.insertSections objectForKey:sectionKey] forKey:sectionKey];
    }
    
    [self recheckSectionDic:newSectionsDic];
    [self recheckUpdateHeaderWithSectionDic:newSectionsDic];
    _queueDataSourceState = [[InboxDataSourceState alloc]initWithSectionsDic:newSectionsDic];
    [self updateDatasourceStateAnimation:YES]; // completion: update no content 
}

/* in case empty section -> remove section
 ig will handle diff for animation */
- (void)recheckSectionDic:(NSMutableDictionary*)sectionDic {
    NSArray *keys = [sectionDic.allKeys copy];
    for (NSString *key in keys) {
        NSArray *section = [sectionDic objectForKey:key];
        if (section.count==0) {
            [sectionDic removeObjectForKey:key];
        }
    }
}

- (void)recheckUpdateHeaderWithSectionDic:(NSDictionary*)sectionDic {
    [self removeAllHeaders];
    if ([sectionDic objectForKey:InboxSectionAddFriend]) { // sectionIndex of inboxSectionAddFriend
        [self createNewHeaderForKey:@(sectionDic.count-1) withTitle:@"Add Friends"];
    }
}
/*
 this separated from applyChangeSet: apply changeSet for the clear animation: delete; insert; update ...
 */
- (void)applyDataSourceStateLoaded:(InboxDataSourceState*)newState {
    
    [self recheckUpdateHeaderWithSectionDic:newState.sectionsDic];
    _queueDataSourceState = newState;
    [self updateDatasourceStateAnimation:YES];
    
}

@end

