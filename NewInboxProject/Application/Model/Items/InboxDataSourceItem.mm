//
//  InboxDataSourceObject.m
//  ZaloiOS-Development_InHouse
//
//  Created by CPU11806 on 5/25/18.
//

#import "InboxDataSourceItem.h"
#import "IGListDiff.h"
#import "InboxCollectionViewCellModel.h"
#include <queue>

@interface InboxDataSourceItem() <IGListDiffable>

@property (strong,nonatomic) NSDictionary *map;


@end

@implementation InboxDataSourceItem

- (id)initWithItemLayout:(InboxDataSourceItemLayout)layout model:(id)model {
    self = [super init];
    if (self) {
        self.layout = layout;
        self.model = model;
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
    if ([self.model isKindOfClass:[InboxCollectionViewCellModel class]]) {
        InboxCollectionViewCellModel *collectionViewItem = self.model;
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
    InboxCollectionViewCellModel *item = (InboxCollectionViewCellModel*)self.model;
    
    if ([item isKindOfClass:[InboxCollectionViewCellModel class]]) {
        NSString *diffId = [NSString stringWithFormat:@"%@_%@",item.title,item.caption];
        return diffId;
    }
    return @"AnEmptyString";
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
    InboxCollectionViewCellModel *firstModel = (InboxCollectionViewCellModel*)self.model;
    InboxCollectionViewCellModel *secondModel = [(InboxDataSourceItem*)object model];

    if ([secondModel isKindOfClass:[InboxCollectionViewCellModel class]]) {
        if (firstModel.selectingInEditingState != secondModel.selectingInEditingState) {
            return false;
        }
        if (firstModel.selectingInEditingState == 1 || secondModel.selectingInEditingState ==1) {
            
        }
    }
    
    return true;
}

- (id)copyWithZone:(NSZone *)zone {
    InboxDataSourceItem *newItem = [[InboxDataSourceItem alloc]init];
    newItem.layout = self.layout;
    newItem.model = [self.model copy];
    
    return newItem;
}

@end
