//
//  Datagram.h
//  Chat
//
//  Created by 货道网 on 15/5/5.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 对发送数据进行编码 以处理 粘包情况
 * 本类提供两个类方法 一个封包 一个解包
 */
@interface Datagram : NSObject

+ (NSData *)codingDictonary:(NSDictionary *)dict;

+ (NSDictionary *)decodingData:(NSData *)data;



@end
