//
//  TSHelper.m
//  UXFrameworkExt
//
//  Created by Hoang Phan on 8/13/14.
//  Copyright (c) 2014 VNG. All rights reserved.
//

#import "TSHelper.h"

@implementation TSHelper

NSString* createQueueNameWithObjectFoundation(NSObject* object) {
    return createQueueNameWithObjectAndPrefix(object, @"com.vng.ux.queue");
}

inline NSString* createQueueNameWithObjectAndPrefix(NSObject* object,NSString* prefix) {
    return [NSString stringWithFormat:@"%@.%@.%p", prefix, [[object class] description], object];
}

+ (NSString*)createDispatchQueueName:(NSObject*)object {
    return [NSString stringWithFormat:@"%@_dispatchQueue_%p", [[object class] description], object];
}

+ (dispatch_queue_t)createDispatchQueue:(NSObject*)object withName:(const char*)queueName isSerial:(BOOL)isSerial {
    return createDispatchQueueWithObject(object, queueName, isSerial);
}

inline dispatch_queue_t createDispatchQueueWithObject(NSObject* object, const char* name, BOOL serial) {
    
    dispatch_queue_t dispatchQueue = dispatch_queue_create(name, serial?DISPATCH_QUEUE_SERIAL:DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_queue_set_specific(dispatchQueue, name, (void*) name, NULL);
    
    return dispatchQueue;
}


inline BOOL isCurrentQueue(dispatch_queue_t queue, const char* queueName) {
    return dispatch_get_specific(queueName) != NULL;
}

+ (BOOL)isCurrentQueue:(dispatch_queue_t)queue withName:(const char*)queueName {
    return isCurrentQueue(queue, queueName);
}

+ (void)dispatchSyncOnQueue:(dispatch_queue_t)queue withName:(const char*)queueName withTask:(dispatch_block_t)block {
    if (isCurrentQueue(queue, queueName))
    {
        block();
    }
    else
        dispatch_sync(queue, block);
}

+ (void)dispatchAsyncOnQueue:(dispatch_queue_t)queue withName:(const char *)queueName withTask:(dispatch_block_t)block {
    dispatch_async(queue, block);
}

+ (void)dispatchOnQueue:(dispatch_queue_t)queue withName:(const char*)queueName withTask:(dispatch_block_t)block {
    if (isCurrentQueue(queue, queueName)) {
        return block();
    } else {
        dispatch_async(queue, block);
    }
}

+ (void)dispatchBarrierSyncOnQueue:(dispatch_queue_t)queue withName:(const char*)queueName withTask:(dispatch_block_t)block {
    if (isCurrentQueue(queue, queueName))
    {
        return block();
    }
    else
        dispatch_barrier_sync(queue, block);
}

+ (void)dispatchBarrierOnQueue:(dispatch_queue_t)queue withName:(const char*)queueName withTask:(dispatch_block_t)block {
    if (isCurrentQueue(queue, queueName))
    {
        return block();
    }
    else
        dispatch_barrier_async(queue, block);
}

+ (void)dispatchOnMainQueue:(dispatch_block_t)block {
    if ([NSThread isMainThread])
    {
        block();
    }
    else
        dispatch_async(dispatch_get_main_queue(), block);
}

+ (void)dispatchAsyncMainQueue:(dispatch_block_t)block {
    dispatch_async(dispatch_get_main_queue(), block);
}

+ (void)dispatchTask:(dispatch_block_t)block afterDelay:(CGFloat)delay onQueue:(dispatch_queue_t)queue {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), queue, block);
}

+ (void)dispatchTaskMainQueue:(dispatch_block_t)block afterDelay:(CGFloat)delay {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_main_queue(), block);
}


@end
