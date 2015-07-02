//
//  ChatViewController.h
//  Chat
//
//  Created by 货道网 on 15/5/4.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ChatViewController : UIViewController

@property (nonatomic, readonly) NSString * username;

- (id) initWithUserName:(NSString *)_userName;

@end
