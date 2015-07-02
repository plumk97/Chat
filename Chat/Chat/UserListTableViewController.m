//
//  UserListTableViewController.m
//  Chat
//
//  Created by 货道网 on 15/5/4.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import "UserListTableViewController.h"
#import "ChatViewController.h"

#import <AudioToolbox/AudioToolbox.h>

@interface UserModel : NSObject

@property (nonatomic, copy) NSString * username;
@property (nonatomic, copy) NSString * password;
@property (nonatomic, copy) NSString * _id;

@property (nonatomic, strong) Session * session;

- (void)updateUserInfo:(NSDictionary *)dict;

@end

@implementation UserModel

- (void)updateUserInfo:(NSDictionary *)dict
{
    self.username = [dict objectForKey:@"username"];
    self.password = [dict objectForKey:@"password"];
    self._id = [dict objectForKey:@"_id"];
    
    if ([self.username isEqualToString:[MQChatManager sharedInstance].username]) {
        return;
    }
    self.session = [MQChatManager sessionForUserName:[dict objectForKey:@"username"] Default:NO];
}

@end


@interface UserTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *unreadCountLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *unreadCountLabelWidth;

@end
@implementation UserTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.unreadCountLabel.layer.cornerRadius = self.unreadCountLabel.frame.size.width / 2.0f;
    self.unreadCountLabel.layer.masksToBounds = YES;
}

@end

@interface UserListTableViewController ()
<ChatManagerDelegate>
{
    NSMutableArray * mDataArr;
    NSInteger count;
    
    NSDate * _preDate;
}
@end

@implementation UserListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    mDataArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    __weak typeof(self) weakSelf = self;
    [self.tableView addRefreshControl:RefreshDirection_Top];
    [self.tableView setRefreshBlock:^(RefreshDirection direction) {
        [weakSelf refreshClick];
    }];
    [self.tableView beganRefreshDirection:RefreshDirection_Top];
    
    [[MQChatManager sharedInstance] addDelegate:self];
    
    self.tabBarController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:@"退出登录"
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(exit:)];
    
    // 隐藏navigationBar 下面的黑线
    if ([self.navigationController.navigationBar respondsToSelector:@selector( setBackgroundImage:forBarMetrics:)]){
        NSArray *list=self.navigationController.navigationBar.subviews;
        for (id obj in list) {
            if ([obj isKindOfClass:[UIImageView class]]) {
                UIImageView *imageView=(UIImageView *)obj;
                NSArray *list2=imageView.subviews;
                for (id obj2 in list2) {
                    if ([obj2 isKindOfClass:[UIImageView class]]) {
                        UIImageView *imageView2=(UIImageView *)obj2;
                        [imageView2 removeFromSuperview];
                    }
                }
            }
        }
    }
}

- (void)exit:(UIBarButtonItem *)sender {
    [[MQChatManager sharedInstance] logOutComplection:^(NSError *result) {
        if (result.code == 1) {
            [GlobalMethod changeWindowRootViewController:[GlobalMethod getStoryboardID:@"LoginNavViewController"]];
        }
    }];
}

- (void)dealloc {
    [[MQChatManager sharedInstance] removeDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}

- (void)refreshClick {
    
    __block typeof(self) weakSelf = self;
    requestGet(RQGetAllUser, nil, ^(NSError *error) {
        NSLog(@"%@",[error localizedDescription]);

        [weakSelf.tableView endRefreshDirection:RefreshDirection_Top];
    }, ^(NSDictionary *dict) {
        [weakSelf.tableView endRefreshDirection:RefreshDirection_Top];

        NSInteger code = [[dict objectForKey:@"code"] integerValue];
        if (code != 1) {
            
            NSLog(@"%@",[dict objectForKey:@"msg"]);
            return ;
        }
        
        [weakSelf->mDataArr removeAllObjects];
        NSArray * arr = [dict objectForKey:@"data"];
        for (NSDictionary * d in arr) {
            
            UserModel * model = [[UserModel alloc] init];
            [model updateUserInfo:d];
            [weakSelf->mDataArr addObject:model];
            
        }
        [weakSelf.tableView reloadData];
        
    });

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// MARK: - MQChatManager Delegate

- (void)chatManager:(MQChatManager *)manager LogOutDescriptionStatus:(LogOutDescriptionStatus)status {
    if (status == LogOutDescriptionStatus_OtherDeviceLogin) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该账号已经在其他设备登录" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [GlobalMethod changeWindowRootViewController:[GlobalMethod getStoryboardID:@"LoginNavViewController"]];
    }
}
- (void)chatManager:(MQChatManager *)manager NetworkChangeState:(AFNetworkReachabilityStatus)status {
    NSLog(@"%ld",status);
}

- (void)chatManager:(MQChatManager *)manager ReceiveMessage:(Message *)message {
    
    if (message.session == [MQChatManager sharedInstance].currentSession && [MQChatManager sharedInstance].applicationStaus == Application_Active) {
        return;
    }
    
    NSDate * date = [NSDate date];
    if (([MQChatManager sharedInstance].applicationStaus == Application_Active && [date timeIntervalSinceDate:_preDate] >= 3) || !_preDate) {
        AudioServicesPlaySystemSound(1000);
        _preDate = date;
    }
    
    if ([MQChatManager sharedInstance].applicationStaus == Application_Background) {
        
        NSMutableString * content = [[NSMutableString alloc] initWithFormat:@"%@:",message.session.to];
        switch ([message.type integerValue]) {
            case MessageType_Audio:
                [content appendString:@"[语音]"];
                break;
            case MessageType_Image:
                [content appendString:@"[图片]"];
                break;
            case MessageType_Location:
                [content appendString:@"[位置]"];
                break;
            case MessageType_Text:
                [content appendString:message.content];
                break;
            default:
                break;
        }
        
        UILocalNotification * locationNoti = [[UILocalNotification alloc] init];
        locationNoti.applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
        locationNoti.soundName= UILocalNotificationDefaultSoundName;
        locationNoti.alertBody = content;
        locationNoti.hasAction = NO;
        [[UIApplication sharedApplication] scheduleLocalNotification:locationNoti];
    }
    [self.tableView reloadData];
}
- (void)chatManager:(MQChatManager *)manager ReceiveOfflineMessages:(NSArray *)messages {
    [self.tableView reloadData];
}
#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return mDataArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    // Configure the cell...
    
    UserModel * model = [mDataArr objectAtIndex:indexPath.row];
    cell.usernameLabel.text = model.username;
    
    int unreadCount = [model.session.unreadCount intValue];
    if (unreadCount == 0) {
        cell.unreadCountLabel.hidden = YES;
    } else {
        cell.unreadCountLabel.hidden = NO;
        if (unreadCount >= 10) {
            cell.unreadCountLabelWidth.constant = 25;
        } else {
            cell.unreadCountLabelWidth.constant = 20;
        }
        cell.unreadCountLabel.text = [[NSString alloc] initWithFormat:@"%d",unreadCount];
    }
    
    if ([model.username isEqualToString:[MQChatManager sharedInstance].username]) {
        cell.contentLabel.text = @"这是自己哦";
    } else {
        cell.contentLabel.text = model.session.lastContent;
    }

    cell.timeLabel.text = [MQChatUtil formatDate:model.session.lastDate Format:@"HH:mm"];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UserModel * model = [mDataArr objectAtIndex:indexPath.row];
    model.session.unreadCount = [NSNumber numberWithInt:0];
    [[MQChatManager sharedInstance].managedObjectContext save:nil];
    if ([model._id isEqualToString:[MQChatManager sharedInstance].userid]) {
        
        [self.view showTipsString:@"不能跟自己聊天"];
        NSLog(@"不能跟自己聊天");
        return;
    }
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    ChatViewController * nav = [[ChatViewController alloc] initWithUserName:model.username];
    [self.navigationController pushViewController:nav animated:YES];
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
