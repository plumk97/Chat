//
//  UIView+Animation.m
//  LoadingAnimation
//
//  Created by 货道网 on 15/6/2.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import "UIView+Animation.h"
#import "MQLoadAnimation.h"

#import <objc/runtime.h>

@interface MQTipsView : UILabel

- (id)initWithString:(NSString *)string;
- (void)hide;
@end
@implementation MQTipsView

- (id)initWithString:(NSString *)string
{
    self = [super initWithFrame:CGRectMake(0, 0, 0, 0)];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8f];
        self.textColor = [UIColor whiteColor];
        self.font = [UIFont systemFontOfSize:13];
        self.numberOfLines = 0;
        self.text = string;
        self.layer.cornerRadius = 10.0f;
        self.layer.masksToBounds = YES;
        CGRect boduns = [string boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 80, 999) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.font} context:nil];
        boduns.size.width += 10;
        boduns.size.height += 10;
        self.frame = boduns;
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self hide];
        });
    }
    return self;
}

- (void)hide
{
    [UIView animateWithDuration:0.15
                     animations:^{
                         self.alpha = 0;
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

- (void)drawTextInRect:(CGRect)rect
{
    CGRect boduns = [self.text boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 80, 999) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.font} context:nil];
    rect.origin.x = (rect.size.width - boduns.size.width) / 2.0f;
    [super drawTextInRect:rect];
}

@end

@implementation UIView (Animation)


- (void)showLoadAnimation
{
    
    MQLoadAnimation * la = objc_getAssociatedObject(self, "loadAnimation");
    if (!la) {
        la = [MQLoadAnimation loadAnimation];
        la.center = self.center;
        [self addSubview:la];
        objc_setAssociatedObject(self, "loadAnimation", la, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [la showAnimation];
    
}

- (void)hideLoadAnimation
{
    MQLoadAnimation * la = objc_getAssociatedObject(self, "loadAnimation");
    if (la) {
        [la hideAnimation];
    }
}
- (void)showTipsString:(NSString *)string
{
    UIView * view = [self isKindOfClass:[UIWindow class]] ? self : self.window;
    MQTipsView * tips = objc_getAssociatedObject(view, "mqtipsview");
    if (tips) {
        [tips removeFromSuperview];
    }
    tips = [[MQTipsView alloc] initWithString:string];
    
    CGRect frame = tips.frame;
    frame.origin = CGPointMake(([UIScreen mainScreen].bounds.size.width - frame.size.width) / 2.0f, [UIScreen mainScreen].bounds.size.height - 100 - tips.frame.size.height / 2.0f);
    tips.frame = frame;
    [view addSubview:tips];
    objc_setAssociatedObject(view, "mqtipsview", tips, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}
- (void)hideTips {
    UIView * view = [self isKindOfClass:[UIWindow class]] ? self : self.window;
    MQTipsView * tips = objc_getAssociatedObject(view, "mqtipsview");
    if (tips) {
        [tips removeFromSuperview];
    }
}




@end
