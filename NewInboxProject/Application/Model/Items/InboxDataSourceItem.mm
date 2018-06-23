//
//  InboxDataSourceObject.m
//  ZaloiOS-Development_InHouse
//
//  Created by CPU11806 on 5/25/18.
//

#import "InboxDataSourceItem.h"
#import "IGListDiff.h"
#import "InboxCollectionViewCellItem.h"

@interface InboxDataSourceItem() <IGListDiffable>

@end

@implementation InboxDataSourceItem

- (id)initWithItem:(id)item layout:(InboxDataSourceItemLayout)layout {
    self = [super init];
    if (self) {
        self.item = item;
        self.layout = layout;
    }
    return self;
}

- (id<NSObject>)diffIdentifier {
    InboxCollectionViewCellItem *item = (InboxCollectionViewCellItem*)self.item;
    if ([item isKindOfClass:[InboxCollectionViewCellItem class]]) {
        return item.title;
    }
    return @"AnEmptyString";
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
    return true;

}

@end
