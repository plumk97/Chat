//
//  UIView+Animation.h
//  LoadingAnimation
//
//  Created by 货道网 on 15/6/2.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Animation)

- (void)showLoadAnimation;
- (void)hideLoadAnimation;

- (void)showTipsString:(NSString *)string;
- (void)hideTips;

@end
