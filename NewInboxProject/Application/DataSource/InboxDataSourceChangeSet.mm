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
        
        self.orderedInsertsKey = orderedKeys(inserts);
    }
    return self;
}

- (instancetype)initWithInsertSections:(NSArray*)insertSections {
    self = [super init];
    if (self) {
        self.insertSections = insertSections;
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
        [sortedArr addObject:indexPath];
    }
    return [sortedArr copy];
}

@end
