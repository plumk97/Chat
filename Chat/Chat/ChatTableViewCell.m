//
//  ChatTableViewCell.m
//  Chat
//
//  Created by 货道网 on 15/5/8.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import "ChatTableViewCell.h"

/**
 显示当前信息发送状态
 */
@interface ActivityStateView : UIView
{
    UIActivityIndicatorView * indicatorView;
    UIButton * againButton;
}

@property (nonatomic, weak) ChatTableViewCell * weakCell;

@end

@implementation ActivityStateView

- (id)init
{
    self = [super init];
    if (self) {
        
        indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        [self addSubview:indicatorView];
        
        againButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [againButton setImage:[UIImage imageNamed:@"chat_warning"] forState:UIControlStateNormal];
        againButton.frame = CGRectMake(0, 0, 25, 25);
        againButton.hidden = YES;
        [againButton addTarget:self action:@selector(againClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:againButton];
    }
    return self;
}

- (void)againClick:(UIButton *)sender
{
    [self hideAllView];
    [self showActivity];
    
    Message * message = self.weakCell.message;
    message.state = [NSNumber numberWithInt:MessageSendState_Sending];
    [[MQChatManager sharedInstance].managedObjectContext save:nil];
    [MQChatManager asyncAgainSendMessage:self.weakCell.message];
}

- (void)showActivity
{
    [indicatorView startAnimating];
}
- (void)showAgainButton {
    againButton.hidden = NO;
}
- (void)hideAllView
{
    againButton.hidden = YES;
    [indicatorView stopAnimating];
}

@end


@interface ChatTableViewCell ()
<ChatBubbleViewDelegate>
{
    ActivityStateView * stateView;
}
@end

@implementation ChatTableViewCell
@synthesize bubbleView;

- (id)initWithMessageModel:(Message *)message
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ChatTableViewCell cellIdentifierForMessageModel:message]];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // 时间类型
        if ([message isKindOfClass:[NSString class]]) {
            _timeView = (ChatTableCellTimeView *)[self prepareBubbleViewForModel:message];
            [self.contentView addSubview:_timeView];
        } else {
            bubbleView = (ChatBubbleView *)[self prepareBubbleViewForModel:message];
            [self.contentView addSubview:bubbleView];
        }
        
        stateView = [[ActivityStateView alloc] init];
        stateView.weakCell = self;
        [self.contentView addSubview:stateView];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}



- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)setMessage:(id)message
{
    _message = message;
    
    if ([message isKindOfClass:[NSString class]]) {
        _timeView.time = message;
    } else {
        bubbleView.delegate = self;
        bubbleView.message = message;
        [bubbleView sizeToFit];
    }
}

/**
 *  根据 model 返回不同类型的 bubbleView
 *
 *  @param model
 *
 *  @return bubbleview
 */
- (UIView *)prepareBubbleViewForModel:(Message *)message
{
    UIView * bubble = nil;
    
    // 时间类型
    if ([message isKindOfClass:[NSString class]]) {
        bubble = [[ChatTableCellTimeView alloc] init];
        return bubble;
    }
    
    switch ([message.type integerValue]) {
        case MessageType_Text:
        {
            bubble = [[ChatTextBubbleView alloc] init];
        }
            break;
        case MessageType_Image:
        {
            bubble = [[ChatImageBubbleView alloc] init];
        }
            break;
        case MessageType_Location:
        {
            bubble = [[ChatLocationBubbleView alloc] init];
        }
            break;
        case MessageType_Audio:
        {
            bubble = [[ChatAudioBubbleView alloc] init];
        }
            break;
        default:
            break;
    }
    
    return bubble;
    
    
}

+ (CGFloat)heightForMessageModel:(Message *)message
{
    CGFloat height = 45;
    
    // 时间类型
    if ([message isKindOfClass:[NSString class]]) {
        return height;
    }
    
    switch ([message.type integerValue]) {
        case MessageType_Text:
            height = [ChatTextBubbleView heightForMessageModel:message];
            break;
        case MessageType_Image:
            height = [ChatImageBubbleView heightForMessageModel:message];
            break;
        case MessageType_Location:
            height = [ChatLocationBubbleView heightForMessageModel:message];
            break;
        case MessageType_Audio:
            height = [ChatAudioBubbleView heightForMessageModel:message];
            break;
        default:
            break;
    }
    
    return height;
}


+ (NSString *)cellIdentifierForMessageModel:(Message *)message
{
    NSString *identifier = @"MessageCell";
    
    // 时间类型
    if ([message isKindOfClass:[NSString class]]) {
        identifier = [identifier stringByAppendingString:@"Time"];
        return identifier;
    }
    
    if ([message.isSender boolValue]) {
        identifier = [identifier stringByAppendingString:@"Sender"];
    }
    else{
        identifier = [identifier stringByAppendingString:@"Receiver"];
    }
    
    
    switch ([message.type integerValue]) {
        case MessageType_Text:
        {
            identifier = [identifier stringByAppendingString:@"Text"];
        }
            break;
        case MessageType_Image:
        {
            identifier = [identifier stringByAppendingString:@"Image"];
        }
            break;
        case MessageType_Location:
        {
            identifier = [identifier stringByAppendingString:@"Location"];
        }
            break;
        case MessageType_Audio:
        {
            identifier = [identifier stringByAppendingString:@"Audio"];
        }
            break;
        default:
            break;
    }
    
    return identifier;
}


// MARK: - ChatBubbleView Delegate

- (void)bubbleViewChangeFrame:(ChatBubbleView *)bubbleView Frame:(CGRect)frame
{
    CGRect stateFrame = CGRectMake(0, 0, 30, 30);
    
    Message * mess = self.message;
    
    if ([mess.isSender boolValue]) {
        stateFrame.origin.x = frame.origin.x - 20;
    } else {
        stateFrame.origin.x = frame.origin.x + frame.size.width;
    }
    stateFrame.origin.y = frame.size.height - 25;
    
    switch ([mess.state integerValue]) {
        case MessageSendState_Fail:
            [stateView showAgainButton];
            break;
        case MessageSendState_Sending:
            [stateView showActivity];
            break;
        case MessageSendState_Succeed:
            [stateView hideAllView];
            break;
        default:
            break;
    }
    if (![mess.isSender boolValue]) {
        [stateView hideAllView];
    }
    
    stateView.frame = stateFrame;
}



- (BOOL)canBecomeFirstResponder
{
    return YES;
}
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{

    if (action == @selector(menuItemCopy:) || action == @selector(menuItemDelete:) || action == @selector(menuItemAgain:)) {
        return YES;
    }
    return NO;
}

- (void)menuItemCopy:(id)sender
{
    Message * mess = self.message;
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    switch ([mess.type integerValue]) {
        case MessageType_Text:
            pasteboard.string = mess.content;
            break;
        case MessageType_Location:
            pasteboard.string = mess.locationName;
            break;
        case MessageType_Image:
            pasteboard.image = mess.image;
            break;
        default:
            break;
    }
    if (self.menuItemClick) {
        self.menuItemClick(self, MenuItemType_Copy);
    }
}

- (void)menuItemDelete:(id)sender
{
    [[MQChatManager sharedInstance] removeMessage:self.message IsRemoveServer:NO];
    if (self.menuItemClick) {
        self.menuItemClick(self, MenuItemType_Delete);
    }
}

- (void)menuItemAgain:(id)sender {

    if (self.menuItemClick) {
        self.menuItemClick(self, MenuItemType_Again);
    }
}

@end
