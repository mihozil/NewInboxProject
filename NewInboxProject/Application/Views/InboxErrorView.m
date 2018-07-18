//
//  InboxErrorView.m
//  NewInboxProject
//
//  Created by CPU11805 on 7/12/18.
//  Copyright © 2018 CPU11806. All rights reserved.
//

#import "InboxErrorView.h"

@implementation InboxErrorView {
    UILabel *errorLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        errorLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        errorLabel.textAlignment = NSTextAlignmentCenter;
        errorLabel.font = [UIFont systemFontOfSize:18.0 weight:UIFontWeightSemibold];
        errorLabel.numberOfLines = 3;
        errorLabel.text = @"Error! Please try again";
        [self addSubview:errorLabel];
        
    }
    return self;
}

@end
