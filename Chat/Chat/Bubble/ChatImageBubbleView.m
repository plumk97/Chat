//
//  ChatImageBubbleView.m
//  Chat
//
//  Created by 货道网 on 15/5/16.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import "ChatImageBubbleView.h"
#import "UIKit+AFNetworking.h"

@implementation ChatImageBubbleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor whiteColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.layer.masksToBounds = YES;
        _imageView.layer.cornerRadius = 14.0f;
        [self addSubview:_imageView];
    }
    return self;
}


- (void)setMessage:(Message *)message
{
    [super setMessage:message];
    
    if ([message.isSender boolValue]) {
        [self downImage];
    } else {
        [self downThumbnailImage];
    }
}
- (void)downThumbnailImage
{
    
    UIImage * image = nil;
    image = [UIImage imageWithData:[MQChatUtil getDataFromLocationFileName:self.message.locationThumbanilImagePath Directory:DIRECTORY_IMAGE]];
    if (image) {
        self.message.image = image;
        self.imageView.image = image;
        return;
    }

    NSString * url = [[NSString alloc] initWithFormat:@"%@%@",RQHost,self.message.thumbnailPath];
    __weak typeof(self) weakSelf = self;
    [_imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakSelf.message.image = image;
        weakSelf.imageView.image = image;
        weakSelf.message.locationThumbanilImagePath = [MQChatUtil saveDataToLocationFileName:[MQChatUtil createFileName:[@"t_" stringByAppendingString:weakSelf.message.time]] Directory:DIRECTORY_IMAGE Data:UIImageJPEGRepresentation(image, 1)];
        [[MQChatManager sharedInstance].managedObjectContext save:nil];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
}


/**
 *  是自己发送的图片 先获取本地的图片 如果没有则代表这个账号在其他设备登陆获取的是网络值 所以获取缩略图
 */
- (void)downImage
{
    UIImage * image = nil;
    image = [UIImage imageWithData:[MQChatUtil getDataFromLocationFileName:[MQChatUtil createFileName:self.message.time] Directory:DIRECTORY_IMAGE]];
    if (image) {
        self.message.image = image;
        self.imageView.image = image;
        return;
    }
    [self downThumbnailImage];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.bounds;
    
    frame = CGRectInset(frame, INTERVAL_BUBBLE_WIDTH, INTERVAL_BUBBLE_HEIGHT + 1);
    _imageView.frame = frame;
    
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake([self.message.imageWidth floatValue], [self.message.imageHeight floatValue]);
}

+ (CGFloat)heightForMessageModel:(Message *)message
{
    return [message.imageHeight floatValue];
}

@end
