//
//  VoiceChatView.h
//  Chat
//
//  Created by 货道网 on 15/6/1.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 语音聊天状态

 */
typedef enum : NSUInteger {
    
    VoiceState_Connecting, // 连接中
    VoiceState_Disconnect, // 断开连接
    VoiceState_Connect, // 连接
    VoiceState_OtherOffline, // 对方不在线
    VoiceState_OtherRefused, // 对方拒绝
    VoiceState_Calling, // 通话中
} VoiceType;

/**
 *  语音聊天显示界面
 */
@interface VoiceChatView : UIWindow
{
    
}

/**
 *  快速创建语音聊天界面
 *
 *  @param username 对方用户名
 *
 *  @return 
 */
+ (VoiceChatView *)voiceChatViewWithUsername:(NSString *)username Passivity:(BOOL)passivity Ipaddress:(NSString *)address Port:(NSInteger)port;

/**
 *  设置当前语音状态
 *
 *  @param state
 */
- (void)setVoiceState:(VoiceType)type;

/**
 *  设置语音信息
 *
 *  @param data
 */
- (void)setVoiceData:(NSDictionary *)data;
@end
