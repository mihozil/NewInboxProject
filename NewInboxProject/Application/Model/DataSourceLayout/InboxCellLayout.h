//
//  InboxCellLayout.h
//  NewInboxProject
//
//  Created by CPU11805 on 7/12/18.
//  Copyright © 2018 CPU11806. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InboxDataSourceItem.h"

@interface InboxCellLayout : NSObject

+ (InboxDataSourceItemLayout)newDefaultLayoutWithModel:(id)model;

@end
