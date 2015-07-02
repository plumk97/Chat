//
//  NSArray+Ext.m
//  Chat
//
//  Created by 货道网 on 15/5/11.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import "NSArray+Ext.h"

@implementation NSArray (Ext)


- (NSArray *)reversalArray
{
    NSMutableArray * mArr = [[NSMutableArray alloc] init];
    
    for (NSInteger i = self.count - 1; i >= 0; i --) {
     
        [mArr addObject:self[i]];
    }
    
    return mArr;
}

@end
