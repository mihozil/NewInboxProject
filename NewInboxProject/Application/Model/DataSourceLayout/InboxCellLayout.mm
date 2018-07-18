//
//  InboxCellLayout.m
//  NewInboxProject
//
//  Created by CPU11805 on 7/12/18.
//  Copyright © 2018 CPU11806. All rights reserved.
//

#import "InboxCellLayout.h"
#import "InboxCollectionViewCellModel.h"

@implementation InboxCellLayout

+ (InboxDataSourceItemLayout)newDefaultLayoutWithModel:(id)model {
    CGSize cellSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 64);
    
    InboxDataSourceItemLayout layout =
    {InboxDataSourceCellContainerView, CGRectMake(0, 0, cellSize.width, cellSize.height),nil,
        {avatarLayout(model),descriptionLayout(model),timeStampLayout()}};
    
    return layout;
}

InboxDataSourceItemLayout avatarLayout(InboxCollectionViewCellModel *model) {
    long margin = 5;
    CGSize cellSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 64);
    CGRect avatarFrame = CGRectMake(margin, margin, cellSize.height-margin*2, cellSize.height-margin*2);
    ConfigView configView = ^(UIView *imgView){
        if ([imgView isKindOfClass:[UIImageView class]]) {
            [(UIImageView*)imgView setImage:[UIImage imageNamed:model.avatarUrl]];
        }
        //        [imgView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:nil action:@selector(onTap)]];
    };
    return {InboxDataSourceCellAvatarView, avatarFrame, configView};
}

InboxDataSourceItemLayout descriptionLayout(InboxCollectionViewCellModel *model) {
    ConfigView configTitle = ^(UIView *titleLabel) {
        if ([titleLabel isKindOfClass:[UILabel class]]) {
            [(UILabel*)titleLabel setFont:[UIFont systemFontOfSize:16.0]];
            [(UILabel*)titleLabel setText:model.title];
        }
    };
    
    ConfigView configCaption = ^(UIView *captionLabel) {
        if ([(UILabel*)captionLabel isKindOfClass:[UILabel class]]) {
            [(UILabel*)captionLabel setFont:[UIFont systemFontOfSize:12.5]];
            [(UILabel*)captionLabel setText:model.caption];
        }
    };
    
    long margin = 3;
    CGSize cellSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 64);
    
    CGRect descriptionFrame = CGRectMake(cellSize.height + margin, margin, cellSize.width - cellSize.height - 25 - margin*2, cellSize.height - margin*2);
    
    CGRect titleFrame = CGRectMake(margin, margin, descriptionFrame.size.width - margin*2, descriptionFrame.size.height/2-margin);
    CGRect captionFrame = CGRectMake(margin, titleFrame.size.height + margin, titleFrame.size.width, descriptionFrame.size.height/2 - margin);
    return {InboxDataSourceCellContainerView, descriptionFrame, nil, {{InboxDataSourceCellTitleLabel, titleFrame, configTitle},{InboxDataSourceCellCaptionLabel, captionFrame, configCaption}}};
}

InboxDataSourceItemLayout timeStampLayout() {
    CGSize cellSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 64);
    CGRect timeStampFrame = CGRectMake(cellSize.width-25, 0, 25, 25);
    return {InboxDataSourceCellTimeStampLabel, timeStampFrame};
}


@end
