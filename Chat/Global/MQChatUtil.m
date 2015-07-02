//
//  MQChatUtil.m
//  Chat
//
//  Created by 货道网 on 15/5/19.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import "MQChatUtil.h"
#import <CommonCrypto/CommonDigest.h>
#import "MQBrowserPhoto.h"


#define LIBRARY_PATH ([NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject])


@interface MQChatUtil ()

@end

@implementation MQChatUtil


+ (MQChatUtil *)sharedInstance
{
    static MQChatUtil * cu = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cu = [[MQChatUtil alloc] init];
    });
    
    
    return cu;
}

/**
 *  保存数据文件到本地
 *
 *  @param fileName  文件名
 *  @param directory 保存目录
 *  @param data      数据
 *
 *  @return 返回保存之后的路径
 */
+ (NSString *)saveDataToLocationFileName:(NSString *)fileName Directory:(NSString *)directory Data:(NSData *)data
{
    NSString * path = [MQChatUtil createFileNameToLocalPath:fileName Directory:directory];
    [data writeToFile:path atomically:YES];
    return path;
}

/**
 *  获取数据来自本地
 *
 *  @param fileName  文件名
 *  @param directory 保存目录
 *
 *  @return 返回获取到的数据
 */
+ (NSData *)getDataFromLocationFileName:(NSString *)fileName Directory:(NSString *)directory
{
    NSString * path = [MQChatUtil createFileNameToLocalPath:[fileName lastPathComponent] Directory:directory];
    NSData * data = [[NSData alloc] initWithContentsOfFile:path];
    return data;
}

/**
 *  复制文件到目的文件夹
 *
 *  @param filePath  复制文件路径
 *  @param fileName  复制后的文件名
 *  @param directory 文件夹
 *
 *  @return 返回复制后的文件路径
 */
+ (NSString *)copyFile:(NSString *)filePath FileName:(NSString *)fileName ToDirectory:(NSString *)directory
{
    NSString * path = [MQChatUtil createFileNameToLocalPath:fileName Directory:directory];
    
    NSFileManager * fm = [NSFileManager defaultManager];
    
    NSError * err;
    [fm copyItemAtPath:filePath toPath:path error:&err];
    if (err) {
        NSLog(@"%@",err);
        return nil;
    }
    return path;
}

/**
 *  生成图片名字
 *
 *  @param name
 *
 *  @return
 */
+ (NSString *)createFileName:(NSString *)name
{
  
    return [name stringByReplacingOccurrencesOfString:@"." withString:@""];
}

/**
 *  生成文件名字
 *
 *  @param name 文件名
 *  @param suffix 后缀
 *
 *  @return
 */
+ (NSString *)createFileName:(NSString *)name Suffix:(NSString *)suffix
{
    return [[MQChatUtil createFileName:name] stringByAppendingString:suffix ? [@"."  stringByAppendingString:suffix]: @""];
}
/**
 *  生成文件本地路径
 *
 *  @param name 文件名
 *  @param directory 文件目录
 *  @return
 */
+ (NSString *)createFileNameToLocalPath:(NSString *)name Directory:(NSString *)directory
{
    return [[MQChatUtil getChatCacheDirectoryName:directory] stringByAppendingPathComponent:name];
}

+ (NSString *)getChatCacheDirectoryName:(NSString *)name
{
    NSFileManager * fm = [NSFileManager defaultManager];
    
    NSString * utilPath = [LIBRARY_PATH stringByAppendingPathComponent:@"MQUTIL"];
    
    BOOL isExists = [fm fileExistsAtPath:utilPath];
    if (!isExists) {
        [fm createDirectoryAtPath:utilPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    utilPath = [utilPath stringByAppendingPathComponent:name];
    
    isExists = [fm fileExistsAtPath:utilPath];
    if (!isExists) {
        [fm createDirectoryAtPath:utilPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return utilPath;
}

/**
 *  生成缩略图大小
 *
 *  @param image 图片
 *
 *  @return size
 */
+ (CGSize)thumbnailSizeWithImage:(UIImage *)image
{
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    
    CGFloat maxValue = MAX(width, height);
    
    if (width > 150) {
        width *= 150 / maxValue;
    }
    if (height > 150) {
        height *= 150 / maxValue;
    }
    width = MAX(width, 100);
    height = MAX(height, 60);
    
    return CGSizeMake((NSInteger)width, (NSInteger)height);
    
    
}

/**
 *  浏览图片
 *
 *  @param photos 传入message数组
 */
- (void)browserPhotos:(NSArray *)photos ShowIndex:(NSInteger)index SuperView:(UIView *)superView OriginFrame:(CGRect)originFrame
{
    MQBrowserPhoto * browser = [[MQBrowserPhoto alloc] initWithPhotos:photos Index:index SuperView:superView OriginFrame:originFrame];
    [[[[UIApplication sharedApplication] delegate] window] addSubview:browser];
}

/**
 *  格式化时间字符串
 *
 *  @param date   时间
 *  @param format 格式字符串
 *
 *  @return 如果格式失败 返回nil
 */
+ (NSString *)formatDate:(NSDate *)date Format:(NSString *)format
{
    if (!date) {
        return nil;
    }
    
    NSTimeZone* GTMzone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDateFormatter * dateF = [[NSDateFormatter alloc] init];
    dateF.timeZone = GTMzone;
    [dateF setDateFormat:format];
    
    return [dateF stringFromDate:date];
    
}


@end
