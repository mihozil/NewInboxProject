//
//  InboxDataSourceChangeSet.h
//  NewInboxProject
//
//  Created by Mihozil on 7/1/18.
//  Copyright © 2018 CPU11806. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InboxDataSourceChangeSet : NSObject

@property (strong, nonatomic) NSDictionary<NSIndexPath*,id> *updates;
@property (strong, nonatomic) NSArray *removes;
@property (strong, nonatomic) NSDictionary *inserts;

@property (strong, nonatomic) NSArray *insertSections;

@property (strong, nonatomic) NSArray *orderedInsertsKey;

- (instancetype)initWithUpdates:(NSDictionary*)updates removes:(NSArray*)remove inserts:(NSDictionary*)inserts;
- (instancetype)initWithInsertSections:(NSArray*)insertSections;

@end
