//
//  InboxDataSourceState.m
//  NewInboxProject
//
//  Created by CPU11806 on 5/30/18.
//  Copyright © 2018 CPU11806. All rights reserved.
//

#import "InboxDataSourceState.h"
#import "InboxDataSourceItem.h"
#import "InboxCollectionViewCellItem.h"

NSString *const InboxSectionChat = @"InboxSectionChat";
NSString *const InboxSectionAddFriend = @"InboxSectionAddFriend";

@interface InboxDataSourceState ()

@property (copy, nonatomic) NSDictionary<NSString*,NSArray*> *sectionsDic;
@property (copy, nonatomic) NSArray *sections;

@end

@implementation InboxDataSourceState

- (instancetype)initWithSectionsDic:(NSDictionary *)sectionsDic {
    self = [super init];
    if (self) {
        self.sectionsDic = sectionsDic;
        
        NSMutableArray *sections = [NSMutableArray new];
        NSArray *sectionsKey = @[InboxSectionChat,InboxSectionAddFriend];
        for (NSString *key in sectionsKey) {
            NSArray *section = [sectionsDic objectForKey:key];
            if (section)
                [sections addObject:section];
        }
        self.sections = [sections copy];
    }
    return self;
}


- (id)copyWithZone:(NSZone *)zone { // no need
    id state = [[self class]allocWithZone:zone];
    [state setSectionsDic:[self.sectionsDic copy]];
    [state setSections:[self.sections copy]];
    return state;
}

#pragma mark read

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *section = [self.sections objectAtIndex:indexPath.section];
    return [section objectAtIndex:indexPath.row];
}

- (NSArray *)selectingIndexPathInEditingState {
    NSMutableArray *selects = [NSMutableArray new];
    for (NSArray *section in self.sections) {
        for (InboxDataSourceItem *datasourceItem in section) {
            if ([datasourceItem.item isKindOfClass:[InboxCollectionViewCellItem class]]) {
                InboxCollectionViewCellItem *item = datasourceItem.item;
                
                NSInteger sectionIndex = [self.sections indexOfObject:section];
                NSInteger itemIndex = [section indexOfObject:datasourceItem];
                [selects addObject:[NSIndexPath indexPathForItem:itemIndex inSection:sectionIndex]];
            }
        }
    }
    return selects;
}

- (NSIndexPath *)indexPathForItem:(id)dataSourceItem inSection:(NSArray *)section {
    NSInteger sectionIndex = [self.sections indexOfObject:section];
    NSInteger itemIndex = [section indexOfObject:dataSourceItem];
    if (sectionIndex!=NSNotFound && itemIndex!=NSNotFound)
        return [NSIndexPath indexPathForItem:itemIndex inSection:sectionIndex];
    else
        return nil;
}

@end
