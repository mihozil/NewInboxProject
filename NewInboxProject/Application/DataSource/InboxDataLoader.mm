//
//  InboxDataLoader.m
//  NewInboxProject
//
//  Created by CPU11806 on 5/25/18.
//  Copyright © 2018 CPU11806. All rights reserved.
//

#import "InboxDataLoader.h"
#import "InboxCellLayout.h"
#import "InboxCollectionViewCellModel.h"
#import "InboxDataSourceState.h"
#include <vector>
#import "TSHelper.h"

@interface InboxDataLoader()

@end

@implementation InboxDataLoader {
    dispatch_queue_t _actionQueue;
    const char* _actionQueueName;
}

- (id)initWithActionQueue:(dispatch_queue_t)actionQueue actionQueueName:(const char*)actionQueueName {
    self = [super init];
    if (self) {
        _actionQueue = actionQueue;
        _actionQueueName = actionQueueName;
    }
    return self;
}

- (void)loadContentWithCompletionHandle:(loadContentCompletion)completion {
    [TSHelper dispatchOnQueue:_actionQueue withName:_actionQueueName withTask:^{
        [self fetchChatsWithCompletionHandle:^(NSArray<NSDictionary*>*entities,NSArray<NSDictionary*>*requests, NSError*error) {
            if (error) {
                if (completion)
                    completion(nil,error);
                return;
            }
            
            InboxDataSourceState *dataSouraceState = [self creatingDataSourceStateByEntities:entities requests:requests];
            if (completion)
                completion([dataSouraceState copy], nil);
        }];
    }];
}

#pragma mark creatingqueueItems
- (InboxDataSourceState*)creatingDataSourceStateByEntities:(NSArray*)entities requests:(NSArray*)requests {
    // temp just one section
    NSMutableDictionary *newSections = [NSMutableDictionary new];
    
    NSMutableArray *items = [NSMutableArray new];
    for (NSDictionary *entity in entities) {
        InboxDataSourceItem *dataSourceItem = [self newItemWithEntity:entity];
        [items addObject:dataSourceItem];
    }
    if (items.count>0)
        [newSections setObject:items forKey:InboxSectionChat];
    
    NSMutableArray *requestItems = [NSMutableArray new];
    for (NSDictionary *request in requests) {
        InboxDataSourceItem *dataSourceItem = [self newItemWithEntity:request];
        [requestItems addObject:dataSourceItem];
    }
    if (requestItems.count>0)
        [newSections setObject:requestItems forKey:InboxSectionAddFriend];
    
    return [[InboxDataSourceState alloc]initWithSectionsDic:newSections];
}

- (InboxDataSourceItem*)newItemWithEntity:(NSDictionary*)entity {
    InboxCollectionViewCellModel *model = [[InboxCollectionViewCellModel alloc]init];
    model.title = [entity objectForKey:@"title"];
    model.caption = [entity objectForKey:@"detail"];
    model.timeStamp = [entity objectForKey:@"lastUpdate"];
    model.avatarUrl = [entity objectForKey:@"icon"];
    
    InboxDataSourceItemLayout layout = [InboxCellLayout newDefaultLayoutWithModel:model];
    
    return [[InboxDataSourceItem alloc]initWithItemLayout:layout model:model];
}


#pragma mark fetch

- (void)fetchChatsWithCompletionHandle:(void(^)(NSArray<NSDictionary*>*chats, NSArray<NSDictionary*>*requests,  NSError*error))completion {
    
    if (completion) {
        [self fetchJsonResourceWithName:@"chat" completionHandle:^(NSDictionary*json, NSError*error) {
            NSArray *entities = json[@"result"];
            NSArray *requests = json[@"requests"];
            completion(entities,requests,error);
        }];
    }
}

- (void)fetchJsonResourceWithName:(NSString*)name completionHandle:(void (^) (NSDictionary*json, NSError*error))completion {
    NSURL *resourceURL = [[NSBundle mainBundle]URLForResource:name withExtension:@"json"];
    if (!resourceURL) {
        NSAssert(NO, @"invalid jsonResource");
    }
    
    NSError*error;
    NSData *data = [NSData dataWithContentsOfURL:resourceURL options:NSDataReadingMappedIfSafe error:&error];
    if (!data) {
        NSLog(@"No Data");
        return;
    }
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (!json) {
        if (completion)
            completion(nil,error);
    }
    
    NSNumber *delayResultNumber = json[@"delayResult"];
    if (delayResultNumber && [delayResultNumber isKindOfClass:[NSNumber class]]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([delayResultNumber floatValue] * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (completion)
                completion(json,error);
        });
    } else {
        if (completion)
            completion(json,error);
    }
}

#pragma mark - Update
- (void)insertEntity:(NSDictionary*)entity atIndexPath:(NSIndexPath*)indexPath {
    InboxDataSourceItem *item = [self newItemWithEntity:entity];
    // updateQueueState
}

@end
