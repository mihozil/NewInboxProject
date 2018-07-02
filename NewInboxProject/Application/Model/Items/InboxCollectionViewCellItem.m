//
//  InboxCollectionViewCellItem.m
//  NewInboxProject
//
//  Created by CPU11806 on 5/25/18.
//  Copyright © 2018 CPU11806. All rights reserved.
//

#import "InboxCollectionViewCellItem.h"

@implementation InboxCollectionViewCellItem

- (id)copyWithZone:(NSZone *)zone {
    InboxCollectionViewCellItem *newItem = [super init];
    newItem.avatarUrl = self.avatarUrl;
    newItem.title = self.title;
    newItem.caption = self.caption;
    newItem.timeStamp = self.timeStamp;
    newItem.selectingInEditingState = self.selectingInEditingState;
    return newItem;
}

@end
