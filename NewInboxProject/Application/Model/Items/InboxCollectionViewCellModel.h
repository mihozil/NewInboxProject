//
//  InboxCollectionViewCellItem.h
//  NewInboxProject
//
//  Created by CPU11806 on 5/25/18.
//  Copyright © 2018 CPU11806. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InboxCollectionViewCellModel : NSObject <NSCopying>

@property (copy, nonatomic) NSString *avatarUrl, *title, *caption, *timeStamp;
@property (assign, nonatomic) BOOL selectingInEditingState;

@end
