//
//  Session.h
//  Chat
//
//  Created by 货道网 on 15/5/9.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Session : NSManagedObject


// MARK: - CoreData 属性
@property (nonatomic, retain) NSString * sessionId;
@property (nonatomic, retain) NSString * from;
@property (nonatomic, retain) NSString * to;

@property (nonatomic, retain) NSString * lastContent;
@property (nonatomic, retain) NSDate * lastDate;
@property (nonatomic, retain) NSNumber * unreadCount;



// MARK: - 自定义属性
@property (nonatomic, strong) NSMutableArray * messages;


@end
