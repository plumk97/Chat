//
//  MQLoadAnimation.m
//  LoadingAnimation
//
//  Created by 货道网 on 15/6/2.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import "MQLoadAnimation.h"

@interface MQAnimation : UIView
{
    int _angle;
    float _scale;
    CGFloat _distance;
    BOOL _isStartAnimation;
    BOOL _isAnimationing;
    CGPoint originPoints[4];
}

- (id) initWithWidth:(CGFloat)width Distance:(CGFloat)distance;

- (void)rotatAngle:(CGFloat)angle;

- (void)beginAnimation;
- (void)endAnimation;

@end
@implementation MQAnimation

- (id)initWithWidth:(CGFloat)width Distance:(CGFloat)distance
{
    self = [super initWithFrame:CGRectMake(0, 0, width, width)];
    if (self) {
        _distance = distance;
        
        CGRect roundRect = CGRectMake(_distance / 2, _distance / 2, self.frame.size.width / 2 - _distance, self.frame.size.width / 2 - _distance);
        NSInteger x = 0;
        
        NSArray * colors =@[
                            [UIColor colorWithRed:1 green:219 / 255.0f blue:60 / 255.0f alpha:1],
                            [UIColor colorWithRed:102 / 255.0f green:220 / 255.0f blue:160 / 255.0f alpha:1],
                            [UIColor colorWithRed:93 / 255.0f green:198 / 255.0f blue:193 / 255.0f alpha:1],
                            [UIColor colorWithRed:234 / 255.0f green:85 / 255.0f blue:104 / 255.0f alpha:1]];
        
        for (int i = 0; i < 4; i ++) {
            UIView * view = [[UIView alloc] initWithFrame:roundRect];
            view.layer.cornerRadius = roundRect.size.width / 2.0f;
            view.backgroundColor = colors[i];
            [self addSubview:view];
            
            originPoints[i] = view.frame.origin;
            
            x ++;
            roundRect.origin.x = x * roundRect.size.width + _distance + _distance / 2;
            if (x == 2) {
                roundRect.origin.y += roundRect.size.height + _distance;
                roundRect.origin.x = _distance / 2;
                x = 0;
            }
        }
        
    }
    return self;
}

- (void)rotatAngle:(CGFloat)angle
{
    _angle = angle;
    
    CGAffineTransform rota = CGAffineTransformMakeRotation(_angle * (M_PI / 180.0f));
    self.transform = rota;
}

- (void)beginAnimation
{
    if (_isAnimationing) {
        return;
    }
    _isAnimationing = YES;
    [self rotaAnimation];
}

- (void)rotaAnimation {
    
    [UIView animateWithDuration:0.03 animations:^{
        [self rotatAngle:_angle + 10];
    } completion:^(BOOL finished) {
        if (_isAnimationing) {
            [self rotaAnimation];
            [self centerAnimation];
        }
        
    }];
}

- (void)centerAnimation
{
    if (_isStartAnimation) {
        return;
    }
    _isStartAnimation = YES;
    CGFloat value = _distance / 2 - 1;
    [UIView animateWithDuration:0.25 animations:^{
        for (UIView * v in self.subviews) {
            
            NSInteger index = [self.subviews indexOfObject:v];
            
            CGRect frame = v.frame;
            frame.origin = originPoints[index];
            switch (index) {
                case 0:
                    frame.origin.x += value;
                    frame.origin.y += value;
                    break;
                case 1:
                    frame.origin.x -= value;
                    frame.origin.y += value;
                    break;
                case 2:
                    frame.origin.x += value;
                    frame.origin.y -= value;
                    break;
                case 3:
                    frame.origin.x -= value;
                    frame.origin.y -= value;
                    break;
                default:
                    break;
            }
            
            v.frame = frame;
        }
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25 animations:^{
            for (UIView * v in self.subviews) {
                CGRect frame = v.frame;
                frame.origin = originPoints[[self.subviews indexOfObject:v]];
                v.frame = frame;
            }
        } completion:^(BOOL finished) {
            _isStartAnimation = NO;
        }];
    }];
    
}

- (void)endAnimation
{
    _isAnimationing = NO;
}


@end


@interface MQLoadAnimation ()
{
    MQAnimation * _animation;
}
@end

@implementation MQLoadAnimation

+ (MQLoadAnimation *)loadAnimation
{
    MQLoadAnimation * animation = [[MQLoadAnimation alloc] initWithFrame:[UIScreen mainScreen].bounds];
    return animation;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1f];
        _animation = [[MQAnimation alloc] initWithWidth:50 Distance:8];
        [self addSubview:_animation];
        _animation.center = self.center;
        
    }
    return self;
}
- (void) showAnimation
{
    [_animation beginAnimation];
    self.hidden = NO;
}
- (void) hideAnimation
{
    [_animation endAnimation];
    self.hidden = YES;
}


@end
