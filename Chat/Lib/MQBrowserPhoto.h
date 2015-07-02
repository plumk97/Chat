//
//  MQBrowserPhoto.h
//  Chat
//
//  Created by 货道网 on 15/5/21.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MQBrowserPhoto : UIView

// 使用这个方法初始化没有动画
- (id)initWithPhotos:(NSArray *)photos Index:(NSInteger)index;

// 使用这个方法初始化有动画
- (id)initWithPhotos:(NSArray *)photos Index:(NSInteger)index SuperView:(UIView *)superView OriginFrame:(CGRect)originFrame;


@end
