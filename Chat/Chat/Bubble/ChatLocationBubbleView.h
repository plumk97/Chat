//
//  ChatLocationBubbleView.h
//  Chat
//
//  Created by 货道网 on 15/5/20.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import "ChatBubbleView.h"

@interface ChatLocationBubbleView : ChatBubbleView
{
    UIView * _contentView;
    
    UIImageView * _locationIcon;
    UILabel * _titleLabel;
    UILabel * _locationLabel;
}

@end
