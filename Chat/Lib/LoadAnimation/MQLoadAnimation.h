//
//  MQLoadAnimation.h
//  LoadingAnimation
//
//  Created by 货道网 on 15/6/2.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MQLoadAnimation : UIView

+ (MQLoadAnimation *)loadAnimation;

- (void) showAnimation;
- (void) hideAnimation;
@end
