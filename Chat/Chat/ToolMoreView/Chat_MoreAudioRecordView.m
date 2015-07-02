//
//  Chat_MoreAudioRecordView.m
//  Chat
//
//  Created by 货道网 on 15/5/22.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import "Chat_MoreAudioRecordView.h"
#import "MQRingProgressView.h"

#import <AEAudioController.h>
#import <AERecorder.h>

// MARK: - 试听页面
@interface AuditionView : UIView
{
    BOOL isPlaying;
    
    void (^_Sure)();
    
    MQRingProgressView * _ringProgressView;
}

- (id)initWithFrame:(CGRect)frame Sure:(void (^) ())sure;

@end
@implementation AuditionView

- (id)initWithFrame:(CGRect)frame Sure:(void (^)())sure {
    
    self = [super initWithFrame:frame];
    if (self) {
        _Sure = sure;
        
        self.backgroundColor = [UIColor colorWithRed:235 / 255.0 green:236 / 255.0 blue:238 / 255.0 alpha:1];
        
        UIButton * cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [cancelBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        cancelBtn.frame = CGRectMake(0, frame.size.height - 40, frame.size.width / 2.0f - 0.5, 40);
        cancelBtn.backgroundColor = [UIColor whiteColor];
        [cancelBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        cancelBtn.tag = 1;
        [self addSubview:cancelBtn];
        
        UIButton * sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [sureBtn setTitle:@"确认" forState:UIControlStateNormal];
        sureBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [sureBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [sureBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        sureBtn.frame = CGRectMake(frame.size.width / 2.0f + 0.5, frame.size.height - 40, frame.size.width / 2.0f, 40);
        sureBtn.backgroundColor = [UIColor whiteColor];
        [sureBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        sureBtn.tag = 2;
        [self addSubview:sureBtn];
        
        UIView * playView = [[UIView alloc] initWithFrame:CGRectMake((frame.size.width - 100) / 2.0f, (frame.size.height - 100) / 2.0f - 10, 100, 100)];
        playView.backgroundColor = [UIColor whiteColor];
        playView.layer.cornerRadius = playView.frame.size.width / 2.0f;
        [self addSubview:playView];
        
        UIButton * playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [playBtn setImage:[UIImage imageNamed:@"aio_record_play_nor"] forState:UIControlStateNormal];
        [playBtn setImage:[UIImage imageNamed:@"aio_record_stop_nor"] forState:UIControlStateSelected];
        playBtn.frame = CGRectMake((frame.size.width - 50) / 2.0f, (frame.size.height - 50) / 2.0f  - 10, 50, 50);
        [playBtn addTarget:self action:@selector(playClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:playBtn];
        
        _ringProgressView = [[MQRingProgressView alloc] initWithFrame:CGRectMake((frame.size.width - 105) / 2.0f, (frame.size.height - 105) / 2.0f - 10, 105, 105)];
        _ringProgressView.startAngle = 270;
        _ringProgressView.lineWidth = 2.0f;
        _ringProgressView.progressColor = [UIColor colorWithRed:24 / 255.0 green:167 / 255.0 blue:220 / 255.0 alpha:1];
        [self addSubview:_ringProgressView];
    }
    return self;
}

- (void)playClick:(UIButton *)sender
{
    if (isPlaying) {
        return;
    }
    isPlaying = YES;
    
    __block typeof(self) weakSelf = self;
    [[MQChatManager sharedInstance] playerVoiceFormPath:RECORD_PATH FinishPlay:^{
        sender.selected = NO;
        weakSelf->isPlaying = NO;
    } Progress:^(CGFloat progress, CGFloat time, CGFloat maxTime) {
        static BOOL isFirst = YES;
        if (isFirst) {
            weakSelf->_ringProgressView.progress = 0;
            isFirst = NO;
        } if (progress >= 1) {
            isFirst = YES;
        }
        
        [weakSelf->_ringProgressView setProgress:progress animated:YES];
    }];

    sender.selected = isPlaying;
}
- (void)btnClick:(UIButton *)sender
{
    if (sender.tag == 2) {
        _Sure ();
    }
    
    [self removeFromSuperview];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx, 1);
    CGContextSetRGBStrokeColor(ctx, 0.8, 0.8, 0.8, 1);
    
    CGContextMoveToPoint(ctx, 0, rect.size.height - 40);
    CGContextAddLineToPoint(ctx, rect.size.width, rect.size.height - 40);
    CGContextDrawPath(ctx, kCGPathStroke);
    
    CGContextSetRGBStrokeColor(ctx, 0.8, 0.8, 0.8, 1 / [UIScreen mainScreen].scale / 2.0f);
    CGContextMoveToPoint(ctx, rect.size.width / 2.0f, rect.size.height - 40);
    CGContextAddLineToPoint(ctx, rect.size.width / 2.0f, rect.size.height);
    CGContextDrawPath(ctx, kCGPathStroke);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {};
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {};
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {};

@end


// MARK: - 音量大小显示界面
@interface VolumeImageView : UIImageView
{
    UIImageView * backgroundImageView;
}
@end

@implementation VolumeImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, frame.size.height)];
        backgroundImageView.image = [UIImage imageNamed:@"aio_voice_volume_light"];
        [self addSubview:backgroundImageView];
        backgroundImageView.center = self.center;
        
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        imageView.image = [UIImage imageNamed:@"aio_voice_volume_dot"];
        [self addSubview:imageView];
    }
    return self;
}

- (void)setVolume:(int)value
{
    CGRect boduns = backgroundImageView.bounds;
    boduns.size.width = 60 + value;
    backgroundImageView.bounds = boduns;
    
}


@end

// MARK: - 录音界面
@interface Chat_MoreAudioRecordView ()
{
    UIView * _audioBackgroundView;
    UIView * _audioPlayerView;
    UIView * _cancelRecordView;
    
    UIImageView * _playerIcon;
    UIImageView * _cancelRecordIcon;
    UIImageView * _lineImageView;
    UILabel * _stateLabel;
    
    BOOL isStartRecord;
    CGAffineTransform originTransform;
    
    BOOL isPressPlayer;
    BOOL isPressCancel;
    
    VolumeImageView * volueIcon;
    
    int currentTime;
}

@property (nonatomic, strong) AERecorder * recorder;
@property (nonatomic, copy) void (^recordAudioSucceed) (int);

@end

@implementation Chat_MoreAudioRecordView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        [self initView];
    }
    return self;
}


- (void)initView
{
    
    // 录制按钮
    UIImageView * audioIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 102 * 0.3, 165 * 0.3)];
    audioIcon.frame = CGRectMake((self.frame.size.width - audioIcon.frame.size.width) / 2.0f,
                                 (self.frame.size.height - audioIcon.frame.size.height) / 2.0f + 10,
                                 audioIcon.frame.size.width,
                                 audioIcon.frame.size.height);
    [audioIcon setImage:[UIImage imageNamed:@"aio_voice_button_icon"]];
    [self addSubview:audioIcon];
    
    
    _audioBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    _audioBackgroundView.layer.cornerRadius = _audioBackgroundView.frame.size.width / 2.0f;
    _audioBackgroundView.backgroundColor = [UIColor colorWithRed:24 / 255.0 green:167 / 255.0 blue:220 / 255.0 alpha:1];
    _audioBackgroundView.center = CGPointMake(self.center.x, self.center.y + 10);
    [self addSubview:_audioBackgroundView];
    [self sendSubviewToBack:_audioBackgroundView];
    
    // line
    
    _lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - 100, 20)];
    _lineImageView.image = [UIImage imageNamed:@"aio_voice_line"];
    _lineImageView.center = self.center;
    _lineImageView.alpha = 0;
    [self addSubview:_lineImageView];
    [self sendSubviewToBack:_lineImageView];
    

    
    _audioPlayerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    _audioPlayerView.layer.cornerRadius = _audioPlayerView.frame.size.width / 2.0f;
    _audioPlayerView.center = CGPointMake(self.center.x - 120, self.center.y - 14);
    _audioPlayerView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_audioPlayerView];
    _audioPlayerView.alpha = 0;
    
    _playerIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 23, 23)];
    _playerIcon.center = _audioPlayerView.center;
    [_playerIcon setImage:[UIImage imageNamed:@"aio_voice_operate_listen_nor"]];
    [_playerIcon setHighlightedImage:[UIImage imageNamed:@"aio_voice_operate_listen_press"]];
    [self addSubview:_playerIcon];
    _playerIcon.alpha = 0;
    
    
    _cancelRecordView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    _cancelRecordView.layer.cornerRadius = _cancelRecordView.frame.size.width / 2.0f;
    _cancelRecordView.center = CGPointMake(self.center.x + 120, self.center.y - 14);
    _cancelRecordView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_cancelRecordView];
    _cancelRecordView.alpha = 0;
    
    
    _cancelRecordIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 23, 23)];
    _cancelRecordIcon.center = _cancelRecordView.center;
    [_cancelRecordIcon setImage:[UIImage imageNamed:@"aio_voice_operate_delete_nor"]];
    [_cancelRecordIcon setHighlightedImage:[UIImage imageNamed:@"aio_voice_operate_delete_press"]];
    [self addSubview:_cancelRecordIcon];
    _cancelRecordIcon.alpha = 0;
    
    originTransform = _cancelRecordView.transform;
    
    volueIcon = [[VolumeImageView alloc] initWithFrame:CGRectMake(0, 0, 450 / 3.0f, 90 / 3.0f)];
    volueIcon.hidden = YES;
    [self addSubview:volueIcon];
    
    _stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.frame.size.width, 20)];
    _stateLabel.backgroundColor = [UIColor clearColor];
    _stateLabel.textAlignment = NSTextAlignmentCenter;
    _stateLabel.text = @"按住说话";
    _stateLabel.font = [UIFont systemFontOfSize:15];
    _stateLabel.textColor = [UIColor grayColor];
    [self addSubview:_stateLabel];
    volueIcon.center = _stateLabel.center;
    
    
    
}


- (void)succeedRecordAudio:(void (^)(int))block
{
    self.recordAudioSucceed = block;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    currentTime = 0;
    if (CGRectContainsPoint(_audioBackgroundView.frame, point)) {
        _audioBackgroundView.backgroundColor = [UIColor colorWithRed:6 / 255.0 green:146 / 255.0 blue:213 / 255.0 alpha:1];
        isStartRecord = YES;
        
        CGAffineTransform originTransForm = _audioPlayerView.transform;
        [UIView animateWithDuration:0.1 animations:^{
            _audioBackgroundView.transform = CGAffineTransformScale(originTransForm, 1.1, 1.1);
            
            _lineImageView.alpha = 1;
            _playerIcon.alpha = 1;
            _audioPlayerView.alpha = 1;
            _cancelRecordIcon.alpha = 1;
            _cancelRecordView.alpha = 1;
            
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                _audioBackgroundView.transform = CGAffineTransformScale(originTransForm, 1, 1);
            }];
        }];  
        
        _stateLabel.text = @"准备中";
        __block typeof(self) weakSelf = self;
        [[MQChatManager sharedInstance] beginRecordVoice:^(int time) {
            weakSelf->currentTime = time;
            [self setRecorderLabelTitleTime:time];
        } RecordLevel:^(float level) {
            [volueIcon setVolume:level];
        }];
        _stateLabel.text = @"0:00";
        volueIcon.hidden = NO;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    CGFloat value = point.x / self.center.x;
    

    
    if (value >= 1) {
        value = MIN(1.5, value);
        _cancelRecordView.transform = CGAffineTransformScale(originTransform, value, value);
        
        if (CGRectContainsPoint(_cancelRecordView.frame, point)) {
            _stateLabel.text = @"松开取消发送";
            _cancelRecordView.backgroundColor = [UIColor lightGrayColor];
            _cancelRecordIcon.highlighted = YES;
            isPressCancel = YES;
            volueIcon.hidden = YES;
        } else {
            [self setRecorderLabelTitleTime:currentTime];
            volueIcon.hidden = NO;
            isPressCancel = NO;
            _cancelRecordIcon.highlighted = NO;
            _cancelRecordView.backgroundColor = [UIColor whiteColor];
        }
        
    } else {
        value = MAX(0.5, value);
        _audioPlayerView.transform = CGAffineTransformScale(originTransform,  1 + (1 - value), 1 + (1 - value));
        
        if (CGRectContainsPoint(_audioPlayerView.frame, point)) {
            _stateLabel.text = @"松开试听";
            isPressPlayer = YES;
            _playerIcon.highlighted = YES;
            _audioPlayerView.backgroundColor = [UIColor lightGrayColor];
            volueIcon.hidden = YES;
        } else {
            [self setRecorderLabelTitleTime:currentTime];
            volueIcon.hidden = NO;
            isPressPlayer = NO;
            _playerIcon.highlighted = NO;
            _audioPlayerView.backgroundColor = [UIColor whiteColor];
        }
    }
    
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if (isStartRecord) {
        _audioBackgroundView.backgroundColor = [UIColor colorWithRed:24 / 255.0 green:167 / 255.0 blue:220 / 255.0 alpha:1];
        isStartRecord = NO;
        volueIcon.hidden = YES;
        
        __block typeof(self) weakSelf = self;
     
        [[MQChatManager sharedInstance] endRecordVoice:^(NSData *soure) {
            if (weakSelf->currentTime < 1) {
                    NSLog(@"录音时间过短");
                return ;
            }
            if (isPressPlayer) {
                
                AuditionView * audition = [[AuditionView alloc] initWithFrame:self.bounds Sure:^{
                    weakSelf.recordAudioSucceed (currentTime);
                }];
                [weakSelf addSubview:audition];
            } else if (!isPressCancel) {
                if (weakSelf.recordAudioSucceed) {
                    weakSelf.recordAudioSucceed(currentTime);
                }
                
            }
        }];
        
    }
    
    _stateLabel.text = @"按住说话";
    isPressPlayer = NO;
    isPressCancel = NO;
    _cancelRecordView.transform = CGAffineTransformScale(originTransform, 1, 1);
    _audioPlayerView.transform = CGAffineTransformScale(originTransform, 1, 1);
    _playerIcon.highlighted = NO;
    _cancelRecordIcon.highlighted = NO;
    _audioPlayerView.backgroundColor = [UIColor whiteColor];
    _cancelRecordView.backgroundColor = [UIColor whiteColor];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         _lineImageView.alpha = 0;
                         _playerIcon.alpha = 0;
                         _audioPlayerView.alpha = 0;
                         _cancelRecordIcon.alpha = 0;
                         _cancelRecordView.alpha = 0;
                     }];
    
}


- (void)setRecorderLabelTitleTime:(int)time
{
    if (isPressPlayer || isPressCancel) {
        return;
    }
    currentTime = time;
    int minute = time / 60;
    time %= 60;
    NSString * title = nil;
    if (time < 10) {
        title = [[NSString alloc] initWithFormat:@"%d:0%d",minute, time];
    } else {
        title = [[NSString alloc] initWithFormat:@"%d:%d",minute, time];
    }
    
    _stateLabel.text = title;
}

@end
