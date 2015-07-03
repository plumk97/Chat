//
//  ChatLogViewController.m
//  Chat
//
//  Created by 货道网 on 15/5/13.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import "ChatLogViewController.h"

@interface ChatLogViewController ()
<UITableViewDataSource, UITableViewDelegate>
{
    NSDate * preDate;
    NSInteger count;
}
@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, copy) void (^completion) ();

@end

@implementation ChatLogViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [[MQChatManager sharedInstance] obtainServerChatRecordWithUsername:[MQChatManager sharedInstance].currentSession.to Completion:^(NSError *result) {
        if (result.code != 1) {
            
            NSLog(@"%@", [result domain]);
            return ;
        }
        // 删除这个会话的所有记录 加入从服务器获取的
        
        NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:@"Message"];
        request.predicate = [NSPredicate predicateWithFormat:@"session == %@", [MQChatManager sharedInstance].currentSession];
        
        NSError * error;
        NSArray * datas = [[MQChatManager sharedInstance].managedObjectContext executeFetchRequest:request error:&error];
        if (error) {
            NSLog(@"%@",[error localizedDescription]);
        }
        for (Message * mess in datas) {
            [[MQChatManager sharedInstance].managedObjectContext deleteObject:mess];
            
        }
        
        
        id list = [result.userInfo objectForKey:@"list"];
        if (list && [list isKindOfClass:[NSArray class]]) {
            for (NSDictionary * dict in list) {
                [Message messageWithDict:dict Session:[MQChatManager sharedInstance].currentSession];
            }
        }
        
        [[MQChatManager sharedInstance].managedObjectContext save:&error];
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
        if (self.completion) {
            self.completion();
        }

    }];
    
}

- (NSDate *)conversionTimeToDate:(CGFloat)time
{
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:time];
    
    return date;
}

- (void)succeedServerChatRecoder:(void (^)())completion
{
    self.completion = completion;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.separatorColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    
    return _tableView;
}


// MARK: - Table View Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return nil;
}



@end
