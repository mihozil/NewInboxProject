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
                    @(InboxDataSourceCellCaptionLabel):self.captionLabel};

    }
    
    return self;
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
        [_captionLabel setFont:[UIFont systemFontOfSize:12.5]];
    }
    return _captionLabel;
}


- (UILabel *)timeStampLabel {
    if (!_timeStampLabel) {
        _timeStampLabel = [[UILabel alloc]init];
        [self.contentView addSubview:_timeStampLabel];
    }
    return _timeStampLabel;
}

- (UILabel *)topicTitleLabel {
    if (!_topicTitleLabel) {
        _topicTitleLabel = [[UILabel alloc]init];
        [self.contentView addSubview:_topicTitleLabel];
    }
    return _topicTitleLabel;
}

#pragma mark - setObject
- (void)setObject:(InboxDataSourceItem*)object {
    typedef pair<InboxDataSourceItemLayout, UIView*> p2;
    queue<p2> layoutQueue;
    layoutQueue.push({object.layout,self.contentView});

    while (!layoutQueue.empty()) {
        p2 layoutPair = layoutQueue.front();
        InboxDataSourceItemLayout layout = layoutPair.first;
        layoutQueue.pop();
        UIView *superView =layoutPair.second;

        UIView*view = [self addSubViewType:layout.cellComponentType frame:layout.frame superView:superView];

        for (auto it= layout.children.begin(); it!=layout.children.end(); it++) {
            InboxDataSourceItemLayout childLayout = *it;
            layoutQueue.push({childLayout,view});
        }
    }
    
    InboxCollectionViewCellItem *item = (InboxCollectionViewCellItem*)object.item;
    self.titleLabel.text = item.title;
    self.captionLabel.text = item.caption;
    [self.avatarImageView setImage:[UIImage imageNamed:item.avatarUrl]];
}

- (UIView*)addSubViewType:(InboxDataSourceCellComponentType)type frame:(CGRect)frame superView:(UIView*)superView {
    UIView *componentView;
    if (type == InboxDataSourceCellContainerView)
        componentView = [[UIView alloc]init];
    else
        componentView = [_viewMap objectForKey:@(type)];
    
    [componentView setFrame:frame];
    [superView addSubview:componentView];
    return componentView;
}


@end
