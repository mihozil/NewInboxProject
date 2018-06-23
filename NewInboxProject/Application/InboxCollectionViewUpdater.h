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

@interface InboxCollectionViewUpdater : NSObject

+ (void)performBatchUpdateCollectionView:(UICollectionView*)collectionView withUpdate:(dispatch_block_t)update completion:(dispatch_block_t) completion;

@end
