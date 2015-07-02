//
//  Chat_MoreFaceView.h
//  Chat
//
//  Created by 货道网 on 15/6/12.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    FaceType_Emoji,
    FaceType_Image,
} FaceType;

@interface Chat_MoreFaceView : UIView

@property (nonatomic, copy) void (^sendFace) (id object, FaceType type);
@property (nonatomic, copy) void (^sendClick) ();

@end
