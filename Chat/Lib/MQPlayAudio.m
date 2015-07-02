//
//  MQPlayeAudio.m
//  RealTimeVoice
//
//  Created by 货道网 on 15/5/30.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import "MQPlayAudio.h"


@interface MQPlayAudio ()
{
    CFMutableDataRef _audioMutableDataRef;
}
@property (nonatomic, strong) AEAudioController * audioController;
@property (nonatomic, strong) AEBlockChannel * blockChannel;
@end

@implementation MQPlayAudio


- (id)initWithAudioController:(AEAudioController *)audioController
{
    self = [super init];
    if (self) {
        self.audioController = audioController;
        _audioMutableDataRef = CFDataCreateMutable(kCFAllocatorDefault, 0);
    }
    return self;
}

- (void)beginPlayAudio
{
    self.blockChannel = [AEBlockChannel channelWithBlock:^(const AudioTimeStamp *time, UInt32 frames, AudioBufferList *audio) {
        
        CFIndex length = CFDataGetLength(_audioMutableDataRef);
        
        if (length >= audio->mBuffers->mDataByteSize) {
            
            CFRange range = CFRangeMake(0, audio->mBuffers->mDataByteSize);
            
            UInt8 * buffer;
            buffer = calloc(audio->mBuffers->mDataByteSize, sizeof(UInt8));
            
            CFDataGetBytes(_audioMutableDataRef, range, buffer);
            
            memcpy(audio->mBuffers->mData, buffer, range.length);
            free(buffer);
            CFDataDeleteBytes(_audioMutableDataRef, range);
            
            
        }
    }];
    [self.audioController addChannels:@[self.blockChannel]];
}

- (void)addAudioData:(NSData *)data
{
    CFDataAppendBytes(_audioMutableDataRef, [data bytes], data.length);
}

- (void)endPlayAudio
{
    CFDataDeleteBytes(_audioMutableDataRef, CFRangeMake(0, CFDataGetLength(_audioMutableDataRef)));
    [self.audioController removeChannels:@[self.blockChannel]];
    self.blockChannel = nil;
}




@end
