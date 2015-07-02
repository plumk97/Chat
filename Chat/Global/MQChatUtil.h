//
//  MQChatUtil.h
//  Chat
//
//  Created by 货道网 on 15/5/19.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//


#define DIRECTORY_IMAGE @"image"
#define DIRECTORY_RECORD @"record"

#import <Foundation/Foundation.h>

/**
 *  本类提供聊天辅助功能
 */

@interface MQChatUtil : NSObject


+ (MQChatUtil *)sharedInstance;


/**
 *  保存数据文件到本地
 *
 *  @param fileName  文件名
 *  @param directory 保存目录
 *  @param data      数据
 *
 *  @return 返回保存之后的路径
 */
+ (NSString *)saveDataToLocationFileName:(NSString *)fileName Directory:(NSString *)directory Data:(NSData *)data;

/**
 *  获取数据来自本地
 *
 *  @param fileName  文件名
 *  @param directory 保存目录
 *
 *  @return 返回获取到的数据
 */
+ (NSData *)getDataFromLocationFileName:(NSString *)fileName Directory:(NSString *)directory;


/**
 *  复制文件到目的文件夹
 *
 *  @param filePath  复制文件路径
 *  @param fileName  复制后的文件名
 *  @param directory 文件夹
 *
 *  @return 返回复制后的文件路径
 */
+ (NSString *)copyFile:(NSString *)filePath FileName:(NSString *)fileName ToDirectory:(NSString *)directory;


/**
 *  生成文件名字
 *
 *  @param name 文件名
 *
 *  @return
 */
+ (NSString *)createFileName:(NSString *)name;

/**
 *  生成文件名字
 *
 *  @param name 文件名
 *  @param suffix 后缀
 *
 *  @return
 */
+ (NSString *)createFileName:(NSString *)name Suffix:(NSString *)suffix;

/**
 *  生成文件本地路径
 *
 *  @param name 文件名
 *  @param directory 文件目录
 *  @return
 */
+ (NSString *)createFileNameToLocalPath:(NSString *)name Directory:(NSString *)directory;


/**
 *  生成缩略图大小
 *
 *  @param image 图片
 *
 *  @return size
 */
+ (CGSize)thumbnailSizeWithImage:(UIImage *)image;

// MARK: - 实例方法

/**
 *  浏览图片
 *
 *  @param photos 传入message数组
 *  @param index 初始显示位置
 */
- (void)browserPhotos:(NSArray *)photos ShowIndex:(NSInteger)index SuperView:(UIView *)superView OriginFrame:(CGRect)originFrame;

/**
 *  格式化时间字符串
 *
 *  @param date   时间
 *  @param format 格式字符串
 *
 *  @return 如果格式失败 返回nil
 */
+ (NSString *)formatDate:(NSDate *)date Format:(NSString *)format;


@end
