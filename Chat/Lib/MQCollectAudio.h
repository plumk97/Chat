//
//  MyCollectAudio.h
//  RealTimeVoice
//
//  Created by 货道网 on 15/5/29.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "TheAmazingAudioEngine.h"
@interface MQCollectAudio : NSObject

/**
 *  初始化音频采集器
 *
 *  @param audioController 音频控制器
 *
 *  @return
 */
- (id)initWithAudioController:(AEAudioController *)audioController;

/**
 *  开始实时采集音频数据
 *
 *  @param block 返回转码之后的音频数据 转码后的数据为 AMR 格式
 *  @param buffer AudioBufferList
 */
- (void)beganCollectAudio:(void (^) (NSData * audio))block AudioBufferList:(void (^) (AudioBufferList *,const AudioTimeStamp *time))buffer;

/**
 *  结束实时采集音频数据
 */
- (void)endCollectAudio;

@end
