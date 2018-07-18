//
//  InboxCollectionViewUpdater.m
//  NewInboxProject
//
//  Created by CPU11806 on 5/30/18.
//  Copyright © 2018 CPU11806. All rights reserved.
//

#import "InboxCollectionViewUpdater.h"

static BOOL _performingAnimation;
static dispatch_block_t _completionHandle;
@implementation InboxCollectionViewUpdater

+ (void)forceReloadCollectionView:(UICollectionView*)collectionView withUpdate:(dispatch_block_t)update completion:(dispatch_block_t)completion {
    
    dispatch_block_t enqueueCompletion = ^{
        if (completion) {
            dispatch_block_t oldCompletion = _completionHandle;
            _completionHandle = ^{
                if (oldCompletion)
                    oldCompletion();
                completion();
            };
            
        }
    };
    
    if (update)
        update();
    [collectionView reloadData];
    enqueueCompletion();
}

/*
 only one animation at once. if other -> performWithoutAnimation & enqueueCompletion
 similar for reload
 */
+ (void)performBatchUpdateCollectionView:(UICollectionView*)collectionView withUpdate:(dispatch_block_t)update completion:(dispatch_block_t) completion {
    
    dispatch_block_t enqueueCompletion = ^{
        if (completion) {
            dispatch_block_t oldCompletion = _completionHandle;
            _completionHandle = ^{
                if (oldCompletion)
                    oldCompletion();    
                completion();
            };
        }
    };
    
    if (_performingAnimation) {
        enqueueCompletion();
        update(); // including perform - animation
        return;
    }
    
    [collectionView performBatchUpdates:^{
        enqueueCompletion();
        update();
        _performingAnimation = true;
    } completion:^(BOOL finished){
        if (_completionHandle)
            _completionHandle();
        _performingAnimation = false;
    }];
}

@end
