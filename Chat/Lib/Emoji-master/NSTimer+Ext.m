//
//  NSTimer+Ext.m
//  Chat
//
//  Created by 货道网 on 15/6/16.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import "NSTimer+Ext.h"

@interface MQTimer : NSObject

@property (nonatomic, copy) BOOL (^timeMethod) ();

- (void)startTimerWithTimeInterval:(NSTimeInterval)ti UserInfo:(id)userInfo repeats:(BOOL)yesOrNo;

@end
@implementation MQTimer

- (void)startTimerWithTimeInterval:(NSTimeInterval)ti UserInfo:(id)userInfo repeats:(BOOL)yesOrNo
{
    [NSTimer scheduledTimerWithTimeInterval:ti target:self selector:@selector(timer:) userInfo:userInfo repeats:yesOrNo];
}

- (void)timer:(NSTimer *)sender
{
    if (self.timeMethod) {
        BOOL result = self.timeMethod();
        if (!result) {
            [sender invalidate];
            sender = nil;
        }
    }
}

- (void)dealloc
{
    NSLog(@"timer dealloc");
}
@end

@implementation NSTimer (Ext)

+ (void)scheduledTimerWithTimeInterval:(NSTimeInterval)ti Method:(BOOL (^) ())method userInfo:(id)userInfo repeats:(BOOL)yesOrNo
{
    MQTimer * timer = [MQTimer new];
    timer.timeMethod = method;
    [timer startTimerWithTimeInterval:ti UserInfo:userInfo repeats:yesOrNo];
}

@end
