//
//  Message.h
//  Chat
//
//  Created by 货道网 on 15/5/9.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>



/**
 当前发送信息状态

 MessageSendState_Sending 发送中
 MessageSendState_Succeed 发送成功
 MessageSendState_Fail 失败
 
 */
typedef enum : NSUInteger {
    
    MessageSendState_Sending,
    MessageSendState_Succeed,
    MessageSendState_Fail,
    
} MessageSendState;

typedef enum : NSUInteger {
    MessageType_Text,
    MessageType_Image,
    MessageType_Location,
    MessageType_Audio,
} MessageType;

@class Session;

@interface Message : NSManagedObject

@property (nonatomic, retain) NSString * time;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) Session *session;
@property (nonatomic, retain) NSString * messageId;
@property (nonatomic, retain) NSNumber * state;
@property (nonatomic, retain) NSNumber * isSender;


// 文字属性
@property (nonatomic, retain) NSString * content;


// 图片属性
@property (nonatomic, retain) NSString * localPath; // 图片本地路径
@property (nonatomic, retain) NSString * locationThumbanilImagePath; // 本地缩略图路径
@property (nonatomic, retain) NSString * remotePath; // 图片在服务器上的路径
@property (nonatomic, retain) NSString * thumbnailPath; // 图片缩略图在服务器上的路径
@property (nonatomic, retain) NSNumber * imageWidth; // 图片宽度
@property (nonatomic, retain) NSNumber * imageHeight; // 图片高度
@property (nonatomic, strong) UIImage * image;


// 位置属性
@property (nonatomic, retain) NSString * locationName; // 位置名
@property (nonatomic, retain) NSNumber * latitude; // 纬度
@property (nonatomic, retain) NSNumber * longitude; // 经度

// 音频属性
@property (nonatomic, retain) NSString * audioLocationPath; // 音频本地路径
@property (nonatomic, retain) NSString * audioRemotePath; // 音频在服务器的路径
@property (nonatomic, retain) NSNumber * audioPlayTime; // 音频播放时间
@property (nonatomic, assign) BOOL isPlaying; // 是否播放中


/**
 *  获取默认message
 *
 *  @return message 对象
 */
+ (Message *)defaultMessage;

/**
 *  根据字典生成message对象
 *
 *  @param dict 字典
 *
 *  @return message
 */
+ (Message *)messageWithDict:(NSDictionary *)dict;

/**
 *  根据字典生成message对象
 *
 *  @param dict 字典
 *  @param session 指定那个会话
 *  @return message
 */
+ (Message *)messageWithDict:(NSDictionary *)dict Session:(Session *)session;

/**
 *  转换为字典形式 用于发送数据
 *
 *  @return 字典
 */
- (NSDictionary *)conversionToDictionary;


/**
 *  克隆message 
 *
 *  @return message
 */
- (Message *)clone;

@end
