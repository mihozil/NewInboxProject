//
//  InboxDataLoader.m
//  NewInboxProject
//
//  Created by CPU11806 on 5/25/18.
//  Copyright © 2018 CPU11806. All rights reserved.
//

#import "InboxDataLoader.h"
#import "InboxDataSourceItem.h"
#import "InboxCollectionViewCellItem.h"
#import "InboxDataSourceState.h"
#include <vector>
#import "TSHelper.h"

@interface InboxDataLoader()

@end

@implementation InboxDataLoader {
    InboxDataSourceState *_queueState;
    dispatch_queue_t _actionQueue;
    const char* _actionQueueName;
}

- (id)initWithQueueState:(InboxDataSourceState*)queueState actionQueue:(dispatch_queue_t)actionQueue actionQueueName:(const char*)actionQueueName {
    self = [super init];
    if (self) {
        _queueState = queueState;
        _actionQueue = actionQueue;
        _actionQueueName = actionQueueName;
    }
    return self;
}

- (void)loadContentWithCompletionHandle:(loadContentCompletion)completion {
    [TSHelper dispatchOnQueue:_actionQueue withName:_actionQueueName withTask:^{
        [self fetchChatsWithCompletionHandle:^(NSArray<NSDictionary*>*entities, NSError*error) {
            if (error) {
                if (completion)
                    completion(nil,error);
                return;
            }
            
            [self creatingqueueItemsByEntities:entities];
            if (completion)
                completion([_queueState copy], nil);
        }];
    }];
}

#pragma mark creatingqueueItems
- (void)creatingqueueItemsByEntities:(NSArray*)entities {
    [_queueState resetDataSourceState];
    NSMutableArray *items = [NSMutableArray new];
    for (NSDictionary *entity in entities) {
        
        InboxCollectionViewCellItem *item = [[InboxCollectionViewCellItem alloc]init];
        item.title = [entity objectForKey:@"title"];
        item.caption = [entity objectForKey:@"detail"];
        item.timeStamp = [entity objectForKey:@"lastUpdate"];
        item.avatarUrl = [entity objectForKey:@"icon"];
        
        CGSize cellSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 64);
        
        InboxDataSourceItemLayout layout =
        {InboxDataSourceCellContainerView, CGRectMake(0, 0, cellSize.width, cellSize.height),
            {avatarLayout(),descriptionLayout(),timeStampLayout()}};
        
        InboxDataSourceItem *dataSourceItem = [[InboxDataSourceItem alloc]initWithItem:item layout:layout];
        [items addObject:dataSourceItem];
    }
    [_queueState addSection:items forKey:InboxSectionChat]; // temp just chat
}

InboxDataSourceItemLayout avatarLayout() {
    long margin = 5;
    CGSize cellSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 64);
    CGRect avatarFrame = CGRectMake(margin, margin, cellSize.height-margin*2, cellSize.height-margin*2);
    return {InboxDataSourceCellAvatarView, avatarFrame};
}

InboxDataSourceItemLayout descriptionLayout() {
    long margin = 3;
    CGSize cellSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 64);
    
    CGRect descriptionFrame = CGRectMake(cellSize.height + margin, margin, cellSize.width - cellSize.height - 25 - margin*2, cellSize.height - margin*2);

    CGRect titleFrame = CGRectMake(margin, margin, descriptionFrame.size.width - margin*2, descriptionFrame.size.height/2-margin);
    CGRect captionFrame = CGRectMake(margin, titleFrame.size.height + margin, titleFrame.size.width, descriptionFrame.size.height/2 - margin);
    return {InboxDataSourceCellContainerView, descriptionFrame, {{InboxDataSourceCellTitleLabel, titleFrame},{InboxDataSourceCellCaptionLabel, captionFrame}}};
}

InboxDataSourceItemLayout timeStampLayout() {
    CGSize cellSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 64);
    CGRect timeStampFrame = CGRectMake(cellSize.width-25, 0, 25, 25);
    return {InboxDataSourceCellTimeStampLabel, timeStampFrame};
}

#pragma mark fetch

- (void)fetchChatsWithCompletionHandle:(void(^)(NSArray<NSDictionary*>*chats, NSError*error))completion {
    
    if (completion) {
        [self fetchJsonResourceWithName:@"chat" completionHandle:^(NSDictionary*json, NSError*error) {
            NSArray *entities = json[@"result"];
            completion(entities,error);
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

@end
