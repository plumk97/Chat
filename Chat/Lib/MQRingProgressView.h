//
//  MQRingProgressView.h
//  CALayerAnimation
//
//  Created by 货道网 on 15/6/16.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  环形进度条
 */
@interface MQRingProgressView : UIView

@property (nonatomic, strong) UIColor * trackColor;
@property (nonatomic, strong) UIColor * progressColor;

@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) CGFloat lineWidth;

@property (nonatomic, assign) CGFloat startAngle;


- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

@end
