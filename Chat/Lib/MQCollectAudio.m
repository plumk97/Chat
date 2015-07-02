//
//  MyCollectAudio.m
//  RealTimeVoice
//
//  Created by 货道网 on 15/5/29.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import "MQCollectAudio.h"
#import <MQEncodeAudio.h>

#define PCM_FRAME_SIZE 320
@interface MQCollectAudio ()
{
    AudioStreamBasicDescription  description;
    BOOL isReceiver;
    
    CFMutableDataRef audioMutableDataRef;
    
    NSTimer * _timer;
}
@property (nonatomic, strong) AEAudioController * audioController;
@property (nonatomic, strong) AEBlockAudioReceiver * blockAudioReceiver;
@property (nonatomic, copy) void (^receiverAudioBlock) (NSData *);

@end

@implementation MQCollectAudio

- (id)initWithAudioController:(AEAudioController *)audioController
{
    self = [super init];
    if (self) {
        self.audioController = audioController;
        audioMutableDataRef = CFDataCreateMutable(kCFAllocatorDefault, 0);
    }
    return self;
}

/**
 *  开始实时采集音频数据
 *
 *  @param block 返回转码之后的音频数据 转码后的数据为 AMR 格式
 */
- (void)beganCollectAudio:(void (^)(NSData *))block AudioBufferList:(void (^)(AudioBufferList *,const AudioTimeStamp *time))buffer
{
    
    self.blockAudioReceiver = [AEBlockAudioReceiver audioReceiverWithBlock:^(void *source, const AudioTimeStamp *time, UInt32 frames, AudioBufferList *audio) {
        if (buffer) {
            buffer(audio, time);
        }
        CFDataAppendBytes(audioMutableDataRef, audio->mBuffers->mData, audio->mBuffers->mDataByteSize);
    }];
    [self.audioController addInputReceiver:self.blockAudioReceiver];
    self.receiverAudioBlock = block;
    isReceiver = YES;
    
    [_timer invalidate];
    _timer = nil;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 / 30.0f target:self selector:@selector(encodeAudioThread) userInfo:nil repeats:YES];
    
}

/**
 *  转码线程 转成 AMR 音频数据
 */
- (void)encodeAudioThread
{
    
    [self encodeAudioIsTail:NO];
    
}

/**
 *  转码方法
 *
 *  @param isTail 是否结尾 如果是结尾就不以采样率长度来算
 */
- (void)encodeAudioIsTail:(BOOL)isTail
{
    CFIndex length = CFDataGetLength(audioMutableDataRef);
    
    // 这里的数字代表了音质 越大越好 越大发送就越慢 因为要等待数据量够才能发。。。
    if (!(length >= PCM_FRAME_SIZE * 10) && !isTail) {
        return;
    }
    CFRange range = CFRangeMake(0, length);
    UInt8 * buffer;
    buffer = calloc(length, sizeof(UInt8));
    CFDataGetBytes(audioMutableDataRef, range, buffer);
    NSData * subData = [NSData dataWithBytes:buffer length:length];
    
    subData = [MQEncodeAudio convertWavToAmr:subData];
    if (self.receiverAudioBlock) {
        self.receiverAudioBlock (subData);
    }
    
    CFDataDeleteBytes(audioMutableDataRef, range);
    free(buffer);
}

/**
 *  结束实时采集音频数据
 */
- (void)endCollectAudio
{
    [_timer invalidate];
    _timer = nil;
    [self encodeAudioIsTail:YES];
    CFDataDeleteBytes(audioMutableDataRef, CFRangeMake(0, CFDataGetLength(audioMutableDataRef)));
    isReceiver = NO;
    [self.audioController removeInputReceiver:self.blockAudioReceiver];
}

@end

