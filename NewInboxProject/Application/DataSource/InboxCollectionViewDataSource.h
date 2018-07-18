//
//  InboxCollectionViewDataSource.h
//  NewInboxProject
//
//  Created by CPU11806 on 5/25/18.
//  Copyright © 2018 CPU11806. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AAPLDataSource.h"
@class InboxDataSourceState;
@class InboxDataSourceItemsDiff;
@class InboxCollectionViewDataSource;

@protocol InboxCollectionViewDataSourceDelegate <NSObject>

@optional
- (void)dataSourceDidEnterLoadingState:(InboxCollectionViewDataSource*)dataSource;
- (void)dataSourceDidExitLoadingState:(InboxCollectionViewDataSource*)dataSource;
- (void)dataSourceDidEnterNoContentState:(InboxCollectionViewDataSource*)dataSource;
- (void)dataSourceDidExitNoContentState:(InboxCollectionViewDataSource*)dataSource;
- (void)dataSourceDidEnterErrorState:(InboxCollectionViewDataSource*)dataSource;
- (void)dataSourceDidExitErrorState:(InboxCollectionViewDataSource*)dataSource;
@end

@interface InboxCollectionViewDataSource : AAPLDataSource

@property (weak, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) InboxDataSourceState *dataSourceState;
@property (strong, nonatomic) InboxDataSourceItemsDiff *dataSourceDiff;
@property (weak, nonatomic) id<InboxCollectionViewDataSourceDelegate> inboxDelegate;

#pragma update
- (void)didSelectIndexPathInSwipeEditingState:(NSIndexPath*)indexPath;
- (void)deleteSelectingIndexPathsInSwipeEditingState;
- (void)resetSelectingIndexPathsInSwipeEditingState;

@end
