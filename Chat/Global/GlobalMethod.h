//
//  GlobalMethod.h
//  Chat
//
//  Created by 货道网 on 15/5/4.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MQChatManager.h"
#import "UIView+Animation.h"
#import "UIScrollView+MQRefreshControl.h"
#import "NSTimer+Ext.h"

@interface GlobalMethod : NSObject





+ (GlobalMethod *)sharedGlobalMethod;



// MARK: - 类方法

/**
 *  改变window的rootViewController
 *
 *  @param viewCotnroller 新的viewcontroller
 */
+ (void)changeWindowRootViewController:(UIViewController *)viewCotnroller;


/**
 *  获取storyboard
 *
 *  @param _id viewcontroller在storyboard中的id
 *
 *  @return 返回获取到的viewcontroller
 */
+ (UIViewController *)getStoryboardID:(NSString *)_id;



@end
