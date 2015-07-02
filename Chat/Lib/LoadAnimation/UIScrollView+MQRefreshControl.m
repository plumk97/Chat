//
//  UIScrollView+MQRefreshControl.m
//  MQRefreshControl
//
//  Created by 货道网 on 15/6/2.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import "UIScrollView+MQRefreshControl.h"
#import <objc/runtime.h>

#define REFRESH_HEIGHT 64

#define MQREFRESH_TOP       "MQREFRESH_TOP"
#define MQREFRESH_BOTTOM    "MQREFRESH_BOTTOM"
#define MQREFRESH_LEFT      "MQREFRESH_LEFT"
#define MQREFRESH_RIGHT     "MQREFRESH_RIGHT"


// MARK: - 刷新旋转动画

@interface MQRefreshAnimation : UIView
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

@implementation MQRefreshAnimation

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

// MARK: - 刷新控件父类
@interface MQRefreshControl : UIView
{
    UIView * _backgroundView;
    
    BOOL _isCanRefresh;
    
    
    MQRefreshAnimation * _animationView;
@public
    BOOL _isRefreshing;
}

@property (nonatomic, strong) UIScrollView * scrollView;

@property (nonatomic, copy) void (^refresh) (RefreshDirection direction);


- (id)initWithFrame:(CGRect)frame ScrollView:(UIScrollView *)scrollView;

- (void)beganRefresh;
- (void)endRefresh;

@end
@implementation MQRefreshControl

- (id)initWithFrame:(CGRect)frame ScrollView:(UIScrollView *)scrollView
{
    self = [super initWithFrame:frame];
    if (self) {
        
        CGSize size = scrollView.contentSize;
        size.width = MAX(scrollView.frame.size.width, size.width);
        size.height = MAX(scrollView.frame.size.height, size.height);
        scrollView.contentSize = size;
        
        self.scrollView = scrollView;
        
        [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        
        _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0 - 999 + frame.size.height, frame.size.width, 999)];
        [self addSubview:_backgroundView];
        
        _animationView = [[MQRefreshAnimation alloc] initWithWidth:40 Distance:7];
        [self addSubview:_animationView];
        self.backgroundColor = [UIColor colorWithRed:238 / 255.0f green:238 / 255.0f blue:238 / 255.0f alpha:1];
    }
    return self;
}
- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    _backgroundView.backgroundColor = backgroundColor;
}
- (void)dealloc
{
    [_scrollView removeObserver:self forKeyPath:@"contentOffset"];
}
- (void)beganRefresh {
    [_animationView beginAnimation];
}
- (void)endRefresh {
    
    [_animationView endAnimation];
}

@end



// MARK: 头部刷新控件
@interface MQTopRefresh : MQRefreshControl
{
    
}

@end

@implementation MQTopRefresh


- (id)initWithFrame:(CGRect)frame ScrollView:(UIScrollView *)scrollView
{
    self = [super initWithFrame:frame ScrollView:scrollView];
    if (self) {
        
        scrollView.alwaysBounceVertical = YES;
        _animationView.center = CGPointMake(self.bounds.size.width / 2.0f , self.bounds.size.height / 2.0f + 5);
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    CGPoint point = self.scrollView.contentOffset;
    BOOL isDragging = self.scrollView.isDragging;
    if (_isRefreshing) {
        return;
    }
    if (point.y <= REFRESH_HEIGHT * -1 && isDragging) {
        _isCanRefresh = YES;
        
    } else if (isDragging) {
        _isCanRefresh = NO;
        
    }
    
    [_animationView rotatAngle:point.y * -1 * 2];
    
    [self shouldBeganRefresh];
}

/**
 *  是否可以开始刷新
 */
- (void)shouldBeganRefresh
{
    if (!self.scrollView.isDragging && _isCanRefresh && !_isRefreshing) {
        
        _isRefreshing = YES;
        UIEdgeInsets edge = self.scrollView.contentInset;
        edge.top += REFRESH_HEIGHT;
        
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.scrollView setContentInset:edge];
        } completion:^(BOOL finished) {
            
        }];
        
        [_animationView beginAnimation];
        
        // 回调block
        if (self.refresh) {
            self.refresh(RefreshDirection_Top);
        }
    }
}

- (void)beganRefresh
{
    [super beganRefresh];
    
    _isCanRefresh = YES;
    [self shouldBeganRefresh];
}

- (void)endRefresh
{
    [super endRefresh];
    
    _isCanRefresh = NO;
    if (_isRefreshing) {
        _isRefreshing = NO;
        UIEdgeInsets edge = self.scrollView.contentInset;
        edge.top -= REFRESH_HEIGHT;
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.scrollView setContentInset:edge];
        } completion:^(BOOL finished) {
            
        }];
    }
    
}
- (void)dealloc
{
    
}

@end

// MARK: - 底部刷新控件

@interface MQBottomRefresh : MQRefreshControl

@end

@implementation MQBottomRefresh

- (id)initWithFrame:(CGRect)frame ScrollView:(UIScrollView *)scrollView
{
    self = [super initWithFrame:frame ScrollView:scrollView];
    if (self) {
        
        scrollView.alwaysBounceVertical = YES;
        
        CGRect frame = _backgroundView.frame;
        frame.origin.y = 0;
        _backgroundView.frame = frame;
        
        _animationView.center = CGPointMake(self.bounds.size.width / 2.0f , self.bounds.size.height / 2.0f - 5);
        
        [scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentSize"]) {
        
        CGRect frame = self.frame;
        frame.origin.y = MAX(self.scrollView.frame.size.height, self.scrollView.contentSize.height);
        
        self.frame = frame;
        
        
        return;
    }
    CGPoint point = self.scrollView.contentOffset;
    point.y += self.scrollView.frame.size.height;
    BOOL isDragging = self.scrollView.isDragging;
    
    if (_isRefreshing) {
        return;
    }
    
    CGFloat value = MAX(self.scrollView.frame.size.height, self.scrollView.contentSize.height);
    
    if (point.y - value >= REFRESH_HEIGHT && isDragging) {
        _isCanRefresh = YES;
        
    } else if (isDragging) {
        _isCanRefresh = NO;
        
    }
    
    [_animationView rotatAngle:point.y];
    [self shouldBeganRefresh];
    
    
}


/**
 *  是否可以开始刷新
 */
- (void)shouldBeganRefresh
{
    if (!self.scrollView.isDragging && _isCanRefresh && !_isRefreshing) {
        
        _isRefreshing = YES;
        UIEdgeInsets edge = self.scrollView.contentInset;
        edge.bottom += REFRESH_HEIGHT;
        
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.scrollView setContentInset:edge];
        } completion:^(BOOL finished) {
            
        }];
        
        [_animationView beginAnimation];
        
        // 回调block
        if (self.refresh) {
            self.refresh(RefreshDirection_Bottom);
        }
    }
}

- (void)beganRefresh
{
    [super beganRefresh];
    
    _isCanRefresh = YES;
    [self shouldBeganRefresh];
}

- (void)endRefresh
{
    [super endRefresh];
    
    _isCanRefresh = NO;
    if (_isRefreshing) {
        _isRefreshing = NO;
        UIEdgeInsets edge = self.scrollView.contentInset;
        edge.bottom -= REFRESH_HEIGHT;
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.scrollView setContentInset:edge];
        } completion:^(BOOL finished) {
            
        }];
    }
    
}

- (void)dealloc
{
    [self.scrollView removeObserver:self forKeyPath:@"contentSize"];
}

@end


// MARK: - 左边刷新控件

@interface MQLeftRefresh : MQRefreshControl

@end

@implementation MQLeftRefresh

- (id)initWithFrame:(CGRect)frame ScrollView:(UIScrollView *)scrollView
{
    self = [super initWithFrame:frame ScrollView:scrollView];
    if (self) {
        self.scrollView.alwaysBounceHorizontal = YES;
        CGRect frame = _backgroundView.frame;
        frame.origin.y = 0;
        frame.origin.x = 0 - 999 + 64;
        frame.size.height = self.frame.size.height;
        frame.size.width = 999;
        _backgroundView.frame = frame;
        
        _animationView.center = CGPointMake(self.bounds.size.width / 2.0f , self.bounds.size.height / 2.0f);
        
        [scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect frame = _backgroundView.frame;
    frame.origin.y = 0;
    frame.origin.x = 0 - 999 + 64;
    frame.size.height = self.frame.size.height;
    frame.size.width = 999;
    _backgroundView.frame = frame;
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    if ([keyPath isEqualToString:@"contentSize"]) {
        
        CGRect frame = self.frame;
        frame.size.height = MAX(self.scrollView.frame.size.height, self.scrollView.contentSize.height);
        
        self.frame = frame;
        
        
        return;
    }
    CGPoint point = self.scrollView.contentOffset;
    BOOL isDragging = self.scrollView.isDragging;
    _animationView.center = CGPointMake(self.bounds.size.width / 2.0f , point.y + self.scrollView.frame.size.height / 2.0f);
    if (_isRefreshing) {
        return;
    }
    if (point.x <= REFRESH_HEIGHT * -1 && isDragging) {
        _isCanRefresh = YES;
        
    } else if (isDragging) {
        _isCanRefresh = NO;
        
    }
    
    [_animationView rotatAngle:point.x * -1];
    [self shouldBeganRefresh];
    
    
}


/**
 *  是否可以开始刷新
 */
- (void)shouldBeganRefresh
{
    if (!self.scrollView.isDragging && _isCanRefresh && !_isRefreshing) {
        
        _isRefreshing = YES;
        UIEdgeInsets edge = self.scrollView.contentInset;
        edge.left += REFRESH_HEIGHT;
        
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.scrollView setContentInset:edge];
        } completion:^(BOOL finished) {
            
        }];
        
        [_animationView beginAnimation];
        
        // 回调block
        if (self.refresh) {
            self.refresh(RefreshDirection_Left);
        }
    }
}

- (void)beganRefresh
{
    [super beganRefresh];
    
    _isCanRefresh = YES;
    [self shouldBeganRefresh];
}

- (void)endRefresh
{
    [super endRefresh];
    
    _isCanRefresh = NO;
    if (_isRefreshing) {
        _isRefreshing = NO;
        UIEdgeInsets edge = self.scrollView.contentInset;
        edge.left -= REFRESH_HEIGHT;
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.scrollView setContentInset:edge];
        } completion:^(BOOL finished) {
            
        }];
    }
    
}

- (void)dealloc
{
    [self.scrollView removeObserver:self forKeyPath:@"contentSize"];
}

@end

// MARK: - 右边刷新控件

@interface MQRightRefresh : MQRefreshControl

@end

@implementation MQRightRefresh

- (id)initWithFrame:(CGRect)frame ScrollView:(UIScrollView *)scrollView
{
    self = [super initWithFrame:frame ScrollView:scrollView];
    if (self) {
        self.scrollView.alwaysBounceHorizontal = YES;
    
        
        CGRect frame = _backgroundView.frame;
        frame.origin.y = 0;
        frame.origin.x = 0;
        frame.size.height = self.frame.size.height;
        frame.size.width = 999;
        _backgroundView.frame = frame;
        
        _animationView.center = CGPointMake(self.bounds.size.width / 2.0f , self.bounds.size.height / 2.0f);
        
        [scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect frame = _backgroundView.frame;
    frame.origin.y = 0;
    frame.origin.x = 0;
    frame.size.height = self.frame.size.height;
    frame.size.width = 999;
    _backgroundView.frame = frame;
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    if ([keyPath isEqualToString:@"contentSize"]) {
        
        CGRect frame = self.frame;
        frame.size.height = MAX(self.scrollView.frame.size.height, self.scrollView.contentSize.height);
        
        self.frame = frame;
        
        return;
    }
    
    CGPoint point = self.scrollView.contentOffset;
    BOOL isDragging = self.scrollView.isDragging;
    
    _animationView.center = CGPointMake(self.bounds.size.width / 2.0f , point.y + self.scrollView.frame.size.height / 2.0f);
    
    if (_isRefreshing) {
        return;
    }
    if (point.x >= REFRESH_HEIGHT && isDragging) {
        _isCanRefresh = YES;
        
    } else if (isDragging) {
        _isCanRefresh = NO;
        
    }
    
    [_animationView rotatAngle:point.x];
    [self shouldBeganRefresh];
    
    
}


/**
 *  是否可以开始刷新
 */
- (void)shouldBeganRefresh
{
    if (!self.scrollView.isDragging && _isCanRefresh && !_isRefreshing) {
        
        _isRefreshing = YES;
        UIEdgeInsets edge = self.scrollView.contentInset;
        edge.right += REFRESH_HEIGHT;
        
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.scrollView setContentInset:edge];
        } completion:^(BOOL finished) {
            
        }];
        
        [_animationView beginAnimation];
        
        // 回调block
        if (self.refresh) {
            self.refresh(RefreshDirection_Right);
        }
    }
}

- (void)beganRefresh
{
    [super beganRefresh];
    
    _isCanRefresh = YES;
    [self shouldBeganRefresh];
}

- (void)endRefresh
{
    [super endRefresh];
    
    _isCanRefresh = NO;
    if (_isRefreshing) {
        _isRefreshing = NO;
        UIEdgeInsets edge = self.scrollView.contentInset;
        edge.right -= REFRESH_HEIGHT;
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.scrollView setContentInset:edge];
        } completion:^(BOOL finished) {
            
        }];
    }
    
}

- (void)dealloc
{
    [self.scrollView removeObserver:self forKeyPath:@"contentSize"];
}

@end




@implementation UIScrollView (MQRefreshControl)

/**
 *  添加刷新控件
 *
 *  @param direction 刷新方向
 */
- (void)addRefreshControl:(RefreshDirection)direction
{
    const void *key = [self createKeyRefreshDirection:direction];
    MQRefreshControl * rc = objc_getAssociatedObject(self, key);
    if (!rc) {
        rc = [self createRefreshControl:direction];
        [self addSubview:rc];
        
        objc_setAssociatedObject(self, key, rc, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (const void *)createKeyRefreshDirection:(RefreshDirection)direction
{
    const void *key = NULL;
    switch (direction) {
        case RefreshDirection_Top:
            key = MQREFRESH_TOP;
            break;
        case RefreshDirection_Bottom:
            key = MQREFRESH_BOTTOM;
            break;
        case RefreshDirection_Left:
            key = MQREFRESH_LEFT;
            break;
        case RefreshDirection_Right:
            key = MQREFRESH_RIGHT;
            break;
        default:
            break;
    }
    return key;
}
- (MQRefreshControl *)createRefreshControl:(RefreshDirection)direction
{
    MQRefreshControl * rc = nil;
    switch (direction) {
        case RefreshDirection_Top:
        {
            rc = [[MQTopRefresh alloc] initWithFrame:CGRectMake(0, 0 - REFRESH_HEIGHT, self.frame.size.width, REFRESH_HEIGHT) ScrollView:self];
        }
            break;
        case RefreshDirection_Bottom:
        {
            rc = [[MQBottomRefresh alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, REFRESH_HEIGHT) ScrollView:self];
        }
            break;
        case RefreshDirection_Left:
        {
            rc = [[MQLeftRefresh alloc] initWithFrame:CGRectMake(0 - REFRESH_HEIGHT, 0, REFRESH_HEIGHT, self.frame.size.height) ScrollView:self];
        }
            break;
        case RefreshDirection_Right:
        {
            rc = [[MQRightRefresh alloc] initWithFrame:CGRectMake(self.frame.size.width, 0, REFRESH_HEIGHT, self.frame.size.height) ScrollView:self];
        }
            break;
        default:
            break;
    }
    return rc;
}

/**
 *  移除刷新控件
 */
- (void)removeRefresh:(RefreshDirection)direction
{
    const void *key = [self createKeyRefreshDirection:direction];
    
    MQRefreshControl * rc = objc_getAssociatedObject(self, key);
    if (rc) {
        [rc removeFromSuperview];
        rc = nil;
        objc_removeAssociatedObjects(self);
    }
}

/**
 *  设置刷新回调
 *
 *  @param block 在此代码中执行你需要的操作
 */
- (void)setRefreshBlock:(void (^)(RefreshDirection direction))block
{
    const void *key = [self createKeyRefreshDirection:RefreshDirection_Top];
    MQRefreshControl * rc = objc_getAssociatedObject(self, key);
    if (rc) {
        rc.refresh = block;
    }
    
    key = [self createKeyRefreshDirection:RefreshDirection_Bottom];
    rc = objc_getAssociatedObject(self, key);
    if (rc) {
        rc.refresh = block;
    }
    
    key = [self createKeyRefreshDirection:RefreshDirection_Left];
    rc = objc_getAssociatedObject(self, key);
    if (rc) {
        rc.refresh = block;
    }
    
    key = [self createKeyRefreshDirection:RefreshDirection_Right];
    rc = objc_getAssociatedObject(self, key);
    if (rc) {
        rc.refresh = block;
    }
}

/**
 *  开始刷新
 *
 *  @param direction 刷新方向
 */
- (void)beganRefreshDirection:(RefreshDirection)direction
{
    const void *key = [self createKeyRefreshDirection:direction];
    MQRefreshControl * rc = objc_getAssociatedObject(self, key);
    if (rc) {
        [rc beganRefresh];
    }
}
/**
 *  结束刷新
 *
 *  @param direction 刷新方向
 */
- (void)endRefreshDirection:(RefreshDirection)direction
{
    const void *key = [self createKeyRefreshDirection:direction];
    MQRefreshControl * rc = objc_getAssociatedObject(self, key);
    if (rc) {
        [rc endRefresh];
    }
}

/**
 *  是否在刷新中
 *
 *  @param direction 刷新方向
 *
 *  @return
 */
- (BOOL)isRefreshing:(RefreshDirection)direction
{
    const void *key = [self createKeyRefreshDirection:direction];
    MQRefreshControl * rc = objc_getAssociatedObject(self, key);
    if (rc) {
        return rc->_isRefreshing;
    }
    
    return NO;
}


@end
