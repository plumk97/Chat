//
//  NSTimer+Ext.h
//  Chat
//
//  Created by 货道网 on 15/6/16.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (Ext)

/**
 *  快速创建定时器
 *
 *  @param ti       间隔
 *  @param method   执行代码块 返回YES 代表继续执行 返回NO 销毁定时器
 *  @param userInfo 用户信息
 *  @param yesOrNo  是否循环执行
 */
+ (void)scheduledTimerWithTimeInterval:(NSTimeInterval)ti Method:(BOOL (^) ())method userInfo:(id)userInfo repeats:(BOOL)yesOrNo;

@end
