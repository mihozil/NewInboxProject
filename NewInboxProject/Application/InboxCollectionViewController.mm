//
//  InboxCollectionViewController.m
//  NewInboxProject
//
//  Created by CPU11806 on 5/25/18.
//  Copyright © 2018 CPU11806. All rights reserved.
//

#import "InboxCollectionViewController.h"
#import "InboxCollectionViewDataSource.h"
#import "InboxDataSourceItem.h"
#import "InboxCollectionViewUpdater.h"
#import "InboxDataSourceItemsDiff.h"
#import "InboxLoadingView.h"

@interface InboxCollectionViewController () <UICollectionViewDelegateFlowLayout,InboxCollectionViewDataSourceDelegate>

@property (strong, nonatomic) InboxCollectionViewDataSource *dataSource;

@end

@implementation InboxCollectionViewController {
    InboxLoadingView *_loadingView;
}

#pragma mark life-Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = [self newCollectionViewDataSource];
    self.collectionView.dataSource = self.dataSource;
    self.collectionView.backgroundColor = [UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:234.0/255.0 alpha:1.0];
}

- (void)viewDidAppear:(BOOL)animated {
    
}

#pragma mark property

- (InboxCollectionViewDataSource*) newCollectionViewDataSource {
    InboxCollectionViewDataSource *dataSource = [[InboxCollectionViewDataSource alloc]init];
    dataSource.collectionView = self.collectionView;
    dataSource.inboxDelegate = self;
    dataSource.title = @"InboxViewController";
    dataSource.noContentPlaceholder = [AAPLDataSourcePlaceholder placeholderWithTitle:@"No content" message:@"Please try again later" image:nil];
    dataSource.errorPlaceholder = [AAPLDataSourcePlaceholder placeholderWithTitle:@"Error" message:@"There seems to be some sort of error" image:nil];
    
    dataSource.defaultMetrics.showsRowSeparator = YES;
    dataSource.defaultMetrics.separatorInsets = UIEdgeInsetsMake(0, 15, 0, 0);
    dataSource.defaultMetrics.estimatedRowHeight = 60;
    
    return dataSource;
}

#pragma mark collectionViewDelegate
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    InboxDataSourceItem *dataSourceItem = [self.dataSource.items objectAtIndex:indexPath.row];
//    InboxDataSourceItemLayout layout = dataSourceItem.layout;
//    return layout.frame.size;
//}

#pragma mark cellAction

- (void)performBatchUpdates:(void (^)())updates completion:(void (^)())completion {
    [InboxCollectionViewUpdater performBatchUpdateCollectionView:self.collectionView withUpdate:updates completion:completion];
}

- (void)swipeToDeleteCell:(__kindof UICollectionViewCell *)cell {
    // update gestureState <done>
    // update model <done>
    // update dataSourceState
    InboxCollectionViewDataSource *dataSource = self.dataSource;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    [dataSource removeItemAtIndexPath:indexPath];
}

#pragma mark swipeEditDelegate
- (void)swipeToEditController:(AAPLSwipeToEditController *)swipeToEditController didSelectCellAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"minhnht: didSelectCellAtIndexPath: %ld",indexPath.item);
    [self.dataSource didSelectIndexPathInSwipeEditingState:indexPath];
}

- (void)didTapDeleteBarButton {
    [super didTapDeleteBarButton];
    [self.dataSource deleteSelectingIndexPathsInSwipeEditingState];
}

- (void)didTapDoneBarButton {
    [super didTapDoneBarButton];
    [self.dataSource resetSelectingIndexPathsInSwipeEditingState];
}

#pragma mark state
- (void)dataSourceDidEnterLoadingState:(InboxCollectionViewDataSource *)dataSource {
    _loadingView = [[InboxLoadingView alloc]initWithFrame:self.collectionView.frame];
    [self.view addSubview:_loadingView];
}

- (void)dataSourceDidExitLoadingState:(InboxCollectionViewDataSource *)dataSource {
    [_loadingView removeFromSuperview];
    _loadingView = nil;
}


@end
