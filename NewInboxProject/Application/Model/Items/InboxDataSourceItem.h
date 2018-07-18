//
//  InboxDataSourceObject.h
//  ZaloiOS-Development_InHouse
//
//  Created by CPU11806 on 5/25/18.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <vector>

using namespace std;

typedef enum {
    InboxDataSourceCellContainerView = 0,
    InboxDataSourceCellAvatarView,
    InboxDataSourceCellTitleLabel,
    InboxDataSourceCellCaptionLabel,
    InboxDataSourceCellTopicTitle,
    InboxDataSourceCellTimeStampLabel,
    InboxDataSourceCellRemoveImageView
    
} InboxDataSourceCellComponentType;
typedef void(^ConfigView)(UIView*);

struct InboxDataSourceItemLayout {
    InboxDataSourceCellComponentType cellComponentType;
    CGRect frame;
    ConfigView configView;
    vector<InboxDataSourceItemLayout> children;
};

typedef struct InboxDataSourceItemLayout InboxDataSourceItemLayout;

@interface InboxDataSourceItem : NSObject <NSCopying>

@property (nonatomic) InboxDataSourceItemLayout layout;
@property (strong, nonatomic) id model;

- (id)initWithItemLayout:(InboxDataSourceItemLayout)layout model:(id)model;
- (void)configViewWithMap:(NSDictionary *)map cellContentView:(UIView*)contentView;

@end
