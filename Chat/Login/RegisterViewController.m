//
//  RegisterViewController.m
//  Chat
//
//  Created by 货道网 on 15/5/4.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import "RegisterViewController.h"
#import "UIView+Animation.h"

@implementation RegisterViewController

- (void)viewDidLoad
{
    
    [super viewDidLoad];

    
}
- (IBAction)itemClick:(id)sender {
    
    [self.view endEditing:YES];
    __weak typeof(self) weakSelf = self;
    [weakSelf.view showLoadAnimation];
    [[MQChatManager sharedInstance] regeisterWithUsername:self.usernameTextField.text Password:self.passwordTextField.text Completion:^(NSError *error) {
        [weakSelf.view hideLoadAnimation];
        if (error.code != 1) {
            [weakSelf.view showTipsString:error.domain];
            return ;
        }[weakSelf.view showTipsString:@"注册成功"];
        NSLog(@"%@",error.userInfo);
        [self.navigationController popViewControllerAnimated:YES];
        
    }];
    
}

@end
