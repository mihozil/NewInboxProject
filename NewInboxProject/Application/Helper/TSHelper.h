//
//  TSHelper.h
//  UXFrameworkExt
//
//  Created by Hoang Phan on 8/13/14.
//  Copyright (c) 2014 VNG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TSHelper : NSObject

+ (NSString*)createDispatchQueueName:(NSObject*)object;

+ (dispatch_queue_t)createDispatchQueue:(NSObject*)object withName:(const char*)queueName isSerial:(BOOL)isSerial;

+ (BOOL)isCurrentQueue:(dispatch_queue_t)queue withName:(const char*)queueName;
+ (void)dispatchSyncOnQueue:(dispatch_queue_t)queue withName:(const char*)queueName withTask:(dispatch_block_t)block;
+ (void)dispatchAsyncOnQueue:(dispatch_queue_t)queue withName:(const char*)queueName withTask:(dispatch_block_t)block;

+ (void)dispatchBarrierSyncOnQueue:(dispatch_queue_t)queue withName:(const char*)queueName withTask:(dispatch_block_t)block;
+ (void)dispatchBarrierOnQueue:(dispatch_queue_t)queue withName:(const char*)queueName withTask:(dispatch_block_t)block;

+ (void)dispatchOnQueue:(dispatch_queue_t)queue withName:(const char*)queueName withTask:(dispatch_block_t)block;

+ (void)dispatchOnMainQueue:(dispatch_block_t)block;
+ (void)dispatchAsyncMainQueue:(dispatch_block_t)block;

+ (void)dispatchTask:(dispatch_block_t)block afterDelay:(CGFloat)delay onQueue:(dispatch_queue_t)queue;
+ (void)dispatchTaskMainQueue:(dispatch_block_t)block afterDelay:(CGFloat)delay;


NSString* createQueueNameWithObjectFoundation(NSObject* object);
NSString* createQueueNameWithObjectAndPrefix(NSObject* object,NSString* prefix);

dispatch_queue_t createDispatchQueueWithObject(NSObject* object, const char* name, BOOL serial);
BOOL isCurrentQueue(dispatch_queue_t queue, const char* queueName);

void dispatchOnQueue(dispatch_queue_t queue, const char* name, dispatch_block_t block, BOOL sync);

@end
