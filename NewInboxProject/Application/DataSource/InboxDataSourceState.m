//
//  InboxDataSourceState.m
//  NewInboxProject
//
//  Created by CPU11806 on 5/30/18.
//  Copyright © 2018 CPU11806. All rights reserved.
//

#import "InboxDataSourceState.h"

NSString *const InboxSectionChat = @"InboxSectionChat";
NSString *const InboxSectionAddFriend = @"InboxSectionAddFriend";

@interface InboxDataSourceState ()


@end

@implementation InboxDataSourceState

- (void)resetDataSourceState {
    self.sections = [NSDictionary new];
}

- (void)addSection:(NSArray*)items forKey:(NSString *)sectionKey {
    if (!self.sections) {
        self.sections = [NSDictionary new];
    }
    NSMutableDictionary *sections = self.sections? [self.sections mutableCopy] : [NSMutableDictionary new];
    [sections setObject:items forKey:sectionKey];
    self.sections = sections;
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *section = [self.sections.allValues objectAtIndex:indexPath.section];
    return [section objectAtIndex:indexPath.row];
}

- (id)copyWithZone:(NSZone *)zone {
    id state = [[self class]allocWithZone:zone];
    [state setSections:self.sections];
    return state;
}

- (void)removeItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *key = [self.sections.allKeys objectAtIndex:indexPath.section];
    NSMutableArray *section = [[self.sections objectForKey:key] mutableCopy];
    [section removeObjectAtIndex:indexPath.item];
    
    NSMutableDictionary *sections = [self.sections mutableCopy];
    [sections setObject:section forKey:key];
    
    self.sections = [sections copy];
}

@end
