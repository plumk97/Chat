//
//  GlobalMethod.m
//  Chat
//
//  Created by 货道网 on 15/5/4.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import "GlobalMethod.h"

static GlobalMethod * gl = nil;

@implementation GlobalMethod

+ (GlobalMethod *)sharedGlobalMethod
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gl = [[GlobalMethod alloc] init];
    });
    
    return gl;
}

- (id) init
{
    self = [super init];
    if (self) {
    }
    return self;
}

+ (void)changeWindowRootViewController:(UIViewController *)viewCotnroller
{
    UIWindow * window = [[[UIApplication sharedApplication] delegate] window];
    
    window.rootViewController = viewCotnroller;
}

/**
 *  获取storyboard
 *
 *  @param _id viewcontroller在storyboard中的id
 *
 *  @return 返回获取到的viewcontroller
 */
+ (UIViewController *)getStoryboardID:(NSString *)_id
{
    UIViewController * vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:_id];
    return vc;
}


@end
