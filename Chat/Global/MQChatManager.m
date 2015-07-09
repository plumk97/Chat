//
//  ChatManager.m
//  Chat
//
//  Created by 货道网 on 15/5/9.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import "MQChatManager.h"
#import "Socket.h"

#import <AVFoundation/AVFoundation.h>

#import <AERecorder.h>
#import "MQEncodeAudio.h"
#import "MQCollectAudio.h"
#import "MQPlayAudio.h"

#import <netinet/in.h>

typedef void (^ComplectionBlock) (NSError *);
@interface MQChatManager ()
<SocketDelegate, AVAudioPlayerDelegate>
{
     NSMutableArray * _timeSessions;
     AVAudioPlayer * _audioPlayer;
     
     BOOL _isRealTimeVoiceing;
     BOOL _isAutoReconnection;
}

@property (nonatomic, strong) AERecorder * recorder;
@property (nonatomic, copy) void (^recorderTime)(int);
@property (nonatomic, copy) void (^recorderLevel)(float);
@property (nonatomic, strong) NSTimer * recorderTimer;
@property (nonatomic, strong) NSTimer * recorderLevelTimer;

@property (nonatomic, copy) void (^playFinish)();

@property (nonatomic, strong) Socket * socket;
@property (nonatomic, copy) ComplectionBlock loginComplectionBlock;
@property (nonatomic, copy) ComplectionBlock registerComplectionBlock;
@property (nonatomic, copy) ComplectionBlock chatRecordComplectionBlock;
@property (nonatomic, copy) ComplectionBlock logOutComplectionBlock;

@property (nonatomic, strong) VoiceChatView * voiceChatView;
@property (nonatomic, strong) MQCollectAudio * collectAudio;
@property (nonatomic, strong) MQPlayAudio * playAudio;

@end

@implementation MQChatManager

@synthesize isLogin;
@synthesize currentSession;
@synthesize netwokStatus;

@synthesize username = _username;
@synthesize userid = _userid;
@synthesize password = _password;

+ (MQChatManager *)sharedInstance
{
    static MQChatManager * cm = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cm = [[MQChatManager alloc] init];
    });

    return cm;
}



- (id)init
{
     self = [super init];
     if (self) {
          _delegates = [[NSMutableArray alloc] init];
          _timeSessions = [[NSMutableArray alloc] init];
          
          _socket = [[Socket alloc] init];
          [_socket addDelegate:self];
          
          __weak typeof(self) weakSelf = self;
          [[AFNetworkReachabilityManager sharedManager] startMonitoring];
          [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
               netwokStatus = status;
               [weakSelf disteributeNetworkChangeStatus:status];
          }];
     
          //添加监听
          
          [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:) name:UIDeviceProximityStateDidChangeNotification object:nil];
          
     }
     return self;
}

- (void)sensorStateChange:(NSNotification *)noti {
     
     if (_voiceChatView) {
          return;
     }
     //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
     if ([[UIDevice currentDevice] proximityState] == YES) {
          NSLog(@"Device is close to user");
          [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
     } else {
          NSLog(@"Device is not close to user");
          [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
     }
}

// MARK: - 属性

- (AEAudioController *)audioController
{
     if (!_audioController) {
          
          AudioStreamBasicDescription audioDescription;
          memset(&audioDescription, 0, sizeof(audioDescription));
          audioDescription.mSampleRate = 8000;//采样率
          audioDescription.mFormatID = kAudioFormatLinearPCM;
          audioDescription.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
          audioDescription.mChannelsPerFrame = 1;///单声道
          audioDescription.mFramesPerPacket = 1;//每一个packet一侦数据
          audioDescription.mBitsPerChannel = 16;//每个采样点16bit量化
          audioDescription.mBytesPerFrame = (audioDescription.mBitsPerChannel/8) * audioDescription.mChannelsPerFrame;
          audioDescription.mBytesPerPacket = audioDescription.mBytesPerFrame ;
          
          _audioController = [[AEAudioController alloc] initWithAudioDescription:audioDescription inputEnabled:YES];
          _audioController.preferredBufferDuration = 0.005;
          _audioController.useMeasurementMode = YES;
     }
     
     return _audioController;
}


// MARK: - 服务器管理

/**
 *  连接聊天服务器
 */
- (void)connectionChatServer
{
     [self.socket connectionToIpaddress:@"li78410693.vicp.cc" Port:27144 isAutoConnection:YES];
}
/**
 *  是否连接服务器
 */
- (BOOL)isConnection
{
     return self.socket.isConnection;
}

/**
 *  登录聊天服务器
 *
 *  @param username    用户名
 *  @param password    密码
 *  @param complection 登录完成回调
 *  @param isAutoReconnection 是否自动断线重连
 */
- (void)loginWithUsername:(NSString *)username Password:(NSString *)password Completion:(void (^) (NSError * error))complection AutoReconnection:(BOOL)isAutoReconnection
{
     _isAutoReconnection = isAutoReconnection;
     self.loginComplectionBlock = complection;
     [self.socket sendAction:Action_Login Parameter:@{@"username" : username,@"password" : password}];
}

/**
 *  注册账号到聊天服务器
 *
 *  @param username    用户名
 *  @param password    密码
 *  @param complection 完成回调block
 */
- (void)regeisterWithUsername:(NSString *)username Password:(NSString *)password Completion:(void (^) (NSError * error))complection
{
     self.registerComplectionBlock = complection;
     [self.socket sendAction:Action_Regeister Parameter:@{@"username" : username,@"password" : password}];
}

/**
 *  退出登录
 *
 *  @param complection 完成回调block
 */
- (void)logOutComplection:(void (^) (NSError * result))complection {
     
     self.logOutComplectionBlock = complection;
     [self.socket sendAction:Action_LogOut Parameter:@{@"username" : _username}];
     
}

// MARK: - 聊天管理

/**
 *  清空当前聊天对象
 */
- (void)nullCurrentSession
{
     currentSession = nil;
}

/**
 *  请求聊天记录
 *
 *  @param username    请求与谁的聊天记录
 *  @param complection 完成回调block
 */
- (void)obtainServerChatRecordWithUsername:(NSString *)username Completion:(void (^) (NSError * result))complection
{
     self.chatRecordComplectionBlock = complection;
     [self.socket sendAction:Action_LogMessage Parameter:@{@"username" : [MQChatManager sharedInstance].username,@"username1" : username}];
     
}

/**
 *  删除一条信息
 *
 *  @param message        信息
 *  @param isRemoveServer 是否删除服务器的
 */
- (void)removeMessage:(Message *)message IsRemoveServer:(BOOL)isRemoveServer
{
     if (isRemoveServer) {
          [self.socket sendAction:Action_RemoveMessage Parameter:@{@"messageId" : message.messageId, @"sessionId" : message.session.sessionId}];
     }
     [self.managedObjectContext deleteObject:message];
     [self.managedObjectContext save:nil];
}
/**
 *  清空会话聊天记录
 *
 *  @param session       会话
 *  @param isClearServer 是否删除会话
 */
- (void)clearSession:(Session *)session IsClearServer:(BOOL)isClearServer
{
     if (isClearServer) {
          [self.socket sendAction:Action_ClearSessionMessage Parameter:@{@"sessionId" : session.sessionId}];
     }
     
     NSFetchRequest * _request = [[NSFetchRequest alloc] initWithEntityName:@"Message"];
     _request.predicate = [NSPredicate predicateWithFormat:@"session == %@",session];
     NSArray * result = [[MQChatManager sharedInstance].managedObjectContext executeFetchRequest:_request error:nil];
     for (id obj in result) {
          [self.managedObjectContext deleteObject:obj];
     }
     [self.managedObjectContext save:nil];
}

// MARK: - 代理
/**
 *  添加聊天代理
 *
 *  @param delegate 代理对象
 */
- (void)addDelegate:(id)delegate
{
     if (!delegate) {
          return;
     }
     MulticastDelegate * md = [[MulticastDelegate alloc] init];
     md.delegate = delegate;
     
     [_delegates addObject:md];
}

/**
 *  删除代理对象
 *
 *  @param delegate 代理对象
 */
- (void)removeDelegate:(id)delegate
{
     if (!delegate) {
          return;
     }
     [_delegates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
          MulticastDelegate * md = obj;
          if (md.delegate == delegate) {
               [_delegates removeObject:md];
               *stop = YES;
          }
     }];
}


// MARK: - 音频管理

/**
 *  开始录制音频
 */
- (void)beginRecordVoice:(void (^)(int))recordTime RecordLevel:(void (^)(float))recordLevel
{
     
     [self.audioController start:nil];
     self.recorder = [[AERecorder alloc] initWithAudioController:self.audioController];
     NSError * error = nil;
     if (![self.recorder beginRecordingToFileAtPath:RECORD_PATH fileType:kAudioFileWAVEType bitDepth:16 error:&error]) {
          [[[UIAlertView alloc] initWithTitle:@"Error"
                                      message:[NSString stringWithFormat:@"Couldn't start recording: %@", [error localizedDescription]]
                                     delegate:nil
                            cancelButtonTitle:nil
                            otherButtonTitles:@"OK", nil] show];
          self.recorder = nil;
          return;
     }
     
     [_audioController addOutputReceiver:_recorder];
     [_audioController addInputReceiver:_recorder];
     self.recorderTime = recordTime;
     self.recorderLevel = recordLevel;
     
     self.recorderTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(recorderTime:) userInfo:nil repeats:YES];
     self.recorderLevelTimer = [NSTimer scheduledTimerWithTimeInterval:0.05f target:self selector:@selector(updateLevel:) userInfo:nil repeats:YES];
}

- (void)recorderTime:(NSTimer *)timer
{
     if (self.recorderTime) {
          int time = (int)(self.recorder.currentTime / 2 + 0.5);
          self.recorderTime(time);
     }
}

- (void)updateLevel:(NSTimer *)timer
{
     if (self.recorderLevel) {
          float inputAvg;
          [_audioController inputAveragePowerLevel:&inputAvg peakHoldLevel:NULL];
          
          if (inputAvg < -100) {
               return;
          }
          self.recorderLevel ((100 - (inputAvg * -1) - 10));
     }
}

/**
 *  停止录制声音
 *
 *  @param recordData 声音数据 已经转码成Amr格式
 */
- (void)endRecordVoice:(void (^)(NSData *soure))recordData
{
     [self.recorderTimer invalidate];
     self.recorderTimer = nil;
     [self.recorderLevelTimer invalidate];
     self.recorderLevelTimer = nil;
     
     [self.audioController stop];
     self.recorderTime = NULL;
     [self.recorder finishRecording];
     [self.audioController removeOutputReceiver:self.recorder];
     [self.audioController removeInputReceiver:self.recorder];
     self.recorder = nil;
     
     NSLog(@"%@",RECORD_PATH);
     NSData * data = [[NSData alloc] initWithContentsOfFile:RECORD_PATH];
     data = [MQEncodeAudio convertWavToAmrFile:data];
     recordData(data);
     
     
}


/**
 *  播放音频来自 data
 *
 *  @param voiceData 音频数据
 */
- (void)playerVoiceFormData:(NSData *)voiceData FinishPlay:(void (^)())block
{
     [self stopPlayerVoice];
     
     NSError * error = nil;
     _audioPlayer = [[AVAudioPlayer alloc] initWithData:voiceData error:&error];
     _audioPlayer.delegate = self;
     if (error) {
          NSLog(@"%@", [error localizedDescription]);
          return;
     }
     [_audioPlayer prepareToPlay];
     [_audioPlayer play];
     self.playFinish = block;
     [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
}

- (void)playerVoiceFormData:(NSData *)voiceData FinishPlay:(void (^)())block Progress:(void (^)(CGFloat, CGFloat, CGFloat))progress
{
     [self playerVoiceFormData:voiceData FinishPlay:block];
     __block typeof(self) weakSelf = self;
     [NSTimer scheduledTimerWithTimeInterval:0.5f Method:^BOOL{
          
          CGFloat p = weakSelf->_audioPlayer.currentTime / weakSelf->_audioPlayer.duration;
          if (p >= 1) {
               return NO;
          }
          progress (p, weakSelf->_audioPlayer.currentTime, weakSelf->_audioPlayer.duration);
          return YES;
     } userInfo:nil repeats:YES];
}

/**
 *  播放音频来自 本地文件
 *
 *  @param voicePath 音频文件路径
 */
- (void)playerVoiceFormPath:(NSString *)voicePath FinishPlay:(void (^)())block
{
     [self stopPlayerVoice];
     NSError * error = nil;
     _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:voicePath] error:&error];
     _audioPlayer.delegate = self;
     if (error) {
          NSLog(@"%@", [error localizedDescription]);
          return;
     }
     [_audioPlayer prepareToPlay];
     [_audioPlayer play];
     self.playFinish = block;
     [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
}

- (void)playerVoiceFormPath:(NSString *)voicePath  FinishPlay:(void(^)())block Progress:(void (^) (CGFloat progress, CGFloat time, CGFloat maxTime))progress
{
     [self playerVoiceFormPath:voicePath FinishPlay:block];
     
     __block typeof(self) weakSelf = self;
     [NSTimer scheduledTimerWithTimeInterval:0.25f Method:^BOOL{
          CGFloat p = weakSelf->_audioPlayer.currentTime / weakSelf->_audioPlayer.duration;
          if (p == 0) {
               progress (1, weakSelf->_audioPlayer.currentTime, weakSelf->_audioPlayer.duration);
               return NO;
          }
          progress (p, weakSelf->_audioPlayer.currentTime, weakSelf->_audioPlayer.duration);
          return YES;
     } userInfo:nil repeats:YES];
}

/**
 *  停止播放音频
 */
- (void)stopPlayerVoice
{
     [_audioPlayer stop];
     _audioPlayer = nil;
     [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
     
}

- (void)beginVoiceChatUsername:(NSString *)username {
     [self beginVoiceChatUsername:username Passivity:NO Ipaddress:nil Port:0];
}
/**
 *  开始语音聊天
 *
 *  @param username 用户名
 */
- (void)beginVoiceChatUsername:(NSString *)username Passivity:(BOOL)passivity Ipaddress:(NSString *)address Port:(NSInteger)port
{
     if (self.voiceChatView) {
          return;
     }
     address = [[address componentsSeparatedByString:@":"] lastObject];
     self.voiceChatView = [VoiceChatView voiceChatViewWithUsername:username Passivity:passivity Ipaddress:address Port:port];
//     [[[[UIApplication sharedApplication] delegate] window] addSubview:self.voiceChatView];
}

/**
 *  设置语音信息
 *
 *  @param state
 */
- (void)setVoiceData:(NSDictionary *)dict
{
     if ([[dict objectForKey:@"type"] integerValue] != VoiceState_Disconnect) {
         [self beginVoiceChatUsername:[dict objectForKey:@"username"] Passivity:YES Ipaddress:[dict objectForKey:@"ipaddr"] Port:[[dict objectForKey:@"port"] integerValue]];
     }
     [self.voiceChatView setVoiceData:dict];
}

/**
 *  结束语音聊天
 */
- (void)endVoiceChat
{
     if (!_voiceChatView) {
          return;
     }
     [self endRealTimeVoice];
     [UIView animateWithDuration:0.25 animations:^{
          self.voiceChatView.alpha = 0.0f;
     } completion:^(BOOL finished) {
          [self.voiceChatView removeFromSuperview];
          self.voiceChatView = nil;
     }];
}

/**
 *  开启实时语音
 *
 *  @param block 采集到的音频数据
 */
- (void)beginRealTimeVoice:(void (^) (NSData *))block
{
     if (_isRealTimeVoiceing) {
          return;
     }
     _isRealTimeVoiceing = YES;
     [self.audioController start:nil];
     self.playAudio = [[MQPlayAudio alloc] initWithAudioController:[MQChatManager sharedInstance].audioController];
     [self.playAudio beginPlayAudio];
     self.collectAudio = [[MQCollectAudio alloc] initWithAudioController:self.audioController];
     
     [self.collectAudio beganCollectAudio:^(NSData *audio) {
          block(audio);
          
     } AudioBufferList:nil];
     

     
     
}
/**
 *  结束实时语音
 */
- (void)endRealTimeVoice
{
     _isRealTimeVoiceing = NO;
     [self.audioController stop];
     [self.collectAudio endCollectAudio];
     self.collectAudio = nil;
     
     [self.playAudio endPlayAudio];
     self.playAudio = nil;
}

/**
 *  播放接受到的实时语音数据
 *
 *  @param data 语音数据
 */
- (void)playeRealTimeVoiceData:(NSData *)data
{
     data = [MQEncodeAudio convertAmrToWav:data];
     [self.playAudio addAudioData:data];
}


// MARK: - 消息分发

/**
 *  分发接受的信息
 *
 *  @param message
 */
- (void)distributeReceiveMessage:(Message *)message
{
     __block typeof(self) weakSelf = self;
     [_delegates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
          MulticastDelegate * md = obj;
          if (md.delegate && [md.delegate respondsToSelector:@selector(chatManager:ReceiveMessage:)]) {
               [md.delegate chatManager:weakSelf ReceiveMessage:message];
          } else if (!md.delegate) {
               [weakSelf->_delegates removeObjectAtIndex:idx];
          }
          
     }];
}

/**
 *  分发发送的信息
 *
 *  @param message
 */
- (void)distributeSendMessage:(Message *)message
{
     __block typeof(self) weakSelf = self;
     [_delegates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
          MulticastDelegate * md = obj;
          if (md.delegate && [md.delegate respondsToSelector:@selector(chatManager:SendMessage:)]) {
               [md.delegate chatManager:weakSelf SendMessage:message];
          } else if (!md.delegate) {
               [weakSelf->_delegates removeObjectAtIndex:idx];
          }
          
     }];
}

/**
 *  分发将要发送消息代理
 *
 *  @param session
 */
- (void)disteributeWillReceiveMessageSession:(Session *)session
{
     __block typeof(self) weakSelf = self;
     [_delegates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
          MulticastDelegate * md = obj;
          if (md.delegate && [md.delegate respondsToSelector:@selector(chatManager:WillReceiveMessageSession:)]) {
               [md.delegate chatManager:self WillReceiveMessageSession:session];
          } else if (!md.delegate) {
               [weakSelf->_delegates removeObjectAtIndex:idx];
          }
          
     }];
}

/**
 *  分发离线消息代理
 *
 *  @param messages 离线消息数组
 */
- (void)disteributeReceiveOfflineMessages:(NSArray *)messages {
     
     __block typeof(self) weakSelf = self;
     [_delegates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
          MulticastDelegate * md = obj;
          if (md.delegate && [md.delegate respondsToSelector:@selector(chatManager:ReceiveOfflineMessages:)]) {
               [md.delegate chatManager:self ReceiveOfflineMessages:messages];
          } else if (!md.delegate) {
               [weakSelf->_delegates removeObjectAtIndex:idx];
          }
     }];
}

/**
 *  分发网络状态改变
 *
 *  @param status 网络状态
 */
- (void)disteributeNetworkChangeStatus:(AFNetworkReachabilityStatus)status {
     __block typeof(self) weakSelf = self;
     [_delegates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
          MulticastDelegate * md = obj;
          if (md.delegate && [md.delegate respondsToSelector:@selector(chatManager:NetworkChangeState:)]) {
               [md.delegate chatManager:self NetworkChangeState:status];
          } else if (!md.delegate) {
               [weakSelf->_delegates removeObjectAtIndex:idx];
          }
     }];
}

/**
 *  分发退出登录
 *
 *  @param status 退出描述状态
 */
- (void)disteributeLogOutStatus:(LogOutDescriptionStatus)status {
     __block typeof(self) weakSelf = self;
     [_delegates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
          MulticastDelegate * md = obj;
          if (md.delegate && [md.delegate respondsToSelector:@selector(chatManager:LogOutDescriptionStatus:)]) {
               [md.delegate chatManager:self LogOutDescriptionStatus:status];
          } else if (!md.delegate) {
               [weakSelf->_delegates removeObjectAtIndex:idx];
          }
     }];
}


// MARK: - 会话管理



/**
 *  根据用户名查找session 如果没有找到则新建
 *
 *  @param username  用户名
 *  @param isDefault 是否设为默认的聊天session
 *
 *  @return session
 */
+ (Session *)sessionForUserName:(NSString *)username Default:(BOOL)isDefault
{
    
    Session * session = nil;
     
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Session"];
    request.predicate = [NSPredicate predicateWithFormat:@"sessionId == %@",[MQChatManager sessionIdForUserName:username]];
    
    NSError * error;
    NSArray * result = [[MQChatManager sharedInstance].managedObjectContext executeFetchRequest:request error:&error];
    session = [result firstObject];
    
    if (!session) {
         session = [NSEntityDescription insertNewObjectForEntityForName:@"Session" inManagedObjectContext:[MQChatManager sharedInstance].managedObjectContext];
         session.to = username;
         session.from = [MQChatManager sharedInstance].username;
         session.sessionId = [MQChatManager sessionIdForUserName:username];
        
         NSError * error;
         [[MQChatManager sharedInstance].managedObjectContext save:&error];
         if (error) {
              NSLog(@"%@",[error localizedDescription]);
              return nil;
         }
    }
     if (isDefault) {
         [[MQChatManager sharedInstance] setValue:session forKey:@"currentSession"];
     }
     
     
     
    
    return session;
    
}

/**
 *  根据对方用户名生成一个唯一的sessionID
 *
 *  @param username 对方用户名
 *
 *  @return sessionId
 */
+ (NSString *)sessionIdForUserName:(NSString *)username
{
     NSString * str = [NSString stringWithFormat:@"%@%@",[MQChatManager sharedInstance].username, username];

     NSMutableArray * mArr = [[NSMutableArray alloc] init];
     for (int i = 0; i < str.length; i++) {
          [mArr addObject:[str substringWithRange:NSMakeRange(i, 1)]];
     }
     [mArr sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
          char * c1 = (char *)[obj1 UTF8String];
          char * c2 = (char *)[obj2 UTF8String];
          if (c1[0] < c2[0]) {
               return -1;
          }
          return 1;
     }];
     NSMutableString * mStr = [[NSMutableString alloc] init];
     for (int i = 0; i < mArr.count; i++) {
          [mStr appendString:[mArr objectAtIndex:i]];
     }
     [mStr appendString:[MQChatManager sharedInstance].username];
     
     return mStr;
}

/**
 *  获取所有会话的未读信息数量
 *
 *  @return
 */
+ (NSInteger)getAllSessionUnreadCount {
     
     NSInteger count = 0;
     if (![MQChatManager sharedInstance].username) {
          return count;
     }
     NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:@"Session"];
     request.predicate = [NSPredicate predicateWithFormat:@"from == %@", [MQChatManager sharedInstance].username];
     
     NSError * error;
     NSArray * result = [[MQChatManager sharedInstance].managedObjectContext executeFetchRequest:request error:&error];
     for (Session * session in result) {
          count += [session.unreadCount integerValue];
     }
     
     
     return count;
}

/**
 *  插入时间到一个信息数组
 *
 *  @param messages 信息数组
 *
 *  @return 返回插入时间之后的数组
 */
+ (NSArray *)inserTimeToMessages:(NSArray *)messages LastDate:(NSDate **)lastDate
{
     NSDate * preDate = nil;
     NSInteger count = 0;
     
     NSDateFormatter * dateF = [[NSDateFormatter alloc] init];
     [dateF setDateFormat:@"HH:mm"];
     
     NSMutableArray * mArr = [[NSMutableArray alloc] init];
     NSDate * messageDate = nil;
     for (Message * message in messages) {
          
          messageDate = [NSDate dateWithTimeIntervalSince1970:[message.time floatValue]];
          
          if (!preDate || [messageDate timeIntervalSinceDate:preDate] >= 180 || count >= 10) {
               [mArr addObject:[dateF stringFromDate:messageDate]];
          }
          [mArr addObject:message];
          preDate = messageDate;
          count ++;
     }
     if (messageDate) {
          *lastDate = messageDate;
     }
     
     return mArr;
}

// MARK: - 信息发送

/**
 *  异步发送信息
 *
 *  @param message 信息对象
 */
+ (void)asyncSendMessage:(Message *)message
{
     NSDate * date = [NSDate date];
     message.state = [NSNumber numberWithInt:MessageSendState_Sending];
     message.isSender = [NSNumber numberWithBool:YES];
     message.messageId = [[NSString alloc] initWithFormat:@"%f",[date timeIntervalSince1970]];
     message.time = message.messageId;
     [[MQChatManager sharedInstance] setLastContentAndLastDateToSession:message.session Message:message];
     switch ([message.type integerValue]) {
          case MessageType_Image:
          {
               
               message.localPath = [MQChatUtil saveDataToLocationFileName:[MQChatUtil createFileName:message.time] Directory:DIRECTORY_IMAGE Data:UIImageJPEGRepresentation(message.image, 1)];
          }
               break;
          case MessageType_Audio:
          {
               message.audioLocationPath = [MQChatUtil copyFile:RECORD_PATH FileName:[MQChatUtil createFileName:message.time Suffix:@"wav"] ToDirectory:DIRECTORY_RECORD];
               
          }
               break;
          default:
               break;
     }
     
     NSError * error;
     [[MQChatManager sharedInstance].managedObjectContext save:&error];
     if (error) {
          NSLog(@"%@", [error localizedDescription]);
     }
     
     [[MQChatManager sharedInstance].socket sendAction:Action_SendMessage Parameter:[message conversionToDictionary]];
}

/**
 *  异步重新发送信息
 *
 *  @param message 信息
 */
+ (void)asyncAgainSendMessage:(Message *)message
{
     [[MQChatManager sharedInstance].socket sendAction:Action_SendMessage Parameter:[message conversionToDictionary]];
}

/**
 *  发送语音聊天数据
 *
 *  @param data
 */
+ (void)asyncSendVoiceChatDataWithdictionary:(NSDictionary *)dictionary
{
     [[MQChatManager sharedInstance].socket sendDataWithDictionary:dictionary];
}

// 保存离线消息
- (void)addOfflineMessage:(NSArray *)messages
{
     NSMutableArray * mArr = [[NSMutableArray alloc] initWithCapacity:0];
     for (NSDictionary * dict in messages) {
          Message * mess = [Message messageWithDict:dict];
          [mArr addObject:mess];
          mess.session.unreadCount = [NSNumber numberWithInteger:[mess.session.unreadCount integerValue] + 1];
          [self setLastContentAndLastDateToSession:mess.session Message:mess];
     }
     
     NSError * error;
     [[MQChatManager sharedInstance].managedObjectContext save:&error];
     if (error) {
          NSLog(@"%@",error);
     }
     
     [self disteributeReceiveOfflineMessages:mArr];
}

// MARK: - Socket Delegate

- (void)socketConnection:(Socket *)sock
{
     // 断线了之后判断是否需要自动重新连接
     if (!isLogin && _isAutoReconnection && [MQChatManager sharedInstance].userid) {
          [self loginWithUsername:[MQChatManager sharedInstance].username Password:[MQChatManager sharedInstance].password Completion:nil AutoReconnection:_isAutoReconnection];
     }
}

- (void)socketDisconnection:(Socket *)sock
{
     isLogin = NO;
}

- (void)socket:(Socket *)sock ReceiveData:(NSDictionary *)dict Action:(Action)action
{
     NSError * error = [NSError errorWithDomain:[dict objectForKey:@"msg"] code:[[dict objectForKey:@"code"] integerValue] userInfo:[dict objectForKey:@"data"]];
     if (action == 0) {
          [[[[UIApplication sharedApplication] delegate] window] showTipsString:error.domain];
          return;
     }
     switch (action) {
          case Action_ReceiveMessage:
          {
               if (error.code != 1) {
                    NSLog(@"%@",error.domain);
                    return;
               }

               
               Session * session = [MQChatManager sessionForUserName:[error.userInfo objectForKey:@"from"] Default:NO];
               session.unreadCount = [NSNumber numberWithInteger:[session.unreadCount integerValue] + 1];
               [self disteributeWillReceiveMessageSession:session];
               
               Message * message = [Message messageWithDict:error.userInfo];

               [self setLastContentAndLastDateToSession:session Message:message];
               [self distributeReceiveMessage:message];
               error = nil;
               [[MQChatManager sharedInstance].managedObjectContext save:&error];
               if (error) {
                    NSLog(@"%@",error);
               }
          }
               break;
          case Action_Login:
               if (self.loginComplectionBlock) {
                    if (error.code == 1) {
                         isLogin = YES;
                         _username = [error.userInfo objectForKey:@"username"];
                         _password = [error.userInfo objectForKey:@"password"];
                         _userid = [error.userInfo objectForKey:@"_id"];
                    }
                    self.loginComplectionBlock(error);
               }
               break;
          case Action_Regeister:
               if (self.registerComplectionBlock) {
                    self.registerComplectionBlock(error);
               }
               break;
          case Action_LogMessage:
               if (self.chatRecordComplectionBlock) {
                    self.chatRecordComplectionBlock(error);
               }
               break;
          case Action_OfflineMessage:
               [self addOfflineMessage:[error.userInfo objectForKey:@"list"]];
               break;
          case Action_VoiceChat:
               [[MQChatManager sharedInstance] setVoiceData:error.userInfo];
               break;
          case Action_SendMessage:
          {
               NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Message"];
               request.predicate = [NSPredicate predicateWithFormat:@"messageId == %@",[[dict objectForKey:@"data"] objectForKey:@"messageId"]];
               
               NSError * error;
               NSArray * result = [[MQChatManager sharedInstance].managedObjectContext executeFetchRequest:request error:&error];
               if (error) {
                    NSLog(@"%@",[error localizedDescription]);
               }
               
               Message * mess = [result firstObject];
               mess.state = [NSNumber numberWithInteger:MessageSendState_Succeed];
               
               
               [[MQChatManager sharedInstance].managedObjectContext save:&error];
               if (error) {
                    NSLog(@"%@",[error localizedDescription]);
               }
               
               [self distributeSendMessage:mess];
          }
               break;
          case Action_LogOut:
               
               if (error.code == 1) {
                    _userid = nil;
                    _username = nil;
                    _password = nil;
                    _isAutoReconnection = NO;
                    isLogin = NO;
               }
               [self disteributeLogOutStatus:LogOutDescriptionStatus_UserLogOut];
               self.logOutComplectionBlock (error);
               break;
          case Action_OtherDeviceLogin:
      
               _userid = nil;
               _username = nil;
               _password = nil;
               _isAutoReconnection = NO;
               isLogin = NO;
               [self disteributeLogOutStatus:LogOutDescriptionStatus_OtherDeviceLogin];
               break;
          default:
               break;
     }
}


- (void)socket:(Socket *)sock SendData:(NSDictionary *)dict Succeed:(BOOL)isSucceed Action:(Action)action
{
     switch (action) {
          case Action_SendMessage:
          {
               if (!isSucceed) {
                    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Message"];
                    request.predicate = [NSPredicate predicateWithFormat:@"messageId == %@",[dict objectForKey:@"messageId"]];
                    
                    NSError * error;
                    NSArray * result = [[MQChatManager sharedInstance].managedObjectContext executeFetchRequest:request error:&error];
                    if (error) {
                         NSLog(@"%@",[error localizedDescription]);
                    }
                    
                    Message * mess = [result firstObject];
                    mess.state = [NSNumber numberWithInteger:MessageSendState_Fail];
                    
                    
                    [[MQChatManager sharedInstance].managedObjectContext save:&error];
                    if (error) {
                         NSLog(@"%@",[error localizedDescription]);
                    }
                    
                    [self distributeSendMessage:mess];
               }
               
          }
               break;
          case Action_Login:
               if (!isSucceed && self.loginComplectionBlock) {
                    self.loginComplectionBlock([self defaultErrorMsg:@"登录请求失败"]);
               }
               break;
          case Action_Regeister:
               if (!isSucceed && self.registerComplectionBlock) {
                    self.registerComplectionBlock([self defaultErrorMsg:@"注册请求失败"]);
               }
               break;
          case Action_LogMessage:
               if (!isSucceed && self.chatRecordComplectionBlock) {
                    self.chatRecordComplectionBlock([self defaultErrorMsg:@"聊天记录请求失败"]);
               }
               break;
          case Action_LogOut:
               if (!isSucceed && self.logOutComplectionBlock) {
                    self.logOutComplectionBlock([self defaultErrorMsg:@"退出登录请求失败"]);
               }
               break;
          default:
               break;
     }

}

- (void)setLastContentAndLastDateToSession:(Session *)session Message:(Message *)message
{
     if (session == self.currentSession) {
          return;
     }
     session.lastDate = [[NSDate alloc] initWithTimeIntervalSince1970:[message.time intValue] + 28800];
     NSString * content = nil;
     switch ([message.type integerValue]) {
          case MessageType_Audio:
               content = @"[语音]";
               break;
          case MessageType_Image:
               content = @"[图片]";
               break;
          case MessageType_Location:
               content = @"[位置]";
               break;
          case MessageType_Text:
               content = message.content;
               break;
          default:
               break;
     }
     session.lastContent = content;
}

- (NSError *)defaultErrorMsg:(NSString *)msg
{
     NSError * error = [NSError errorWithDomain:msg code:0 userInfo:nil];
     return error;
}


// MARK: - AVAudioPlay Delegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
     [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
     if (self.playFinish) {  self.playFinish(); }
}


@end
