//
//  ChatViewController.m
//  Chat
//
//  Created by 货道网 on 15/5/4.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatTableViewCell.h"
#import "ChatLogViewController.h"

#import "Chat_MoreOperationView.h"
#import "Chat_MoreAudioRecordView.h"
#import "Chat_MoreFaceView.h"
#import "ChatLocationViewController.h"

#import "Session.h"
#import "Message.h"

#define MaxOpenHeight 100

@class ChatToolBar;
@protocol ChatToolBarDelegate <ChatLocationDelegate>

- (void)chatToolBar:(ChatToolBar *)toolBar ShowHeight:(CGFloat)height;
- (void)chatToolBar:(ChatToolBar *)toolBar SendContent:(NSString *)content;

@end



@interface ChatToolBar : UIView
<UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

{
    UITextView * contentTextView;
    UIControl * touchResignFirstResponderController;
    
    CGFloat curShowHeight;
    CGFloat inputHeight;
    CGFloat invHeight;
    
    
    UIButton * preOperBtn;
    BOOL isUpMoreView;
}

@property (nonatomic, assign) id<ChatToolBarDelegate> delegate;
@property (nonatomic, strong) UIView * moreView;
@property (nonatomic, strong) Chat_MoreOperationView * moreOperationView;
@property (nonatomic, strong) Chat_MoreAudioRecordView * moreAudioRecordView;
@property (nonatomic, strong) Chat_MoreFaceView * moreFaceView;

@property (nonatomic, copy) NSString * content;

@property (nonatomic, copy) void (^selectImagesCall) (NSArray *);

/**
 *  添加内容
 *
 *  @param content 内容
 */
- (void)appContent:(NSString *)content;

/**
 *  删除内容最后一个文字
 */
- (void)removeLastOneContent;

@end

@implementation ChatToolBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        self.backgroundColor = [UIColor colorWithRed:235 / 255.0 green:236 / 255.0 blue:238 / 255.0 alpha:1];
        [self layoutView];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti:) name:UIKeyboardWillChangeFrameNotification object:nil];

    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (UIView *)moreView
{
    if (!_moreView) {
        _moreView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, self.frame.size.width, 200)];
        _moreView.backgroundColor = [UIColor colorWithRed:235 / 255.0 green:236 / 255.0 blue:238 / 255.0 alpha:1];
    }
    return _moreView;
}

- (void)setContent:(NSString *)content
{
    contentTextView.text = content;
    [self calueText:contentTextView];
}
- (NSString *)content
{
    return contentTextView.text;
}


- (void)appContent:(NSString *)content
{
    
    contentTextView.text = [contentTextView.text stringByAppendingString:content];
    [contentTextView scrollRangeToVisible:NSMakeRange(contentTextView.text.length, 0)];
    [self calueText:contentTextView];
}

/**
 *  删除内容最后一个
 */
- (void)removeLastOneContent
{
    if (contentTextView.text.length == 0) {
        return;
    }
    unichar c;
    int length = 1;
    [contentTextView.text getCharacters:&c range:NSMakeRange(contentTextView.text.length - 1, 1)];
    
    // emoji 表情占2个字符
    if (c >= 56000) {
        length = 2;
    }
    
    contentTextView.text = [contentTextView.text stringByReplacingCharactersInRange:NSMakeRange(contentTextView.text.length - length, length) withString:@""];
    [contentTextView scrollRangeToVisible:NSMakeRange(contentTextView.text.length, 0)];
    [self calueText:contentTextView];
}

/**
 *  初始化界面布局
 */
- (void)layoutView
{
    
    UIButton * recordBtn = [self defultButton:[UIImage imageNamed:@"chat_bottom_voice_nor@3x.png"]
                                   PressImage:[UIImage imageNamed:@"chat_bottom_voice_press@3x.png"]
                                  SelectImage:[UIImage imageNamed:@"chat_bottom_keyboard_nor@3x.png"]
                                          Method:@selector(btnClick:)
                                        Frame:CGRectMake(5, (self.frame.size.height - (self.frame.size.height - 10)) / 2, self.frame.size.height - 10, self.frame.size.height - 10)];
    recordBtn.tag = 10;
    [self addSubview:recordBtn];
    
    
    contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(recordBtn.frame.origin.x + recordBtn.frame.size.width + 5, (self.frame.size.height - (self.frame.size.height - 8)) / 2, self.frame.size.width - self.frame.size.height * 3 + 5, self.frame.size.height - 8)];
    contentTextView.font = [UIFont systemFontOfSize:15];
    contentTextView.layer.cornerRadius = 5.0f;
    contentTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    contentTextView.layer.borderWidth = 1 / [UIScreen mainScreen].scale / 2.0f;
    contentTextView.returnKeyType = UIReturnKeySend;
    contentTextView.delegate = self;
    contentTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight |  UIViewAutoresizingFlexibleWidth;
    [self addSubview:contentTextView];
    
    inputHeight = contentTextView.frame.size.height;
    invHeight = self.frame.size.height - contentTextView.frame.size.height;
    
    
    
    UIButton * faceBtn = [self defultButton:[UIImage imageNamed:@"chat_bottom_smile_nor@3x.png"]
                                   PressImage:[UIImage imageNamed:@"chat_bottom_smile_press@3x.png"]
                                  SelectImage:[UIImage imageNamed:@"chat_bottom_keyboard_nor@3x.png"]
                                       Method:@selector(btnClick:)
                                        Frame:CGRectMake(self.frame.size.width - self.frame.size.height * 2 + 12.5, (self.frame.size.height - (self.frame.size.height - 10)) / 2, self.frame.size.height - 10, self.frame.size.height - 10)];
    faceBtn.tag = 11;
    [self addSubview:faceBtn];
    
    
    UIButton * moreBtn = [self defultButton:[UIImage imageNamed:@"chat_bottom_up_nor@3x.png"]
                                 PressImage:[UIImage imageNamed:@"chat_bottom_up_press@3x.png"]
                                SelectImage:[UIImage imageNamed:@"chat_bottom_keyboard_nor@3x.png"]
                                     Method:@selector(btnClick:)
                                      Frame:CGRectMake(self.frame.size.width - self.frame.size.height + 5, (self.frame.size.height - (self.frame.size.height - 10)) / 2, self.frame.size.height - 10, self.frame.size.height - 10)];
    moreBtn.tag = 12;
    [self addSubview:moreBtn];
    
    __weak typeof(self) weakSelf = self;
    _moreOperationView = [[Chat_MoreOperationView alloc] initWithFrame:self.moreView.bounds];
    [_moreOperationView setDidSelectItemIndex:^(NSInteger index) {
        [weakSelf dealSelectIndex:index];
    }];
    [self.moreView addSubview:self.moreOperationView];
    
    _moreAudioRecordView = [[Chat_MoreAudioRecordView alloc] initWithFrame:self.moreView.bounds];
    [self.moreView addSubview:self.moreAudioRecordView];
    
    _moreFaceView = [[Chat_MoreFaceView alloc] initWithFrame:self.moreView.bounds];
    [self.moreView addSubview:self.moreFaceView];
}

/**
 *  处理选择的事件
 *
 *  @param index 选择了第几个
 */
- (void)dealSelectIndex:(NSInteger)index
{
    /*
     * 0 : 选取相册中的图片
     * 1 : 拍照
     * 2 : 语音
     * 3 : 位置
     */
    
    switch (index) {
        case 0:
        {
            UIImagePickerController * picker = [[UIImagePickerController alloc] init];
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            picker.allowsEditing = NO;
            picker.delegate = self;
            [self.window.rootViewController presentViewController:picker animated:YES completion:nil];
        }
            break;
        case 1:
        {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                UIImagePickerController * picker = [[UIImagePickerController alloc] init];
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                picker.allowsEditing = NO;
                picker.delegate = self;
                [self.window.rootViewController presentViewController:picker animated:YES completion:nil];
            }
        }
            break;
        case 2:
        {
            [[MQChatManager sharedInstance] beginVoiceChatUsername:[MQChatManager sharedInstance].currentSession.to];
        }
            break;
        case 3:
        {
            ChatLocationViewController * location = [[ChatLocationViewController alloc] init];
            location.delegate = self.delegate;
            [(UINavigationController *)self.window.rootViewController pushViewController:location animated:YES];
        }
            break;
        default:
            break;
    }
}

/**
 *  快速创建默认的 Button
 *
 *  @param image       默认Image
 *  @param pressImage  按下Image
 *  @param selectImage 选中Image
 *  @param method      触发方法
 *  @param frame
 *
 *  @return <#return value description#>
 */
- (UIButton *) defultButton:(UIImage *)image PressImage:(UIImage *)pressImage SelectImage:(UIImage *)selectImage Method:(SEL)method Frame:(CGRect)frame
{
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:image forState:UIControlStateNormal];
    [btn setImage:pressImage forState:UIControlStateHighlighted];
    [btn setImage:selectImage forState:UIControlStateSelected];
    [btn addTarget:self action:method forControlEvents:UIControlEventTouchUpInside];
    btn.frame = frame;
    return btn;
}

- (void)btnClick:(UIButton *)sender
{
    if (preOperBtn == sender) {
        return;
    }
    self.moreOperationView.hidden = YES;
    self.moreAudioRecordView.hidden = YES;
    self.moreFaceView.hidden = YES;
    switch (sender.tag) {
        case 10:
            self.moreAudioRecordView.hidden = NO;
            break;
        case 11:
            self.moreFaceView.hidden = NO;
            break;
        case 12:
            self.moreOperationView.hidden = NO;
            break;
        default:
            break;
    }
    
    if (!isUpMoreView) {
        [contentTextView resignFirstResponder];
        CGFloat height = 0;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
        [self addTouchResignFirstResponder];
        height = self.moreView.frame.size.height;
        CGRect frame = self.moreView.frame;
        frame.origin.y = [UIScreen mainScreen].bounds.size.height - frame.size.height - 64;
#else
        height = self.moreView.frame.size.height;
        frame.origin.y = [UIScreen mainScreen].bounds.size.height - frame.size.height;
#endif
        [UIView animateWithDuration:0.25 animations:^{
            self.moreView.frame = frame;
            [self willShowButtomHeight:height];
        }];
        
        preOperBtn = sender;
    }

}

/**
 *  取消显示MoreView
 */
- (void)cancelMoreView
{
    
    CGRect frame = self.moreView.frame;
    frame.origin.y = [UIScreen mainScreen].bounds.size.height;
    [UIView animateWithDuration:0.25 animations:^{
        self.moreView.frame = frame;
        [self willShowButtomHeight:0];
    } completion:^(BOOL finished) {
    }];
    preOperBtn = nil;
    isUpMoreView = NO;
}

/**
 *  键盘通知接受方法
 *
 *  @param noti <#noti description#>
 */
- (void)noti:(NSNotification *)noti
{
    NSDictionary * userInfo = noti.userInfo;
    
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect beginFrame = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    
    void(^animations)() = ^{
        [self willShowKeyboardFromFrame:beginFrame toFrame:endFrame];
    };
    
    void(^completion)(BOOL) = ^(BOOL finished){
    };
    
    [UIView animateWithDuration:duration delay:0.0f options:(curve << 16 | UIViewAnimationOptionBeginFromCurrentState) animations:animations completion:completion];
    
}

/**
 *  通过键盘的frame 计算出要弹起的高度
 *
 *  @param beginFrame 起始Frame
 *  @param toFrame    结束Frame
 */
- (void)willShowKeyboardFromFrame:(CGRect)beginFrame toFrame:(CGRect)toFrame
{
    CGFloat height = 0;
    if (toFrame.origin.y == [UIScreen mainScreen].bounds.size.height) {
        [self deleteTouchResignFirstResponder];
    } else {
        [self cancelMoreView];
        [self addTouchResignFirstResponder];
        height = toFrame.size.height;
    }
    
    
    [self willShowButtomHeight:height];
}

/**
 *  设置将要弹起的高度
 *
 *  @param height 高度
 */
- (void)willShowButtomHeight:(CGFloat)height
{
    
    CGRect frame = self.frame;
    CGFloat inv = 0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        inv = 64;
    }
    frame.origin.y = self.window.frame.size.height - height - frame.size.height - inv;
    self.frame = frame;
    
    if (_delegate && [_delegate respondsToSelector:@selector(chatToolBar:ShowHeight:)] && curShowHeight != height) {
        [_delegate chatToolBar:self ShowHeight:height];
    }
    curShowHeight = height;
}

/**
 *  添加点击屏幕取消键盘control
 */
- (void)addTouchResignFirstResponder
{
    if (!touchResignFirstResponderController) {
        touchResignFirstResponderController = [[UIControl alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [touchResignFirstResponderController addTarget:self action:@selector(touchResignFirstResponder:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.superview insertSubview:touchResignFirstResponderController belowSubview:self];
    }
}

/**
 *  删除点击屏幕取消键盘control
 */

- (void)deleteTouchResignFirstResponder
{
    [touchResignFirstResponderController removeFromSuperview];
    touchResignFirstResponderController = nil;
}

/**
 *  点击屏幕取消键盘事件
 *
 *  @param control
 */
- (void)touchResignFirstResponder:(UIControl *)control
{
    NSLog(@"touch");
    [self cancelMoreView];
    [contentTextView resignFirstResponder];
    [self deleteTouchResignFirstResponder];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


// MARK: - Picker Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage * image = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (self.selectImagesCall) {
        self.selectImagesCall (@[image]);
    }
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

// MARK: - TextView Delegate

- (void)textViewDidChange:(UITextView *)textView
{
    [self calueText:textView];
}

- (void)calueText:(UITextView *)textView
{
    CGSize size = CGSizeZero;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
        CGRect frame = [textView.text boundingRectWithSize:CGSizeMake(textView.frame.size.width, 999) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : textView.font} context:nil];
        size = frame.size;
#else
        size = [textView.text sizeWithFont:textView.font constrainedToSize:CGSizeMake(textView.frame.size.width, 999)];
#endif
    
    
    CGRect inputBoudns = [contentTextView frame];
    CGRect boudns = [self frame];
    
    inputBoudns.size.height = size.height > inputHeight ? size.height > MaxOpenHeight ? MaxOpenHeight : size.height : inputHeight;
    
    boudns.size.height = inputBoudns.size.height + invHeight;
    self.frame = boudns;
    contentTextView.frame = inputBoudns;
    
    
    [self willShowButtomHeight:curShowHeight];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        
        if (_delegate && [_delegate respondsToSelector:@selector(chatToolBar:SendContent:)]) {
            [_delegate chatToolBar:self SendContent:textView.text];
            textView.text = @"";
            [self calueText:textView];
        }
        return NO;
    }
    return YES;
}

@end

@interface ChatViewController ()
<UITableViewDataSource, UITableViewDelegate, ChatToolBarDelegate, ChatManagerDelegate>
{
    CGRect originFrame;
    
    BOOL isLoadMessageing;
    BOOL isCanLoadMessage;
    
    NSDate * lastSendDate;
    NSInteger sumMessageCount;
    
    Message * prePlayMessage; // 上一个播放语音的message

    void (^_eventResponer) (Message * message, BubblePressType type);
    void (^_menuItemClick) (ChatTableViewCell * cell ,MenuItemType type);
    
}

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) ChatToolBar * toolBar;
@property (nonatomic, strong) NSMutableArray * dataArr;
@property (nonatomic, strong) Session * session;
@property (nonatomic, strong) UIActivityIndicatorView * loadActivityView;
@property (nonatomic, strong) UIMenuController * menuController;

@end

@implementation ChatViewController
@synthesize username;

- (id)initWithUserName:(NSString *)_userName
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        username = _userName;
        
        _session = [MQChatManager sessionForUserName:username Default:YES];
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.title = self.username;
    UIImageView * backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"face2add_bg_morning@2x.png"]];
    backgroundImageView.frame = self.view.bounds;
    backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:backgroundImageView];

    [self.view addSubview:self.tableView];
    [self.view addSubview:self.toolBar];
    [self.view addSubview:self.loadActivityView];
    originFrame = self.tableView.frame;
    [self.view addSubview:self.toolBar.moreView];
    
    self.dataArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    // 添加接受信息代理
    [[MQChatManager sharedInstance] addDelegate:self];

    isCanLoadMessage = YES;
    [self loadMoreMessage];
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"聊天记录" style:UIBarButtonItemStylePlain target:self action:@selector(rightItemClick:)];
    
    
    /* 以下是照片选取等回调 */
    
    __weak typeof(self) weakSelf = self;
    self.toolBar.selectImagesCall = ^(NSArray *images) {
        
        for (UIImage * image in images) {
            [weakSelf sendImage:image];
            
        }
    };
    
    
    [self.toolBar.moreAudioRecordView succeedRecordAudio:^(int recordTime) {
        [weakSelf sendAudioRecordTime:recordTime];
    }];
    
    self.toolBar.moreFaceView.sendClick = ^{
        if ([weakSelf.toolBar.content isEqualToString:@""]) {
            return ;
        }
        [weakSelf sendContent:weakSelf.toolBar.content];
        weakSelf.toolBar.content = @"";
    };
    self.toolBar.moreFaceView.sendFace = ^(id object, FaceType type) {
        if (type == FaceType_Emoji) {
            if ([object isKindOfClass:[UIImage class]]) {
                
                [weakSelf.toolBar removeLastOneContent];
                return ;
            }
            [weakSelf.toolBar appContent:object];
        }
    };
    
    // MARK: -- bubble 点击或者长按
    _eventResponer = ^(Message * message, BubblePressType type) {
        if (type == BubblePressType_Press) {
            
            switch ([message.type integerValue]) {
                case MessageType_Text:
                    [weakSelf textPressMessage:message];
                    break;
                case MessageType_Image:
                    [weakSelf imagePressMessage:message];
                    break;
                case MessageType_Location:
                    [weakSelf locationPressMessage:message];
                    break;
                case MessageType_Audio:
                    [weakSelf audioPressMessage:message];
                    break;
                default:
                    break;
            }
            
        } else if (type == BubblePressType_LongPress) {
            
            ChatTableViewCell * cell = (ChatTableViewCell *)[weakSelf.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[weakSelf.dataArr indexOfObject:message] inSection:0]];
            [weakSelf longPressMessage:message Cell:cell];
        }
    };
    
    // MARK: -- menuItem点击
    _menuItemClick = ^(ChatTableViewCell * cell ,MenuItemType type) {
        NSIndexPath * indexPath = [weakSelf.tableView indexPathForCell:cell];
        
        if (type == MenuItemType_Delete) {
            
            // 判断当前cell 的上一个是不是时间cell 如果是则删除
            NSIndexPath * indexPath1 = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:0];
            ChatTableViewCell * tmpCell = (ChatTableViewCell *)[weakSelf.tableView cellForRowAtIndexPath:indexPath1];
            NSArray * indexPaths = nil;
            if ([tmpCell.message isKindOfClass:[NSString class]] && indexPath1.row == weakSelf.dataArr.count - 2) {
                indexPaths = @[indexPath, indexPath1];
                [weakSelf.dataArr removeObjectAtIndex:indexPath.row];
                [weakSelf.dataArr removeObjectAtIndex:indexPath1.row];
            } else {
                indexPaths = @[indexPath];
                [weakSelf.dataArr removeObjectAtIndex:indexPath.row];
            }
            
            [weakSelf.tableView beginUpdates];
            [weakSelf.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
            [weakSelf.tableView endUpdates];
        } else if (type == MenuItemType_Again) {
            Message * mess = cell.message;
            Message * cloneMessage = [mess clone];
            cloneMessage.state = [NSNumber numberWithInt:MessageSendState_Sending];
            
            [weakSelf.dataArr removeObject:mess];
            [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            
            [[MQChatManager sharedInstance].managedObjectContext deleteObject:mess];
            [[MQChatManager sharedInstance].managedObjectContext save:nil];
            
            
            [MQChatManager asyncAgainSendMessage:cloneMessage];
            [weakSelf isNeedAddTimeCell];
            [weakSelf addMessage:cloneMessage];
        }
    };
}


- (void)rightItemClick:(UIBarButtonItem *)sender
{
    ChatLogViewController * log1 = [[ChatLogViewController alloc] init];
    
    __unsafe_unretained __block typeof(self) weakSelf = self;
    [log1 succeedServerChatRecoder:^{
        weakSelf->isCanLoadMessage = YES;
        [weakSelf.dataArr removeAllObjects];
        [weakSelf loadMoreMessage];
    }];
    [self.navigationController pushViewController:log1 animated:YES];
}

- (void)dealloc
{
    [[MQChatManager sharedInstance] stopPlayerVoice];
    [[MQChatManager sharedInstance] nullCurrentSession];
    [[MQChatManager sharedInstance] removeDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (ChatToolBar *)toolBar
{
    if (!_toolBar) {
        _toolBar = [[ChatToolBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
        _toolBar.delegate = self;
        _toolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    }
    return _toolBar;
}
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.separatorColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        CGRect frame = _tableView.frame;
        frame.size.height -= self.toolBar.frame.size.height;
        _tableView.frame = frame;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _tableView.backgroundColor = [UIColor clearColor];
        UIEdgeInsets edge = _tableView.contentInset;
        edge.top += 20;
        edge.bottom += 20;
        _tableView.contentInset = edge;
    }
    
    return _tableView;
}

- (UIActivityIndicatorView *)loadActivityView
{
    if (!_loadActivityView) {
        _loadActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _loadActivityView.frame = CGRectMake((self.view.frame.size.width - 30) / 2, 10, 30, 30);
    }
    return _loadActivityView;
}

/**
 *  加载更多的信息
 */
- (void)loadMoreMessage
{
    if (!isCanLoadMessage) {
        return;
    }
    [self.loadActivityView startAnimating];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Message"];
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"messageId" ascending:NO];
        [request setSortDescriptors:[NSArray arrayWithObject:sort]];
        request.predicate = [NSPredicate predicateWithFormat:@"session == %@",self.session];
        request.fetchLimit = 10;
        request.fetchOffset = self.dataArr.count;
        NSError * error;
        NSArray * result = [[MQChatManager sharedInstance].managedObjectContext executeFetchRequest:request error:&error];
        if (error) {
            NSLog(@"%@",error);
        }
        if (result.count > 0) {
            result = [result reversalArray];
            NSDate * tmpDate;
            result = [MQChatManager inserTimeToMessages:result LastDate:&tmpDate];
            lastSendDate = tmpDate;
            NSInteger currentCount = result.count;
            NSMutableArray * mArr = [[NSMutableArray alloc] initWithArray:result];
            [mArr addObjectsFromArray:self.dataArr];
            [self.dataArr setArray:mArr];
            
            if (self.dataArr.count > 0) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:currentCount - 1 inSection:0];
                    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                });
            }
        }
        if (result.count == 0 || result.count < 10) {
            isCanLoadMessage = NO;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loadActivityView stopAnimating];
        });
        
        isLoadMessageing = NO;
    });
    
}

- (void)addMessage:(Message *)mess
{
    [self.dataArr addObject:mess];
    
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:self.dataArr.count - 1 inSection:0];
    
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    });
    
}
// MARK: - 各种信息点击

- (void)textPressMessage:(Message *)message
{
    NSLog(@"点击了信息");
}

- (void)locationPressMessage:(Message *)message
{
    ChatLocationViewController * location = [[ChatLocationViewController alloc] init];
    location.message = message;
    [self.navigationController pushViewController:location animated:YES];
}

- (void)audioPressMessage:(Message *)message
{
    if (message == prePlayMessage && message.isPlaying) {
        message.isPlaying = NO;
        [[MQChatManager sharedInstance] stopPlayerVoice];
        return;
    }
    prePlayMessage.isPlaying = NO;
    message.isPlaying = YES;
    prePlayMessage = message;
    
    NSData * data = [NSData dataWithContentsOfFile:[MQChatUtil createFileNameToLocalPath:[MQChatUtil createFileName:message.time Suffix:@"wav"] Directory:DIRECTORY_RECORD]];
    if (!data) {
        NSLog(@"音频未下载");
        return;
    }
    [[MQChatManager sharedInstance] playerVoiceFormData:data FinishPlay:^{
        message.isPlaying = NO;
    }];

}

- (void)imagePressMessage:(Message *)message
{
    NSMutableArray * mArr = [[NSMutableArray alloc] init];
    [self.dataArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Message * mess = obj;
        if ([mess isKindOfClass:[Message class]] && [mess.type integerValue] == MessageType_Image) {
            [mArr addObject:mess];
        }
    }];
    ChatTableViewCell * cell = (ChatTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self.dataArr indexOfObject:message] inSection:0]];
                                
    [[MQChatUtil sharedInstance] browserPhotos:mArr ShowIndex:[mArr indexOfObject:message] SuperView:self.view OriginFrame:[cell.bubbleView convertRect:cell.bubbleView.bounds toView:self.view.window]];

}

- (void)longPressMessage:(Message *)message Cell:(ChatTableViewCell *)cell
{
  
    [cell becomeFirstResponder];
    
    _menuController = [UIMenuController sharedMenuController];
    
    UIMenuItem * copyItem = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(menuItemCopy:)];
    UIMenuItem * deleteItem = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(menuItemDelete:)];
    UIMenuItem * againItem = [[UIMenuItem alloc] initWithTitle:@"重新发送" action:@selector(menuItemAgain:)];
    
    if ([message.type integerValue] == MessageType_Audio || [message.type integerValue] == MessageType_Image) {
        _menuController.menuItems = @[deleteItem];
    } else {
        if ([message.isSender boolValue]) {
            _menuController.menuItems = @[copyItem, deleteItem, againItem];
        } else {
            _menuController.menuItems = @[copyItem,deleteItem];
        }
    }
    
    
    [_menuController setTargetRect:cell.bubbleView.frame inView:cell.bubbleView.superview];
    [_menuController setMenuVisible:YES animated:YES];
}

// MARK: - 各种类型发送信息

- (void)sendContent:(NSString *)content
{
    [self isNeedAddTimeCell];
    Message * message = [Message defaultMessage];
    message.content = content;
    message.session = self.session;
    message.type = [NSNumber numberWithInteger:MessageType_Text];
    [MQChatManager asyncSendMessage:message];
    
    [self addMessage:message];
}

- (void)sendImage:(UIImage *)image
{
    [self isNeedAddTimeCell];
    CGSize thumbnailSize = [MQChatUtil thumbnailSizeWithImage:image];
    
    Message * message = [Message defaultMessage];
    message.image = image;
    message.imageWidth = [NSNumber numberWithFloat:thumbnailSize.width];
    message.imageHeight = [NSNumber numberWithFloat:thumbnailSize.height];
    message.session = self.session;
    message.type = [NSNumber numberWithInteger:MessageType_Image];
    [MQChatManager asyncSendMessage:message];
    
    [self addMessage:message];
}

- (void)sendLocationName:(NSString *)name Longitude:(CGFloat)longitude Latitude:(CGFloat)latitude
{
    [self isNeedAddTimeCell];
    Message * message = [Message defaultMessage];
    message.type = [NSNumber numberWithInt:MessageType_Location];
    message.session = self.session;
    message.locationName = name;
    message.longitude = [NSNumber numberWithFloat:longitude];
    message.latitude = [NSNumber numberWithFloat:latitude];
    [MQChatManager asyncSendMessage:message];
    
    [self addMessage:message];
}

- (void)sendAudioRecordTime:(int)recordTime
{
    [self isNeedAddTimeCell];
    Message * message = [Message defaultMessage];
    message.type = [NSNumber numberWithInt:MessageType_Audio];
    message.session = self.session;
    message.audioPlayTime = [NSNumber numberWithInt:recordTime];
    
    [MQChatManager asyncSendMessage:message];
    [self addMessage:message];
    
}




// MARK: - TalbeView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id message = [self.dataArr objectAtIndex:indexPath.row];
    
    ChatTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:[ChatTableViewCell cellIdentifierForMessageModel:message]];
    
    if (!cell) {
        cell = [[ChatTableViewCell alloc] initWithMessageModel:message];
        
        cell.menuItemClick = _menuItemClick;
        
        cell.bubbleView.eventResponer = _eventResponer;
    }
    
    cell.message = message;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ChatTableViewCell heightForMessageModel:[self.dataArr objectAtIndex:indexPath.row]] - 5;
}


// MARK: - Scroll Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!isLoadMessageing && scrollView.contentOffset.y <= -20 && !CGSizeEqualToSize(scrollView.contentSize, CGSizeZero))
    {
        isLoadMessageing = YES;
        [self loadMoreMessage];
    }
}


// MARK: - ChatTooBar Location Delegate

- (void)chatLocation:(ChatLocationViewController *)location Name:(NSString *)name Longitude:(CGFloat)longitude Latitude:(CGFloat)latitude
{
    [self sendLocationName:name Longitude:longitude Latitude:latitude];
}

// MARK: - ChatToolBar Delegate

- (void)chatToolBar:(ChatToolBar *)toolBar ShowHeight:(CGFloat)height
{
    
    UITableViewCell * cell = [[self.tableView visibleCells] lastObject];

    CGRect frame = self.view.bounds;
    frame.size.height -= height + toolBar.frame.size.height;

    [UIView animateWithDuration:0.25 animations:^{
        self.tableView.frame = frame;
        [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionNone animated:NO];
    } completion:^(BOOL finished) {
        
    }];
    
}

- (void)chatToolBar:(ChatToolBar *)toolBar SendContent:(NSString *)content
{
    if ([content isEqualToString:@""]) {
         return;
    }
    [self sendContent:content];
}

- (BOOL)isNeedAddTime {
    
    BOOL isNeed = NO;
    // 如果距离上次发送时间超过3分钟则插入一条时间信息
    NSDate * curDate = [NSDate date];
    if ([curDate timeIntervalSinceDate:lastSendDate] >= 60 * 3 || !lastSendDate || sumMessageCount >= 10) {
        sumMessageCount = 0;
        NSDateFormatter * dateF = [[NSDateFormatter alloc] init];
        [dateF setDateFormat:@"HH:mm"];
        [self.dataArr addObject:[dateF stringFromDate:curDate]];
        
        isNeed = YES;
    }
    lastSendDate = [NSDate date];
    sumMessageCount ++;
    
    return isNeed;
}

/**
 *  是否需要添加时间Cell
 */
- (void)isNeedAddTimeCell
{
    if ([self isNeedAddTime]) {
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:self.dataArr.count - 1 inSection:0];
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}


// MARK: - ChatManagerDelegate

// 接受信息
- (void)chatManager:(MQChatManager *)manager ReceiveMessage:(Message *)message
{
    if (self.session == message.session) {
        [self isNeedAddTimeCell];
        [self addMessage:message];
    }
}
// 接受离线消息
- (void)chatManager:(MQChatManager *)manager ReceiveOfflineMessages:(NSArray *)messages {
    [messages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Message * mess = obj;
        if (mess.session == self.session) {
            [self isNeedAddTime];
            [self.dataArr addObject:mess];
        }
    }];
    [self.tableView reloadData];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArr.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    });
}

// 发送信息返回结果
- (void)chatManager:(MQChatManager *)manager SendMessage:(Message *)message
{
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:[self.dataArr indexOfObject:message] inSection:0];

    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
