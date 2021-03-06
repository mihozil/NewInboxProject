//
//  InboxDataSourceItemsDiff.m
//  NewInboxProject
//
//  Created by CPU11806 on 5/29/18.
//  Copyright © 2018 CPU11806. All rights reserved.
//

#import "InboxDataSourceItemsDiff.h"
#import "IGListDiff.h"
#import "InboxDataSourceState.h"

@interface InboxDataSourceItemsDiff()

@property (strong, nonatomic) NSMutableArray *insertIndexPaths;
@property (strong, nonatomic) NSMutableArray *deleteIndexPaths;
@property (strong, nonatomic) NSMutableArray<NSDictionary*> *moves;
@property (strong, nonatomic) NSMutableArray *reloadIndexPaths;

@property (strong, nonatomic) NSMutableIndexSet *insertSections;
@property (strong, nonatomic) NSMutableIndexSet *deleteSections;

@end

@implementation InboxDataSourceItemsDiff

- (id)initWithOldState:(InboxDataSourceState *)oldState newState:(InboxDataSourceState *)newState {
    self = [super init];
    if (self) {
        [self setupDiffWithOldState:oldState newState:newState];
    }
    return self;
}

- (void)setupDiffWithOldState:(InboxDataSourceState*)oldState newState:(InboxDataSourceState*)newState {
    [self resetAnimation];
    
    NSArray *sectionKeys = @[InboxSectionChat,InboxSectionAddFriend];
    for (NSString *key in sectionKeys) {
        NSArray *oldSection = [oldState.sectionsDic objectForKey:key];
        NSArray *newSection = [newState.sectionsDic objectForKey:key];
        if (oldSection && newSection) {
            IGListIndexPathResult *result = IGListDiffPaths([oldState.sections indexOfObject:oldSection], [newState.sections indexOfObject:newSection], oldSection, newSection, IGListDiffEquality);
            
            [self.insertIndexPaths addObjectsFromArray:result.inserts];
            [self.deleteIndexPaths addObjectsFromArray:result.deletes];
            [self.reloadIndexPaths addObjectsFromArray:result.updates];
            for (IGListMoveIndexPath *move in result.moves) {
                [self.moves addObject:@{@"from":move.from,@"to":move.to}];
            }
        }
        if (oldSection && !newSection) {
            [self.deleteSections addIndex:[oldState.sections indexOfObject:oldSection]];
        }
        if (!oldSection && newSection) {
            [self.insertSections addIndex:[newState.sections indexOfObject:newSection]];
        }
    }
    
}

- (NSArray*)convertIndexPaths:(NSArray*)indexPaths toSection:(NSInteger)section {
    NSMutableArray *newIndexPaths = [NSMutableArray new];
    for (NSIndexPath *indexPath in indexPaths) {
        [newIndexPaths addObject:[NSIndexPath indexPathForItem:indexPath.item inSection:section]];
    }
    return newIndexPaths;
}

- (void)resetAnimation {
    self.insertIndexPaths = [NSMutableArray new];
    self.deleteIndexPaths = [NSMutableArray new];
    self.moves = [NSMutableArray new];
    self.reloadIndexPaths = [NSMutableArray new];
    
    self.insertSections = [NSMutableIndexSet new];
    self.deleteSections = [NSMutableIndexSet new];
}

- (void)implementAnimationCollectionView:(UICollectionView*)collectionView {
    if (_insertSections.count>0)
        [collectionView insertSections:_insertSections];
    if (_deleteSections.count>0)
        [collectionView deleteSections:_deleteSections];
    
    if (_insertIndexPaths.count>0)
        [collectionView insertItemsAtIndexPaths:_insertIndexPaths];
    NSLog(@"animation: insert: %ld",_insertIndexPaths.count);
    
    if (_deleteIndexPaths.count>0)
        [collectionView deleteItemsAtIndexPaths:_deleteIndexPaths];
    NSLog(@"animation: delete: %ld",_deleteIndexPaths.count);
    for (NSIndexPath *indexPath in _deleteIndexPaths)
        NSLog(@"animation: indexPath: %ld",indexPath.item);
//    for (NSDictionary *move in _moves) {
//        NSIndexPath *from = [move objectForKey:@"from"];
//        NSIndexPath *to = [move objectForKey:@"to"];
//        if ([from isKindOfClass:[NSIndexPath class]] && [to isKindOfClass:[NSIndexPath class]])
//            [collectionView moveItemAtIndexPath:from toIndexPath:to];
//    }
    // temp no move
    if (_reloadIndexPaths.count>0)
        [collectionView reloadItemsAtIndexPaths:_reloadIndexPaths];
    NSLog(@"animation: reload: %ld",_reloadIndexPaths.count);
}

@end
