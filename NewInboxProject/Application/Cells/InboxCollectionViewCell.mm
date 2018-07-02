//
//  InboxCollectionViewCell.m
//  ZaloiOS-Development_InHouse
//
//  Created by CPU11806 on 5/25/18.
//

#import "InboxCollectionViewCell.h"
#import "InboxDataSourceItem.h"
#import "InboxCollectionViewCellItem.h"
#include <queue>

@interface InboxCollectionViewCell ()

@property (strong, nonatomic) UIImageView *avatarImageView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *captionLabel;
@property (strong, nonatomic) UILabel *topicTitleLabel;
@property (strong, nonatomic) UILabel *timeStampLabel;

@property (strong, nonatomic) NSDictionary *viewMap;

@end

@implementation InboxCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _viewMap = @{@(InboxDataSourceCellAvatarView):self.avatarImageView,
                    @(InboxDataSourceCellTitleLabel):self.titleLabel,
                    @(InboxDataSourceCellTopicTitle):self.topicTitleLabel,
                    @(InboxDataSourceCellCaptionLabel):self.captionLabel,
                     @(InboxDataSourceCellRemoveImageView):self.removeImageView
                     };
    }
    
    return self;
}

- (void)prepareForReuse {
    if (self.editing) {
        
    }
}

#pragma mark - PROPERTY
- (UIImageView*) avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc]init];
    }
    return _avatarImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        [_titleLabel setFont:[UIFont systemFontOfSize:16]];
    }
    return _titleLabel;
}

- (UILabel *)captionLabel {
    if (!_captionLabel) {
        _captionLabel = [[UILabel alloc]init];
    }
    return _captionLabel;
}


- (UILabel *)timeStampLabel {
    if (!_timeStampLabel) {
        _timeStampLabel = [[UILabel alloc]init];
    }
    return _timeStampLabel;
}

- (UILabel *)topicTitleLabel {
    if (!_topicTitleLabel) {
        _topicTitleLabel = [[UILabel alloc]init];
    }
    return _topicTitleLabel;
}

#pragma mark - setObject

- (void)resetCellContentView {
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }
}

- (void)setObject:(InboxDataSourceItem*)object {
    [self resetCellContentView];
    [object configViewWithMap:_viewMap cellContentView:self.contentView];
}


@end
