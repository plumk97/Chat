//
//  RegisterViewController.h
//  Chat
//
//  Created by 货道网 on 15/5/4.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginTextField.h"

@interface RegisterViewController : UIViewController

@property (weak, nonatomic) IBOutlet LoginTextField *usernameTextField;
@property (weak, nonatomic) IBOutlet LoginTextField *passwordTextField;

@end
