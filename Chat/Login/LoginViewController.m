//
//  LoginViewController.m
//  Chat
//
//  Created by 货道网 on 15/5/4.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import "LoginViewController.h"
#import "MQEncodeAudio.h"

#import <AEAudioController.h>
#import <AERecorder.h>

#import "UIView+Animation.h"

#import "Emoji.h"


@interface LoginViewController ()

{

    BOOL isFirst;
}
@property (nonatomic) AERecorder * recorder;
@property (nonatomic, strong) NSMutableData * recorderData;

@end

@implementation LoginViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)loginBtnClick:(id)sender {
    
    __block typeof(self) weakSelf = self;
    [weakSelf.view showLoadAnimation];
    [[MQChatManager sharedInstance] loginWithUsername:self.usernameTextField.text Password:self.passwordTextField.text Completion:^(NSError *result) {
        [weakSelf.view hideLoadAnimation];
        if (result.code != 1) {
            [self.view showTipsString:result.domain];
            return ;
        }

        [GlobalMethod changeWindowRootViewController:[GlobalMethod getStoryboardID:@"HomeNavigationController"]];
    } AutoReconnection:YES];
}

- (void)dealloc
{
    
}



@end
