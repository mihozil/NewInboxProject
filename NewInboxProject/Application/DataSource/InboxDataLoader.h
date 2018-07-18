//
//  InboxDataLoader.h
//  NewInboxProject
//
//  Created by CPU11806 on 5/25/18.
//  Copyright © 2018 CPU11806. All rights reserved.
//

#import <Foundation/Foundation.h>
@class InboxDataSourceItem;
@class InboxDataSourceState;

typedef void (^loadContentCompletion)(InboxDataSourceState*, NSError*);

/*
 This should be rename InboxDataManager: handle even from model<entity> and doing logic before updating to View/ViewController
 <all these moved from dataSource just to reduce mass dataSource>
 */
@interface InboxDataLoader : NSObject

- (id)initWithActionQueue:(dispatch_queue_t)actionQueue actionQueueName:(const char*)actionQueueName;
- (void)loadContentWithCompletionHandle:(loadContentCompletion)completion;

@end
