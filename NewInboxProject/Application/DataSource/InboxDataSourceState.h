//
//  InboxDataSourceState.h
//  NewInboxProject
//
//  Created by CPU11806 on 5/30/18.
//  Copyright © 2018 CPU11806. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString *const InboxSectionChat;
extern NSString *const InboxSectionAddFriend;

@interface InboxDataSourceState : NSObject <NSCopying>

@property (readonly, copy, nonatomic) NSDictionary<NSString*,NSArray*> *sectionsDic;
@property (readonly, copy, nonatomic) NSArray *sections;

- (id)objectAtIndexPath:(NSIndexPath*)indexPath;
- (instancetype)initWithSectionsDic:(NSDictionary<NSString*,NSArray*>*)sectionsDic;
- (NSArray *)selectingIndexPathInEditingState;
- (NSIndexPath*)indexPathForItem:(id)dataSourceItem inSection:(NSArray*)section;


@end
