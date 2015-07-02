//
//  Chat_MoreAudioRecordView.h
//  Chat
//
//  Created by 货道网 on 15/5/22.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 *  此类录制音频
 */
@interface Chat_MoreAudioRecordView : UIView

/**
 *  录制音频完成回调block
 *
 *  @param block 
 */
- (void)succeedRecordAudio:(void (^) (int recordTime))block;

@end
