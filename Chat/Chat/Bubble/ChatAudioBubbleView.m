 //
//  ChatAudioBubbleView.m
//  Chat
//
//  Created by 货道网 on 15/5/28.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import "ChatAudioBubbleView.h"
#import "MQEncodeAudio.h"

@interface ChatAudioBubbleView ()
{
    UILabel * _timeLabel;
    
    NSArray * _senderAnimation;
    NSArray * _receiveAnimation;

    UIImageView * _audioImageView;
}
@end

@implementation ChatAudioBubbleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:_timeLabel];
        
        _senderAnimation = @[[UIImage imageNamed:@"voice_send_icon_1"],
                             [UIImage imageNamed:@"voice_send_icon_2"],
                             [UIImage imageNamed:@"voice_send_icon_3"]];
        
        _receiveAnimation = @[[UIImage imageNamed:@"voice_receive_icon_1"],
                             [UIImage imageNamed:@"voice_receive_icon_2"],
                             [UIImage imageNamed:@"voice_receive_icon_3"]];
        _audioImageView = [[UIImageView alloc] init];
        _audioImageView.animationDuration = 0.5;
        [self addSubview:_audioImageView];
        
        // 监听是否播放属性改变
        [self addObserver:self forKeyPath:@"message.isPlaying" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (self.message.isPlaying) {
        [_audioImageView startAnimating];
    } else {
        [_audioImageView stopAnimating];
    }
}

- (void)setMessage:(Message *)message
{
    [super setMessage:message];
    _timeLabel.text = [[NSString stringWithFormat:@"%d",[message.audioPlayTime intValue]] stringByAppendingString:@"\""];
    if ([self.message.isSender boolValue]) {
        _audioImageView.image = [UIImage imageNamed:@"voice_send_icon_nor"];
        _audioImageView.animationImages = _senderAnimation;
    } else {
        _audioImageView.image = [UIImage imageNamed:@"voice_receive_icon_nor"];
        _audioImageView.animationImages = _receiveAnimation;
    }
    if (self.message.isPlaying) {
        [_audioImageView startAnimating];
    } else {
        [_audioImageView stopAnimating];
    }
    [self downloadAudio];
}

/**
 *  下载音频
 */
- (void)downloadAudio
{
    // 判断本地是否已经有了这个音频文件
    NSFileManager * fm = [NSFileManager defaultManager];
    
    BOOL isEx = [fm fileExistsAtPath:[MQChatUtil createFileNameToLocalPath:[MQChatUtil createFileName:self.message.time Suffix:@"wav"] Directory:DIRECTORY_RECORD]];
    if (isEx) {
        return;
    }
    
    NSString * path = [[NSString alloc] initWithFormat:@"%@%@",RQHost,self.message.audioRemotePath];
    
    __weak typeof(self) weakSelf = self;
    AFHTTPRequestOperationManager * om = [[AFHTTPRequestOperationManager alloc] init];
    AFHTTPRequestOperation * oper = [om GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{

                
                NSData * data = [[NSData alloc] initWithData:responseObject];
                data = [MQEncodeAudio convertAmrToWavFile:data];
                
                weakSelf.message.audioLocationPath = [MQChatUtil saveDataToLocationFileName:[MQChatUtil createFileName:weakSelf.message.time Suffix:@"wav"] Directory:DIRECTORY_RECORD Data:data];
                [[MQChatManager sharedInstance].managedObjectContext save:nil];
            });
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
    oper.responseSerializer = [AFCompoundResponseSerializer serializer];
    [oper start];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = CGRectMake(INTERVAL_BUBBLE_WIDTH + 10, 0, self.bounds.size.height, self.bounds.size.height);
    if ([self.message.isSender boolValue]) {
        _timeLabel.frame = frame;
        _audioImageView.frame = CGRectMake(self.bounds.size.width - INTERVAL_BUBBLE_WIDTH * 2 - 20, (self.bounds.size.height - 20) / 2.0f, 20, 20);
    } else {
        _timeLabel.textColor = [UIColor blackColor];
        frame.origin.x = self.bounds.size.width - INTERVAL_BUBBLE_WIDTH * 3;
        _timeLabel.frame = frame;
        _audioImageView.frame = CGRectMake(INTERVAL_BUBBLE_WIDTH + 10, (self.bounds.size.height - 20) / 2.0f, 20, 20);
    }
    
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGFloat width = 100 + [self.message.audioPlayTime intValue] * 10;
    width = width > 200 ? 200 : width;
    return CGSizeMake(width, 60);
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"message.isPlaying"];
}

+ (CGFloat)heightForMessageModel:(Message *)message
{
    return 60;
}

@end
