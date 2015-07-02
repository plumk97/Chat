//
//  NSTimer+Ext.h
//  Chat
//
//  Created by 货道网 on 15/6/16.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (Ext)

+ (void)scheduledTimerWithTimeInterval:(NSTimeInterval)ti Method:(BOOL (^) ())method userInfo:(id)userInfo repeats:(BOOL)yesOrNo;

@end
