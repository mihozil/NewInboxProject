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

- (void)resetDataSourceState;
- (void)addSection:(NSArray*)items forKey:(NSString*)sectionKey;
- (void)removeItemAtIndexPath:(NSIndexPath*)indexPath;

@property (copy, nonatomic) NSDictionary<NSString*,NSArray*> *sections;

- (id)objectAtIndexPath:(NSIndexPath*)indexPath;


@end
