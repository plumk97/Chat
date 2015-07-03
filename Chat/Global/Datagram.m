//
//  Datagram.m
//  Chat
//
//  Created by 货道网 on 15/5/5.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import "Datagram.h"

@implementation Datagram


+ (NSData *)codingDictonary:(NSDictionary *)dict {
    
    NSMutableData * jsonData = [[NSMutableData alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil]];
    NSString * str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    str = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSInteger length = str.length;
    UInt8 header[4] = {0};
    header[0] = length >> 0;
    header[1] = length >> 8;
    header[2] = length >> 16;
    header[3] = length >> 24;

    [jsonData setData:[NSData dataWithBytes:header length:4]];
    
    [jsonData appendData:[str dataUsingEncoding:NSUTF8StringEncoding]];

    return jsonData;
}

+ (NSDictionary *)decodingData:(NSData *)data {
    NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    return dict;
}

@end
