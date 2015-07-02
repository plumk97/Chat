//
//  LoginTextField.m
//  Chat
//
//  Created by 货道网 on 15/5/4.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import "LoginTextField.h"

@implementation LoginTextField
@synthesize nameLabel;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.borderStyle = 0;
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, self.frame.size.height, self.frame.size.height)];
        nameLabel.text = self.tag == 1 ? @"账 号:" : @"密 码:";
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.font = [UIFont boldSystemFontOfSize:13];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:nameLabel];
        
    }
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    CGRect frame = [super textRectForBounds:bounds];
    frame.origin.x = 8 + bounds.size.height;
    frame.size.width -= frame.origin.x;
    
    return frame;
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds
{
    CGRect frame = [super placeholderRectForBounds:bounds];
    frame.origin.x = 8 + bounds.size.height;
    frame.size.width -= frame.origin.x;
    
    return frame;
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    CGRect frame = [super editingRectForBounds:bounds];
    frame.origin.x = 8 + bounds.size.height;
    frame.size.width -= frame.origin.x;
    
    return frame;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx, 1);
    CGContextSetRGBStrokeColor(ctx, 200 / 255.0, 200 / 255.0, 200 / 255.0, 1);
    
    
    CGContextMoveToPoint(ctx, 0, rect.size.height);
    CGContextAddLineToPoint(ctx, rect.size.width, rect.size.height);
    CGContextDrawPath(ctx, kCGPathStroke);
    
    
}


@end
