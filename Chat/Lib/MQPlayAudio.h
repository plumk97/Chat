//
//  MQPlayeAudio.h
//  RealTimeVoice
//
//  Created by 货道网 on 15/5/30.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TheAmazingAudioEngine.h>
@interface MQPlayAudio : NSObject

/**
 *  初始化播放器
 *
 *  @param audioController 音频控制器
 *
 *  @return
 */
- (id)initWithAudioController:(AEAudioController *)audioController;

/**
 *  开始播放音频
 */
- (void)beginPlayAudio;
/**
 *  添加音频数据
 *
 *  @param data 音频数据
 */
- (void)addAudioData:(NSData *)data;
/**
 *  结束播放音频
 */
- (void)endPlayAudio;

@end
