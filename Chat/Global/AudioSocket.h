//
//  AudioSocket.h
//  AudioSocket
//
//  Created by li on 15/7/1.
//  Copyright (c) 2015年 li. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    AudioSocketConnectStatus_Disconnect,
    AudioSocketConnectStatus_Connect,
} AudioSocketConnectStatus;
@interface AudioSocket : NSObject

@property (nonatomic, assign) AudioSocketConnectStatus status;

/**
 *  开启服务器
 *
 *  @return 返回服务器端口
 */
- (NSInteger)bindServerPort;
/**
 *  连接到服务器
 *
 *  @param ipAddress 服务器地址
 *  @param port      服务器端口
 */
- (void)connectionIpaddress:(NSString *)ipAddress Port:(NSInteger)port;
/**
 *  发送数据
 *
 *  @param data 数据
 */
- (void)writeData:(NSData *)data;
/**
 *  断开连接
 */
- (void)disconnection;
/**
 *  设置连接状态改变block
 *
 *  @param block
 */
- (void)setConnectStatusChange:(void (^)(AudioSocketConnectStatus status))block;
/**
 *  设置接收数据block
 *
 *  @param block
 */
- (void)setReceiveData:(void (^) (NSData * data))block;
@end
