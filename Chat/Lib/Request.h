//
//  Request.h
//  yayi
//
//  Created by ltz on 14/11/4.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "RequestURL.h"


typedef void(^requestError) (NSError *error) ;
typedef void(^requestSuccessful) (NSDictionary *dict) ;
typedef void(^requestBody) (id<AFMultipartFormData> formData) ;


@interface Request : NSObject
{
    requestError block_requestError ;
    requestSuccessful block_requestSuccessful ;
    requestBody block_requestBody ;
}
void requestPost(NSString *requestUrl,NSDictionary *parameter,requestError errorBlock,requestSuccessful successfulBlock);
void requestGet(NSString *requestUrl,NSDictionary *parameter,requestError errorBlock,requestSuccessful successfulBlock);

void requestPostBody(NSString *requestUrl,NSDictionary *parameter,requestBody bodyBlock,requestError errorBlock,requestSuccessful successfulBlock) ;

@end
