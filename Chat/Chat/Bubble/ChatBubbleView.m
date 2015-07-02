//
//  ChatBubbleView.m
//  Chat
//
//  Created by 货道网 on 15/5/8.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import "ChatBubbleView.h"

@implementation ChatBubbleView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _bubbleImageView = [[UIImageView alloc] init];
        _bubbleImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_bubbleImageView];
        
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
        [self addGestureRecognizer:tap];
    
        UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [self addGestureRecognizer:longPress];
    }
    return self;
}

- (void)tapClick:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self postEventResponerType:BubblePressType_Press];
    }
   
}
- (void)longPress:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self postEventResponerType:BubblePressType_LongPress];
    }
}

- (void)postEventResponerType:(NSInteger)type
{
    if (self.eventResponer) {
        self.eventResponer (self.message, type);
    }
}

- (void)setMessage:(Message *)message
{
    _message = message;
    
    UIImage * image = [UIImage imageNamed:[message.isSender boolValue] ? RIGHT_BUBBLE_IMAGE : LEFT_BUBBLE_IMAGE];
    
    _bubbleImageView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height / 2 - 1, image.size.width / 2 - 1, image.size.height / 2 + 1, image.size.width / 2 + 1)];
    
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    if (_delegate && [_delegate respondsToSelector:@selector(bubbleViewChangeFrame:Frame:)]) {
        [_delegate bubbleViewChangeFrame:self Frame:frame];
    }
  
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.frame;
    frame.origin.y = 4;
    if ([self.message.isSender boolValue]) {
        frame.origin.x = [UIScreen mainScreen].bounds.size.width - frame.size.width;
    } else {
        frame.origin.x = 0;
    }
    
    self.frame = frame;
    
    
}

+ (CGFloat)heightForMessageModel:(Message *)message
{
    return 40;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
