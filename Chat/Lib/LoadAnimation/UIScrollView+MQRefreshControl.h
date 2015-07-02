//
//  UIScrollView+MQRefreshControl.h
//  MQRefreshControl
//
//  Created by 货道网 on 15/6/2.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 刷新方向枚举
 如果设置为右刷新则 scrollView.contentSize.width 不能小于 scrollView.frame.size.width
 */
typedef enum : NSUInteger {
    RefreshDirection_Top,
    RefreshDirection_Bottom,
    RefreshDirection_Left,
    RefreshDirection_Right,
} RefreshDirection;


@interface UIScrollView (MQRefreshControl)

/**
 *  添加刷新控件
 *
 *  @param direction 刷新方向
 */
- (void)addRefreshControl:(RefreshDirection)direction;
/**
 *  移除刷新控件
 */
- (void)removeRefresh:(RefreshDirection)direction;

/**
 *  设置刷新回调
 *
 *  @param block 在此代码中执行你需要的操作
 */
- (void)setRefreshBlock:(void (^)(RefreshDirection direction))block;

/**
 *  开始刷新
 *
 *  @param direction 刷新方向
 */
- (void)beganRefreshDirection:(RefreshDirection)direction;
/**
 *  结束刷新
 *
 *  @param direction 刷新方向
 */
- (void)endRefreshDirection:(RefreshDirection)direction;

/**
 *  是否在刷新中
 *
 *  @param direction 刷新方向
 *
 *  @return
 */
- (BOOL)isRefreshing:(RefreshDirection)direction;
@end
