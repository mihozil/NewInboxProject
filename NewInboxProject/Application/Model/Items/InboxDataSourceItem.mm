//
//  InboxDataSourceObject.m
//  ZaloiOS-Development_InHouse
//
//  Created by CPU11806 on 5/25/18.
//

#import "InboxDataSourceItem.h"
#import "IGListDiff.h"
#import "InboxCollectionViewCellItem.h"
#include <queue>

@interface InboxDataSourceItem() <IGListDiffable>

@property (nonatomic) InboxDataSourceItemLayout layout;
@property (strong,nonatomic) NSDictionary *map;
@property (strong, nonatomic) id item;

@end

@implementation InboxDataSourceItem

- (id)initWithItemLayout:(InboxDataSourceItemLayout)layout item:(id)item {
    self = [super init];
    if (self) {
        self.layout = layout;
        self.item = item;
    }
    return self;
}

- (void)configViewWithMap:(NSDictionary *)map cellContentView:(UIView*)contentView {
    self.map = map;
    
    typedef pair<InboxDataSourceItemLayout, UIView*> p2;
    queue<p2> layoutQueue;
    layoutQueue.push({self.layout,contentView});
    
    while (!layoutQueue.empty()) {
        p2 layoutPair = layoutQueue.front();
        InboxDataSourceItemLayout layout = layoutPair.first;
        UIView *superView =layoutPair.second;
        layoutQueue.pop();
        
        UIView*view = [self addSubViewType:layout.cellComponentType frame:layout.frame superView:superView];
        if (layout.configView)
            layout.configView(view);
        
        for (auto it= layout.children.begin(); it!=layout.children.end(); it++) {
            InboxDataSourceItemLayout childLayout = *it;
            layoutQueue.push({childLayout,view});
        }
    }
}

- (UIView*)addSubViewType:(InboxDataSourceCellComponentType)type frame:(CGRect)frame superView:(UIView*)superView {
    UIView *componentView;
    if (type == InboxDataSourceCellContainerView)
        componentView = [[UIView alloc]init];
    else
        componentView = [self.map objectForKey:@(type)];
    
    [componentView setFrame:frame];
    [superView addSubview:componentView];
    return componentView;
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
