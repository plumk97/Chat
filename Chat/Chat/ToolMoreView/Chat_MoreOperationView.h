//
//  Chat_MoreOperationView.h
//  Chat
//
//  Created by 货道网 on 15/5/15.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  此类包含 照片、拍摄、位置等操作
 */
@interface Chat_MoreOperationView : UIView

- (void)setDidSelectItemIndex:(void (^) (NSInteger))block;

@end
