//
//  MQRingProgressView.m
//  CALayerAnimation
//
//  Created by 货道网 on 15/6/16.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import "MQRingProgressView.h"

@interface MQRingProgressView () {
    
    CAShapeLayer * _trackLayer;
    CAShapeLayer * _progressLayer;
}

@end

@implementation MQRingProgressView

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.userInteractionEnabled = NO;
        
        _trackLayer = [CAShapeLayer layer];
        _trackLayer.fillColor = nil;
        _trackLayer.frame = self.bounds;
        [self.layer addSublayer:_trackLayer];
        
        
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.fillColor = nil;
        _progressLayer.frame = self.bounds;
        _progressLayer.lineCap = kCALineCapRound;
        [self.layer addSublayer:_progressLayer];
        
        _startAngle = 90;
        self.lineWidth = 5;
        self.trackColor = [UIColor clearColor];
        self.progressColor = [UIColor brownColor];
        self.progress = 0;
        
    }
    
    return self;
}

- (void)setLineWidth:(CGFloat)lineWidth
{
    _lineWidth = lineWidth;
    
    _trackLayer.lineWidth = lineWidth;
    _progressLayer.lineWidth = lineWidth;
    
    CGPoint center = CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f);
    UIBezierPath * bezierPath = [UIBezierPath bezierPathWithArcCenter:center radius:(self.bounds.size.width - lineWidth)/ 2 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    _trackLayer.path = bezierPath.CGPath;
    _progressLayer.path = bezierPath.CGPath;
    
    
    bezierPath = [UIBezierPath bezierPathWithArcCenter:center radius:(self.bounds.size.width - lineWidth)/ 2 startAngle:-_startAngle * M_PI / 180.0f endAngle:(360 - _startAngle) * M_PI / 180.0f clockwise:YES];
    _progressLayer.path = bezierPath.CGPath;
}

- (void)setTrackColor:(UIColor *)trackColor {
    _trackColor = trackColor;
    _trackLayer.strokeColor = trackColor.CGColor;
}

- (void)setProgressColor:(UIColor *)progressColor {
    _progressColor = progressColor;
    _progressLayer.strokeColor = progressColor.CGColor;
}

- (void)setProgress:(CGFloat)progress {
    
    _progress = progress;
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    _progressLayer.strokeEnd = progress;
    [CATransaction commit];
}

- (void)setStartAngle:(CGFloat)startAngle
{
    _startAngle = startAngle;
    self.lineWidth = _lineWidth;
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
    if (animated) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        animation.duration = 0.25;
        animation.fromValue = @(self.progress);
        animation.toValue = @(progress);
        animation.delegate = self;
        [_progressLayer addAnimation:animation forKey:@"AnimationKey"];
    }
    self.progress = progress;
}
@end
