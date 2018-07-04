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
@property (strong, nonatomic) NSArray *removes; // big to small
@property (strong, nonatomic) NSDictionary *inserts;

@property (strong, nonatomic) NSDictionary *insertSections;

@property (strong, nonatomic) NSArray *orderedInsertKeys; // small to big
@property (strong, nonatomic) NSArray *orderedSectionKeys;


// temporary if section -> not indexPath and vice verse
- (instancetype)initWithUpdates:(NSDictionary*)updates removes:(NSArray*)remove inserts:(NSDictionary*)inserts;
- (instancetype)initWithInsertSections:(NSArray*)insertSections;

@end
