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
    
} InboxDataSourceCellComponentType;
typedef void(^ConfigView)(UIView*);

struct InboxDataSourceItemLayout {
    InboxDataSourceCellComponentType cellComponentType;
    CGRect frame;
    ConfigView configView;
    vector<InboxDataSourceItemLayout> children;
};

typedef struct InboxDataSourceItemLayout InboxDataSourceItemLayout;

@interface InboxDataSourceItem : NSObject

- (id)initWithItemLayout:(InboxDataSourceItemLayout)layout item:(id)item;
- (void)configViewWithMap:(NSDictionary *)map cellContentView:(UIView*)contentView;

@end
