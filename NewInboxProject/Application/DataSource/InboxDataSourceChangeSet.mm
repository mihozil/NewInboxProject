//
//  InboxDataSourceChangeSet.m
//  NewInboxProject
//
//  Created by Mihozil on 7/1/18.
//  Copyright © 2018 CPU11806. All rights reserved.
//
#include <set>
using namespace std;
#import "InboxDataSourceChangeSet.h"
#import <UIKit/UIKit.h>
#import "InboxDataSourceState.h"

// temp support only update remove and insert
@interface InboxDataSourceChangeSet ()

@end

@implementation InboxDataSourceChangeSet

- (instancetype)initWithUpdates:(NSDictionary *)updates removes:(NSArray *)remove inserts:(NSDictionary *)inserts {
    self = [super init];
    if (self) {
        self.updates = updates;
        self.removes = sortArray(remove);
        self.inserts = inserts;
        
        self.orderedInsertKeys = orderedKeys(inserts);
    }
    return self;
}

- (instancetype)initWithInsertSections:(NSDictionary*)insertSections {
    self = [super init];
    if (self) {
        self.insertSections = insertSections;
        NSMutableArray *orderKeys = [NSMutableArray new];
        NSArray *sectionKeys = @[InboxSectionChat,InboxSectionAddFriend];
        for (NSString *sectionKey in sectionKeys) {
            NSArray *section = [insertSections objectForKey:sectionKey];
            if (section) {
                [orderKeys addObject:sectionKey];
            }
        }
        self.orderedSectionKeys = [orderKeys copy];
    }
    return self;
}


NSArray* orderedKeys(NSDictionary*dic) {
    set<NSIndexPath*> mySet;
    for (NSIndexPath *indexPath in dic.allKeys) {
        mySet.insert(indexPath);
    }
    NSMutableArray *keys = [NSMutableArray new];
    for (auto it = mySet.begin(); it!=mySet.end(); it++) {
        NSIndexPath *indexPath = *it;
        [keys addObject:indexPath];
    }
    return [keys copy];
}

NSArray* sortArray(NSArray*arr) {
    set<NSIndexPath*> mySet;
    for (NSIndexPath *indexPath in arr) {
        mySet.insert(indexPath);
    }
    NSMutableArray *sortedArr = [NSMutableArray new];
    for (auto it = mySet.begin(); it!=mySet.end(); it++) {
        NSIndexPath *indexPath = *it;
        [sortedArr insertObject:indexPath atIndex:0];
    }
    return [sortedArr copy];
}

@end
