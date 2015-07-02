//
//  ChatTableViewCell.h
//  Chat
//
//  Created by 货道网 on 15/5/8.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ChatBubbleView.h"

#import "ChatTextBubbleView.h"
#import "ChatImageBubbleView.h"
#import "ChatLocationBubbleView.h"
#import "ChatAudioBubbleView.h"

#import "ChatTableCellTimeView.h"

typedef enum : NSUInteger {
    MenuItemType_Copy,
    MenuItemType_Delete,
    MenuItemType_Again,
} MenuItemType;

@interface ChatTableViewCell : UITableViewCell
{    
    ChatTableCellTimeView * _timeView;
}

@property (nonatomic, strong) id  message;
@property (nonatomic, readonly) ChatBubbleView * bubbleView;
@property (nonatomic, copy) void (^menuItemClick) (ChatTableViewCell *,MenuItemType);
/**
 *  通过model 初始化不同的 cell
 *
 *  @param model
 *
 *  @return cell
 */
- (id)initWithMessageModel:(Message *)message;

/**
 *  通过 model 计算高度
 *
 *  @param model
 *
 *  @return
 */
+ (CGFloat)heightForMessageModel:(Message *)message;

/**
 *  根据model 的不同类型返回不同的 Identifier
 *
 *  @param model
 *
 *  @return identifier
 */
+ (NSString *)cellIdentifierForMessageModel:(Message *)message;

@end
