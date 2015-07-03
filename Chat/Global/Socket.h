//
//  Socket.h
//  Chat
//
//  Created by 货道网 on 15/5/6.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"
#import "Datagram.h"

/**
 请求服务器的action
 */
typedef enum : NSUInteger {
    Action_Regeister = 9, // 注册
    Action_Login = 10, // 登录
    Action_SendMessage = 11, // 发送消息
    Action_ReceiveMessage = 12, // 接受信息
    Action_LogMessage = 13, // 获取聊天记录
    Action_OfflineMessage = 14, // 离线消息
    Action_VoiceChat = 15, // 语音聊天的一系列操作
    Action_RemoveMessage = 16, // 删除一条信息
    Action_ClearSessionMessage = 17, // 清空会话信息
    Action_LogOut = 18, // 退出登录
    Action_OtherDeviceLogin = 19, // 其他设备登录
} Action;

/**
 *  多播代理
 *  因为数组添加成员会使对象引用计数加1从而无法释放
 */
@interface MulticastDelegate : NSObject

@property (nonatomic, assign) id delegate;

@end

@interface Socket : NSObject
<AsyncSocketDelegate>
{
    AsyncSocket * _socket;
    NSMutableArray * _delegates; // 所有代理
    NSInteger currentSendTag; // 当前发送tag
    NSMutableDictionary * currentSendDict; // 发送缓存字典 发送成功 或 失败 删除缓存数据
}



// MARK: - 实例方法

/**
 *  连接socket服务器
 *
 *  @param address 地址
 *  @param port    端口
 *  @param isAuto  是否自动重连
 */
- (void)connectionToIpaddress:(NSString *)address Port:(NSInteger)port isAutoConnection:(BOOL)isAuto;

/**
 * 是否连接服务器
 */
- (BOOL)isConnection;

/**
 *  发送请求到服务器
 *
 *  @param action    请求方法
 *  @param parameter 参数
 */
- (void)sendAction:(Action)action Parameter:(NSDictionary *)parameter;
- (void)sendDataWithDictionary:(NSDictionary *)dictionary;

/**
 *  添加接受和发送数据代理
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

@end


@protocol SocketDelegate <NSObject>

@optional
/**
 *  接受数据代理方法
 *
 *  @param sock 当前socket连接对象
 *  @param dict 返回数据 以字典形式接受
 */
- (void)socket:(Socket *)sock ReceiveData:(NSDictionary *)dict Action:(Action)action;


/**
 *  发送数据代理方法
 *
 *  @param sock      当前socket连接对象
 *  @param dict      发送的数据
 *  @param isSucceed 是否发送成功
 */
- (void)socket:(Socket *)sock SendData:(NSDictionary *)dict Succeed:(BOOL)isSucceed Action:(Action)action;

/**
 *  与服务器断开连接
 *
 *  @param sock 当前socket对象
 */
- (void)socketDisconnection:(Socket *)sock;

/**
 *  连接服务器
 *
 *  @param sock 当前socket对象
 */
- (void)socketConnection:(Socket *)sock;

@end



