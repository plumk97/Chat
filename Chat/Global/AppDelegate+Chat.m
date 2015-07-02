//
//  AppDelegate+Chat.m
//  Chat
//
//  Created by li on 15/6/30.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import "AppDelegate+Chat.h"

@implementation AppDelegate (Chat)

- (void)chatApplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self registerRemoteNotification];
    [self setupNotifiers];
}

- (void)setupNotifiers{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterBackgroundNotif:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActiveNotif:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)appDidEnterBackgroundNotif:(NSNotification *)noti {
    [MQChatManager sharedInstance].applicationStaus = Application_Background;
    [UIApplication sharedApplication].applicationIconBadgeNumber = [MQChatManager getAllSessionUnreadCount];
}

- (void)appDidBecomeActiveNotif:(NSNotification *)noti {
    [MQChatManager sharedInstance].applicationStaus = Application_Active;
}

- (void)registerRemoteNotification{
#if !TARGET_IPHONE_SIMULATOR
    UIApplication *application = [UIApplication sharedApplication];
    //iOS8 注册APNS
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [application registerForRemoteNotifications];
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }else{
        UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeBadge |
        UIRemoteNotificationTypeSound |
        UIRemoteNotificationTypeAlert;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationTypes];
    }
#endif
}

@end
