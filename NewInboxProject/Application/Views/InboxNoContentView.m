//
//  InboxNoContentView.m
//  NewInboxProject
//
//  Created by CPU11805 on 7/12/18.
//  Copyright © 2018 CPU11806. All rights reserved.
//

#import "InboxNoContentView.h"

@implementation InboxNoContentView {
    UILabel *noContentLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        noContentLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        noContentLabel.textAlignment = NSTextAlignmentCenter;
        noContentLabel.font = [UIFont systemFontOfSize:18.0 weight:UIFontWeightSemibold];
        noContentLabel.numberOfLines = 3;
        noContentLabel.text = @"No Content! Please try again";
        [self addSubview:noContentLabel];
        
    }
    return self;
}

@end
