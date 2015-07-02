//
//  ChatTableCellTimeView.m
//  Chat
//
//  Created by 货道网 on 15/5/11.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import "ChatTableCellTimeView.h"

@implementation ChatTableCellTimeView

- (id)init
{
    self = [super init];
    if (self) {
        timeLabel = [[UILabel alloc] init];
        timeLabel.font = [UIFont systemFontOfSize:11];
        timeLabel.textColor = [UIColor colorWithRed:245 / 255.0 green:245 / 255.0 blue:245 / 255.0 alpha:1];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.textAlignment = NSTextAlignmentCenter;
        timeLabel.layer.masksToBounds = YES;
        timeLabel.layer.cornerRadius = 5.0f;
        [self addSubview:timeLabel];
    }
    return self;
}
- (void)setTime:(NSString *)time
{
    _time = time;
    timeLabel.text = time;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    CGRect frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - 50) / 2, (45 - 20) / 2, 50, 20);
    timeLabel.frame = frame;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake([UIScreen mainScreen].bounds.size.width, 45);
}

@end
