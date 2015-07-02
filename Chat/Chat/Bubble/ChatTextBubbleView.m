//
//  ChatTextBubbleView.m
//  Chat
//
//  Created by 货道网 on 15/5/8.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import "ChatTextBubbleView.h"



#define MAX_TEXT_WIDTH 200
#define MIN_TEXT_WIDTH 60

#define TEXT_FONT_SIZE 15
@implementation ChatTextBubbleView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addSubview:self.textLabel];
        
    }
    return self;
}


- (UILabel *)textLabel
{
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textLabel.font = [UIFont systemFontOfSize:TEXT_FONT_SIZE];
        _textLabel.numberOfLines = 0;
        _textLabel.textColor = [UIColor whiteColor];
      
    }
    
    return _textLabel;
}

- (void)setMessage:(Message *)message
{
    [super setMessage:message];
    _textLabel.text = message.content;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.bounds;
    
    frame = CGRectInset(frame, INTERVAL_BUBBLE_WIDTH, INTERVAL_BUBBLE_HEIGHT);
    frame.size.width -= INTERVAL_BUBBLE_WIDTH;
    if ([self.message.isSender boolValue]) {
        frame.origin.x += INTERVAL_BUBBLE_WIDTH - 3;
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.textAlignment = NSTextAlignmentLeft;
        if (_textLabel.text.length <= 3) {
            _textLabel.textAlignment = NSTextAlignmentCenter;
            frame.origin.x -= INTERVAL_BUBBLE_WIDTH / 2.0f - 2;
        }
    } else {
        frame.origin.x += INTERVAL_BUBBLE_WIDTH / 2.0f + 3;
        _textLabel.textColor = [UIColor blackColor];
        _textLabel.textAlignment = NSTextAlignmentLeft;
        if (_textLabel.text.length <= 3) {
            _textLabel.textAlignment = NSTextAlignmentCenter;
            frame.origin.x = INTERVAL_BUBBLE_WIDTH + INTERVAL_BUBBLE_WIDTH / 2.0f;
        }
    }
    _textLabel.frame = frame;
 
}



- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize maxSize = CGSizeMake(MAX_TEXT_WIDTH + INTERVAL_BUBBLE_WIDTH * 2, CGFLOAT_MAX);
    CGSize calculateSize = CGSizeZero;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
    
    calculateSize = [self.message.content boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:TEXT_FONT_SIZE]} context:nil].size;
#else
    
    calculateSize = [self.message.content sizeWithFont:[UIFont systemFontOfSize:TEXT_FONT_SIZE] constrainedToSize:maxSize lineBreakMode:NSLineBreakByCharWrapping];
#endif
    
    calculateSize.width = MAX(MIN_TEXT_WIDTH, calculateSize.width + INTERVAL_BUBBLE_WIDTH * 2 + INTERVAL_BUBBLE_WIDTH);
    calculateSize.width += 10;
    calculateSize.height = MAX(35 + INTERVAL_BUBBLE_HEIGHT + 15, calculateSize.height + INTERVAL_BUBBLE_HEIGHT * 2 + 20);
    
    return calculateSize ;
}


+ (CGFloat)heightForMessageModel:(Message *)message
{
    CGSize maxSize = CGSizeMake(MAX_TEXT_WIDTH + INTERVAL_BUBBLE_WIDTH * 2, CGFLOAT_MAX);
    CGSize calculateSize = CGSizeZero;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
    
    calculateSize = [message.content boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:TEXT_FONT_SIZE]} context:nil].size;
#else
    
    calculateSize = [message.content sizeWithFont:[UIFont systemFontOfSize:TEXT_FONT_SIZE] constrainedToSize:maxSize lineBreakMode:NSLineBreakByCharWrapping];
#endif
    
    calculateSize.height = MAX(35 + INTERVAL_BUBBLE_HEIGHT + 15, calculateSize.height + INTERVAL_BUBBLE_HEIGHT * 2 + 20);
    
    return calculateSize.height ;
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
