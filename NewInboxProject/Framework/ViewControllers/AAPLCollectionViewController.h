/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A subclass of UICollectionViewController that adds support for swipe to edit and drag reordering.
 */

#import "AAPLSwipeToEditController.h"

NS_ASSUME_NONNULL_BEGIN

@class AAPLAction;
/// A subclass of UICollectionViewController that adds support for swipe to edit and drag reordering.
@interface AAPLCollectionViewController : UICollectionViewController <UICollectionViewDelegate,AAPLSwipeToEditControllerDelegate>

@property (nonatomic, getter = isEditing) BOOL editing;

/// Amount to inset content in this view controller. By default, this value will be calculated based on whether the view for this view controller intersects the status bar, navigation bar, and tab bar. The contentInsets are also updated if the keyboard is displayed and its frame intersects with the frame of this controller's view.
@property (nonatomic) UIEdgeInsets contentInsets;

- (void)performBatchUpdates:(void(^)())updates completion:(void(^)())completion;

@end

@interface AAPLCollectionViewController (AAPLCollectionViewControllerEditingActions) <AAPLSwipeToEditControllerDelegate>
- (void)swipeToDeleteCell:(__kindof UICollectionViewCell *)cell;
- (void)didTapRemoveButtonCell:(__kindof UICollectionViewCell *)cell;
- (void)didSelectActionFromCell:(__kindof UICollectionViewCell *)cell;
- (void)presentAlertSheetFromCell:(__kindof UICollectionViewCell *)cell;

- (void)didTapDeleteBarButton;
- (void)didTapDoneBarButton;

@property (strong, nonatomic) NSArray *selectedIndexPaths;

@end




NS_ASSUME_NONNULL_END
