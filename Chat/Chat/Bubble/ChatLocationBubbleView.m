//
//  ChatLocationBubbleView.m
//  Chat
//
//  Created by 货道网 on 15/5/20.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import "ChatLocationBubbleView.h"

@implementation ChatLocationBubbleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.clipsToBounds = YES;
        _contentView.layer.masksToBounds = YES;
        _contentView.layer.cornerRadius = 14.0f;
        [self addSubview:_contentView];
        
        _locationIcon = [[UIImageView alloc] init];
        _locationIcon.image = [UIImage imageNamed:@"chat_share_location@2x.png"];
        [_contentView addSubview:_locationIcon];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"位置分享";
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        [_contentView addSubview:_titleLabel];
        
        _locationLabel = [[UILabel alloc] init];
        _locationLabel.font = [UIFont systemFontOfSize:13];
        _locationLabel.textColor = [UIColor lightGrayColor];
        _locationLabel.numberOfLines = 0;
        [_contentView addSubview:_locationLabel];
    }
    return self;
}

- (void)setMessage:(Message *)message
{
    [super setMessage:message];
    _locationLabel.text = message.locationName;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.bounds;
    frame = CGRectInset(frame, INTERVAL_BUBBLE_WIDTH + 1, INTERVAL_BUBBLE_HEIGHT + 2);
    _contentView.frame = frame;
    
    frame.origin.y = (frame.size.height - 70) / 2;
    frame.origin.x = frame.origin.y;
    frame.size = CGSizeMake(70, 70);
    _locationIcon.frame = frame;
    
    frame.origin.x += frame.size.width + 5;
    frame.size = CGSizeMake(self.bounds.size.width - (frame.origin.x + INTERVAL_BUBBLE_WIDTH * 2 + 5), 20);
    _titleLabel.frame = frame;
    
    frame.origin.y += frame.size.height + 5;
    frame.size = CGSizeMake(frame.size.width, 0);
    frame.size.height = [_locationLabel.text boundingRectWithSize:CGSizeMake(frame.size.width, 100) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : _locationLabel.font} context:nil].size.height;
    _locationLabel.frame = frame;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake(250, 110);
}

+ (CGFloat)heightForMessageModel:(Message *)message
{
    return 110;
}

@end
