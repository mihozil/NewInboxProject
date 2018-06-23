//
//  InboxDataSourceItemsDiff.h
//  NewInboxProject
//
//  Created by CPU11806 on 5/29/18.
//  Copyright © 2018 CPU11806. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class InboxDataSourceState;

@interface InboxDataSourceItemsDiff : NSObject

- (id)initWithOldState:(InboxDataSourceState*)oldState newState:(InboxDataSourceState*)newState;
- (void)implementAnimationCollectionView:(UICollectionView*)collectionView;

@end
