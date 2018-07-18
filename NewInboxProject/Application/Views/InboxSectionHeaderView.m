//
//  InboxSectionHeaderView.m
//  NewInboxProject
//
//  Created by CPU11805 on 7/13/18.
//  Copyright © 2018 CPU11806. All rights reserved.
//

#import "InboxSectionHeaderView.h"

@implementation InboxSectionHeaderView {
    UILabel *_titleLabel;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _titleLabel = [[UILabel alloc]init];
        [_titleLabel setFont:[UIFont systemFontOfSize:18.0 weight:UIFontWeightSemibold]];
        [_titleLabel setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:_titleLabel];
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _titleLabel.text = title;
}

@end
