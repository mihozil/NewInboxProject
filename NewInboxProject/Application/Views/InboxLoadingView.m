//
//  InboxLoadingView.m
//  NewInboxProject
//
//  Created by CPU11806 on 6/20/18.
//  Copyright © 2018 CPU11806. All rights reserved.
//

#import "InboxLoadingView.h"

@implementation InboxLoadingView {
    UIActivityIndicatorView *activityIndicatorView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        activityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicatorView.frame = CGRectMake(0, 0, 66, 66);
        activityIndicatorView.center = CGPointMake(frame.size.width/2, frame.size.height/2);
        [activityIndicatorView startAnimating];
        [self addSubview:activityIndicatorView];
    }
    return self;
}


@end
