//
//  VoiceChatView.m
//  Chat
//
//  Created by 货道网 on 15/6/1.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import "VoiceChatView.h"
#import "AudioSocket.h"
#import <AVFoundation/AVFoundation.h>

@interface VoiceChatView ()
{
    UILabel * _stateLabel;
    UIButton * _closeBtn;
    UIView * _bottomView;
    
    BOOL isClose;
    BOOL isPassivity;
    BOOL isConnect;
    BOOL isInput;
    
    AudioSocket * _audioSocket;

    NSString * _ipaddress;
    NSInteger _port;
}

@property (nonatomic, strong) UIImageView * backgroundImageView;
@property (nonatomic, copy) NSString * username;

@end

/**
 *  语音聊天界面
 */
@implementation VoiceChatView


/**
 *  快速创建语音聊天界面
 *
 *  @param username 对方用户名
 *
 *  @return
 */
+ (VoiceChatView *)voiceChatViewWithUsername:(NSString *)username Passivity:(BOOL)passivity Ipaddress:(NSString *)address Port:(NSInteger)port
{
    VoiceChatView * vc = [[VoiceChatView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0) Username:username Passivity:passivity Ipaddress:address Port:port];

    CGRect frame = vc.frame;
    frame.size.height = 120;
    [UIView animateWithDuration:0.5 animations:^{
        vc.frame = frame;
    }];
    return vc;
}

/**
 *  设置当前语音状态
 *
 *  @param state
 */
- (void)setVoiceState:(VoiceType)type
{
    if (isPassivity) {
        

        switch (type) {
            case VoiceState_Connecting:
                _stateLabel.text = [self.username stringByAppendingString:@"请求通话"];
                break;
            case VoiceState_Connect:
                _stateLabel.text = [@"正在与" stringByAppendingFormat:@"%@通话中",self.username];
                break;
            case VoiceState_Disconnect:
                _stateLabel.text = [@"与" stringByAppendingFormat:@"%@通话不稳定",self.username];
                break;
            
            default:
                break;
        }
        
    } else {
        switch (type) {
            case VoiceState_Connecting:
                _stateLabel.text = [@"请求与" stringByAppendingFormat:@"%@通话",self.username];
                break;
            case VoiceState_Connect:
                
                _stateLabel.text = [@"正在与" stringByAppendingFormat:@"%@通话中",self.username];
                break;
            case VoiceState_Disconnect:
                _stateLabel.text = [@"与" stringByAppendingFormat:@"%@通话不稳定",self.username];
                break;
            case VoiceState_OtherOffline:
                _stateLabel.text = [self.username stringByAppendingString:@"不在线"];
                break;
            case VoiceState_OtherRefused:
                _stateLabel.text = [self.username stringByAppendingString:@"拒绝通话"];
                break;
            case VoiceState_Calling:
                _stateLabel.text = [self.username stringByAppendingString:@"通话中"];
                break;
            default:
                break;
        }
    }
    
    if (type == VoiceState_Connect) {
        isConnect = YES;
        [[MQChatManager sharedInstance] beginRealTimeVoice:^(NSData *audio) {
            if (!isInput) {
                [_audioSocket writeData:audio];
            }
            
        }];
    }
    
}

/**
 *  设置语音信息
 *
 *  @param data
 */
- (void)setVoiceData:(NSDictionary *)data
{
    NSInteger type = [[data objectForKey:@"type"] integerValue];
    [self setVoiceState:type];
    
    if (type == VoiceState_Disconnect || type == VoiceState_OtherOffline || type == VoiceState_OtherRefused || type == VoiceState_Calling) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[MQChatManager sharedInstance] endVoiceChat];
        });
    }
    
}

- (id)initWithFrame:(CGRect)frame Username:(NSString *)username Passivity:(BOOL)passivity Ipaddress:(NSString *)address Port:(NSInteger)port;
{
    self = [super initWithFrame:frame];
    if (self) {
        self.hidden = NO;
        self.windowLevel = UIWindowLevelStatusBar + 1.0f;
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
        
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 20, frame.size.width, 20)];
        _bottomView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.4];
        [self addSubview:_bottomView];
        
        UIImageView * dragImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chat_voice_drag"]];
        dragImageView.frame = CGRectMake((frame.size.width - 23) / 2.0, (20 - 8) / 2.0, 23, 8);
        [_bottomView addSubview:dragImageView];
        
        UIButton * btn = nil;
        if (!passivity) {
            btn = [self defultButton:[UIImage imageNamed:@"AV_red_normal"]
                          PressImage:[UIImage imageNamed:@"AV_red_pressed"]
                         SelectImage:nil
                              Method:@selector(btnClick:)
                               Frame:CGRectMake((frame.size.width - 82) / 2.0f, 120 - 25 - 30, 82, 30)];
        } else {
            btn = [self defultButton:[UIImage imageNamed:@"AV_red_normal"]
                          PressImage:[UIImage imageNamed:@"AV_red_pressed"]
                         SelectImage:nil
                              Method:@selector(btnClick:)
                               Frame:CGRectMake((frame.size.width - 82) / 2.0f - 82 / 2 - 5, 120 - 25 - 30, 82, 30)];
        }
        
        btn.tag = 1;
        [self addSubview:btn];
        
        btn = [self defultButton:[UIImage imageNamed:@"AV_speaker_normal"]
                      PressImage:[UIImage imageNamed:@"AV_speaker_pressed"]
                     SelectImage:[UIImage imageNamed:@"AV_speaker_active"]
                          Method:@selector(btnClick:)
                           Frame:CGRectMake(20, 120 - 25 - 25, 20, 20)];
        btn.tag = 2;
        [self addSubview:btn];
        
        btn = [self defultButton:[UIImage imageNamed:@"AV_speaker_normal"]
                      PressImage:[UIImage imageNamed:@"AV_speaker_pressed"]
                     SelectImage:[UIImage imageNamed:@"AV_speaker_active"]
                          Method:@selector(btnClick:)
                           Frame:CGRectMake(20, 120 - 25 - 25, 20, 20)];
        btn.tag = 3;
        [self addSubview:btn];
        
        btn = [self defultButton:[UIImage imageNamed:@"AV_mic_normal"]
                      PressImage:[UIImage imageNamed:@"AV_mic_pressed"]
                     SelectImage:[UIImage imageNamed:@"AV_mic_active"]
                          Method:@selector(btnClick:)
                           Frame:CGRectMake(frame.size.width - 20 * 2, 120 - 25 - 25, 22, 25)];
        btn.tag = 4;
        [self addSubview:btn];
        
        if (passivity) {
            btn = [self defultButton:[UIImage imageNamed:@"AV_audioaccept_normal"]
                          PressImage:[UIImage imageNamed:@"AV_audioaccept_pressed"]
                         SelectImage:[UIImage imageNamed:@"AV_audioaccept_disable"]
                              Method:@selector(btnClick:)
                               Frame:CGRectMake((frame.size.width - 82) / 2.0f + 82 / 2 + 5, 120 - 25 - 30, 82, 30)];
            btn.tag = 5;
            [self addSubview:btn];
        }
        
        
        _stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 35, frame.size.width, 20)];
        _stateLabel.textColor = [UIColor whiteColor];
        _stateLabel.font = [UIFont systemFontOfSize:15];
        _stateLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_stateLabel];
        
        self.username = username;
        
        isPassivity = passivity;
        _ipaddress = address;
        _port = port;
        
         __weak typeof(self) weakSelf = self;
        _audioSocket = [[AudioSocket alloc] init];
        [_audioSocket setConnectStatusChange:^(AudioSocketConnectStatus status) {
            if (status == AudioSocketConnectStatus_Connect) {
                [weakSelf setVoiceState:VoiceState_Connect];
            } else {
                [weakSelf setVoiceState:VoiceState_Disconnect];
            }
        }];
        [_audioSocket setReceiveData:^(NSData *data) {
            [[MQChatManager sharedInstance] playeRealTimeVoiceData:data];
        }];
        if (!passivity) {
            NSInteger _port1 = [_audioSocket bindServerPort];
            [self setVoiceState:VoiceState_Connecting];
            [MQChatManager asyncSendVoiceChatDataWithdictionary:@{@"action" : [NSNumber numberWithInt:15], @"to" : self.username,@"from" : [MQChatManager sharedInstance].username, @"type" : [NSNumber numberWithInt:VoiceState_Connecting], @"port" : [NSNumber numberWithInteger:_port1]}];
        }
        
    }
    return self;
}
/**
 *  快速创建默认的 Button
 *
 *  @param image       默认Image
 *  @param pressImage  按下Image
 *  @param selectImage 选中Image
 *  @param method      触发方法
 *  @param frame
 *
 *  @return <#return value description#>
 */
- (UIButton *) defultButton:(UIImage *)image PressImage:(UIImage *)pressImage SelectImage:(UIImage *)selectImage Method:(SEL)method Frame:(CGRect)frame
{
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:image forState:UIControlStateNormal];
    [btn setImage:pressImage forState:UIControlStateHighlighted];
    [btn setImage:selectImage forState:UIControlStateSelected];
    [btn addTarget:self action:method forControlEvents:UIControlEventTouchUpInside];
    btn.frame = frame;
    return btn;
}

- (void)btnClick:(UIButton *)sender
{
    switch (sender.tag) {
        case 1:
            if (isPassivity && !isConnect) {
                [MQChatManager asyncSendVoiceChatDataWithdictionary:@{@"action" : [NSNumber numberWithInt:15], @"to" : self.username,@"from" : [MQChatManager sharedInstance].username, @"type" : [NSNumber numberWithInt:VoiceState_OtherRefused]}];
            } else {
                [MQChatManager asyncSendVoiceChatDataWithdictionary:@{@"action" : [NSNumber numberWithInt:15], @"to" : self.username,@"from" : [MQChatManager sharedInstance].username, @"type" : [NSNumber numberWithInt:VoiceState_Disconnect]}];
            }
            
            [[MQChatManager sharedInstance] endVoiceChat];
            break;
        case 2:
            break;
        case 3:
            sender.selected = !sender.selected;
            [MQChatManager sharedInstance].audioController.voiceProcessingEnabled = sender.selected;
            break;
        case 4:
            sender.selected = !sender.selected;
            isInput = sender.selected;
            break;
        case 5:
        {
            [_audioSocket connectionIpaddress:_ipaddress Port:_port];
            [self hideConnectBtn];
        }
            break;
        default:
            break;
    }
}

- (void)hideConnectBtn
{
    UIButton * btn = (UIButton *)[self viewWithTag:1];
    UIButton * btn1 = (UIButton *)[self viewWithTag:5];
    [UIView animateWithDuration:0.15 animations:^{
        btn1.alpha = 0;
        btn.frame = CGRectMake((self.frame.size.width - 82) / 2.0f, 120 - 25 - 30, 82, 30);
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _bottomView.frame = CGRectMake(0, self.frame.size.height - 20, self.frame.size.width, 20);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (CGRectContainsPoint(_bottomView.frame, point)) {
        CGRect frame = self.frame;
        frame.size.height = isClose ? 120 : 20;
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.frame = frame;
                             _bottomView.frame = CGRectMake(0, self.frame.size.height - 20, self.frame.size.width, 20);
                         }];
        isClose = !isClose;
    }
}

- (void)dealloc {
    [MQChatManager sharedInstance].audioController.voiceProcessingEnabled = NO;
    [[MQChatManager sharedInstance] endVoiceChat];
    [_audioSocket disconnection];
}


@end
