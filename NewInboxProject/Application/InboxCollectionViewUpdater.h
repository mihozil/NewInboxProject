//
//  InboxCollectionViewUpdater.h
//  NewInboxProject
//
//  Created by CPU11806 on 5/30/18.
//  Copyright © 2018 CPU11806. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class InboxDataSourceItemsDiff;

/*
 the class implement the data and uiUpdate of collectionView:
 updateBlock: update data and update UI
 completionBlock: completion
 */
@interface InboxCollectionViewUpdater : NSObject

+ (void)forceReloadCollectionView:(UICollectionView*)collectionView withUpdate:(dispatch_block_t)update completion:(dispatch_block_t)completion;
+ (void)performBatchUpdateCollectionView:(UICollectionView*)collectionView withUpdate:(dispatch_block_t)update completion:(dispatch_block_t) completion;

@end
