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

@property (strong,nonatomic) NSDictionary *map;


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
    
    [self configDefaultView];
    
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

- (void)configDefaultView {
    if ([self.item isKindOfClass:[InboxCollectionViewCellItem class]]) {
        InboxCollectionViewCellItem *collectionViewItem = self.item;
        UIImageView *removeImageView = [self.map objectForKey:@(InboxDataSourceCellRemoveImageView)];
        if (collectionViewItem.selectingInEditingState) {
            removeImageView.alpha = 1.0;
        }
        else {
            removeImageView.alpha = 0.5;
        }
        
    }
}

#pragma mark other

- (id<NSObject>)diffIdentifier {
    InboxCollectionViewCellItem *item = (InboxCollectionViewCellItem*)self.item;
    
    if ([item isKindOfClass:[InboxCollectionViewCellItem class]]) {
        NSString *diffId = [NSString stringWithFormat:@"%@_%@",item.title,item.caption];
        return diffId;
    }
    return @"AnEmptyString";
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
    InboxCollectionViewCellItem *firstItem = (InboxCollectionViewCellItem*)self.item;
    InboxCollectionViewCellItem *secondItem = [(InboxDataSourceItem*)object item];

    if ([secondItem isKindOfClass:[InboxCollectionViewCellItem class]]) {
        if (firstItem.selectingInEditingState != secondItem.selectingInEditingState) {
            return false;
        }
        if (firstItem.selectingInEditingState == 1 || secondItem.selectingInEditingState ==1) {
            
        }
    }
    
    return true;
}

- (id)copyWithZone:(NSZone *)zone {
    InboxDataSourceItem *newItem = [[InboxDataSourceItem alloc]init];
    newItem.layout = self.layout;
    newItem.item = [self.item copy];
    NSLog(@"old - new cellItem: %@ %@",self.item,newItem.item);
    return newItem;
}

@end
