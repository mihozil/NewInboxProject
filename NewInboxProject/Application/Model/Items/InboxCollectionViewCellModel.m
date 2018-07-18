//
//  InboxCollectionViewCellItem.m
//  NewInboxProject
//
//  Created by CPU11806 on 5/25/18.
//  Copyright © 2018 CPU11806. All rights reserved.
//

#import "InboxCollectionViewCellModel.h"

@implementation InboxCollectionViewCellModel

- (id)copyWithZone:(NSZone *)zone {
    InboxCollectionViewCellModel *newItem = [[InboxCollectionViewCellModel alloc] init];
    newItem.avatarUrl = self.avatarUrl;
    newItem.title = self.title;
    newItem.caption = self.caption;
    newItem.timeStamp = self.timeStamp;
    newItem.selectingInEditingState = self.selectingInEditingState;
    return newItem;
}

@end
