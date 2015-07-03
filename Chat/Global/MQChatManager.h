//
//  ChatManager.h
//  Chat
//
//  Created by 货道网 on 15/5/9.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <AEAudioController.h>
#import "MQChatUtil.h"

#import "Session.h"
#import "Message.h"

#import "NSArray+Ext.h"

#import "VoiceChatView.h"

#define RECORD_PATH ([NSTemporaryDirectory() stringByAppendingPathComponent:@"tmpRecord.wav"]) // 录音保存临时文件

typedef enum : NSUInteger {
    Application_Active,
    Application_Background,
} ApplicationStaus;

typedef enum : NSUInteger {
    
    LogOutDescriptionStatus_UserLogOut = 0, // 用户退出
    LogOutDescriptionStatus_OtherDeviceLogin = 1, // 账号在其他地方登录
    
}LogOutDescriptionStatus;

@interface MQChatManager : NSObject
{
    NSMutableArray * _delegates;
}

// MARK: - 用户属性
@property (nonatomic, readonly) NSString * username;
@property (nonatomic, readonly) NSString * password;
@property (nonatomic, readonly) NSString * userid;

// MARK: - CoreData属性
@property (weak, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (weak, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, weak, readonly) Session * currentSession;   // 当前聊天会话对象
@property (nonatomic, assign, readonly) BOOL isLogin;
@property (nonatomic, assign, readonly) AFNetworkReachabilityStatus netwokStatus; // 网络状态
@property (nonatomic, assign) ApplicationStaus applicationStaus; // app 状态
@property (nonatomic, strong) AEAudioController * audioController;

+ (MQChatManager *)sharedInstance;


// MARK: - 服务器管理

/**
 *  连接聊天服务器
 */
- (void)connectionChatServer;

/**
 *  是否连接服务器
 */
- (BOOL)isConnection;

/**
 * 是否登录服务器
 */
- (BOOL)isLogin;

/**
 *  登录聊天服务器
 *
 *  @param username    用户名
 *  @param password    密码
 *  @param complection 登录完成回调
 *  @param isAutoReconnection 是否自动断线重连
 */
- (void)loginWithUsername:(NSString *)username Password:(NSString *)password Completion:(void (^) (NSError * result))complection AutoReconnection:(BOOL)isAutoReconnection;


/**
 *  注册账号到聊天服务器
 *
 *  @param username    用户名
 *  @param password    密码
 *  @param complection 完成回调block
 */
- (void)regeisterWithUsername:(NSString *)username Password:(NSString *)password Completion:(void (^) (NSError * result))complection;

/**
 *  退出登录
 *
 *  @param complection 完成回调block
 */
- (void)logOutComplection:(void (^) (NSError * result))complection;

// MARK: - 聊天管理

/**
 *  清空当前聊天对象
 */
- (void)nullCurrentSession;

/**
 *  请求聊天记录
 *
 *  @param username    请求与谁的聊天记录
 *  @param complection 完成回调block
 */
- (void)obtainServerChatRecordWithUsername:(NSString *)username Completion:(void (^) (NSError * result))complection;
/**
 *  删除一条信息
 *
 *  @param message        信息
 *  @param isRemoveServer 是否删除服务器的
 */
- (void)removeMessage:(Message *)message IsRemoveServer:(BOOL)isRemoveServer;
/**
 *  清空会话聊天记录
 *
 *  @param session       会话
 *  @param isClearServer 是否删除会话
 */
- (void)clearSession:(Session *)session IsClearServer:(BOOL)isClearServer;

// MARK: - 聊天代理
/**
 *  添加聊天代理
 *
 *  @param delegate 代理对象
 */
- (void)addDelegate:(id)delegate;

/**
 *  删除代理对象
 *
 *  @param delegate 代理对象
 */
- (void)removeDelegate:(id)delegate;

// MARK: - 音频控制
/**
 *  开始录制音频
 *
 *  @param recordTime 录制时间
 *  @param level 录音音量登记
 */
- (void)beginRecordVoice:(void (^)(int time))recordTime RecordLevel:(void (^)(float level))recordLevel;
/**
 *  停止录制声音
 *
 *  @param recordData 声音数据 已经转码成Amr格式
 */
- (void)endRecordVoice:(void (^)(NSData *soure))recordData;

/**
 *  播放音频来自 data
 *
 *  @param voiceData 音频数据
 *  @param block 完成播放调用
 */
- (void)playerVoiceFormData:(NSData *)voiceData FinishPlay:(void(^)())block;

/**
 *  播放音频来自 data
 *
 *  @param voiceData 音频数据
 *  @param block 完成播放调用
 *  @param progress 播放进度
 */
- (void)playerVoiceFormData:(NSData *)voiceData  FinishPlay:(void(^)())block Progress:(void (^) (CGFloat progress, CGFloat time, CGFloat maxTime))progress;

/**
 *  播放音频来自 本地文件
 *
 *  @param voicePath 音频文件路径
 *  @param block 完成播放调用
 */
- (void)playerVoiceFormPath:(NSString *)voicePath  FinishPlay:(void(^)())block;
/**
 *  播放音频来自 本地文件
 *
 *  @param voicePath 音频文件路径
 *  @param block 完成播放调用
 *  @param progress 播放进度
 */
- (void)playerVoiceFormPath:(NSString *)voicePath  FinishPlay:(void(^)())block Progress:(void (^) (CGFloat progress, CGFloat time, CGFloat maxTime))progress;

/**
 *  停止播放音频
 */
- (void)stopPlayerVoice;

/**
 *  开始语音聊天
 *
 *  @param username 用户名
 */
- (void)beginVoiceChatUsername:(NSString *)username;
/**
 *  设置语音信息
 *
 *  @param state
 */
- (void)setVoiceData:(NSDictionary *)dict;
/**
 *  结束语音聊天
 */
- (void)endVoiceChat;

/**
 *  开启实时语音
 *
 *  @param block 采集到的音频数据
 */
- (void)beginRealTimeVoice:(void (^) (NSData *))block;
/**
 *  结束实时语音
 */
- (void)endRealTimeVoice;

/**
 *  播放接受到的实时语音数据
 *
 *  @param data 语音数据
 */
- (void)playeRealTimeVoiceData:(NSData *)data;

// MARK: - 会话管理

/**
 *  根据用户名查找session 如果没有找到则新建
 *
 *  @param username  用户名
 *  @param isDefault 是否设为默认的聊天session
 *
 *  @return session
 */
+ (Session *)sessionForUserName:(NSString *)username Default:(BOOL)isDefault;

/**
 *  插入时间到一个信息数组
 *
 *  @param messages 信息数组
 *  @param lastDate 获取最后一次时间
 *
 *  @return 返回插入时间之后的数组
 */
+ (NSArray *)inserTimeToMessages:(NSArray *)messages LastDate:(NSDate **)lastDate;

/**
 *  根据对方用户名生成一个唯一的sessionID
 *
 *  @param username 对方用户名
 *
 *  @return sessionId
 */
+ (NSString *)sessionIdForUserName:(NSString *)username;

/**
 *  获取所有会话的未读信息数量
 *
 *  @return
 */
+ (NSInteger)getAllSessionUnreadCount;

// MARK: - 信息发送
/**
 *  异步发送信息
 *
 *  @param message 信息对象
 */
+ (void)asyncSendMessage:(Message *)message;
/**
 *  异步重新发送信息
 *
 *  @param message 信息
 */
+ (void)asyncAgainSendMessage:(Message *)message;

/**
 *  发送语音聊天数据
 *
 *  @param data
 */
+ (void)asyncSendVoiceChatDataWithdictionary:(NSDictionary *)dictionary;

@end


@protocol ChatManagerDelegate <NSObject>

@optional

/**
 *  分发接受到聊天信息
 *
 *  @param manager 聊天管理
 *  @param message 聊天信息
 */
- (void)chatManager:(MQChatManager *)manager ReceiveMessage:(Message *)message;

/**
 *  分发接受到的离线消息
 *
 *  @param manager  聊天管理
 *  @param messages 离线消息数组
 */
- (void)chatManager:(MQChatManager *)manager ReceiveOfflineMessages:(NSArray *)messages;

/**
 *  分发将要接受信息 在这个代理方法可以处理接受信息前需要处理的数据 比如添加时间
 *
 *  @param manager 聊天管理
 *  @param session 将要接受信息的session
 */
- (void)chatManager:(MQChatManager *)manager WillReceiveMessageSession:(Session *)session;

/**
 *  分发网络状态改变
 *
 *  @param manager 聊天管理
 *  @param status  网络状态
 */
- (void)chatManager:(MQChatManager *)manager NetworkChangeState:(AFNetworkReachabilityStatus)status;

/**
 *  分发发送的聊天信息 无论成功与否都会走此方法 根据message.state 判断是否发送成功
 *
 *  @param manager 聊天管理
 *  @param message 聊天信息
 */
- (void)chatManager:(MQChatManager *)manager SendMessage:(Message *)message;

/**
 *  分发用户退出
 *
 *  @param manager 聊天管理
 *  @param status  退出类型
 */
- (void)chatManager:(MQChatManager *)manager LogOutDescriptionStatus:(LogOutDescriptionStatus)status;

@end


