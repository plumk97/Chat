

//
//  Request.m
//  yayi
//
//  Created by ltz on 14/11/4.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import "Request.h"

@implementation Request

requestError block_requestError;
requestSuccessful block_requestSuccessful;
requestBody block_requestBody;

void requestGet(NSString *requestUrl,NSDictionary *parameter,requestError errorBlock,requestSuccessful successfulBlock)
{
    
    Request *r = [Request new];
    
    if (r->block_requestError != errorBlock)
    {
        r->block_requestError = errorBlock;
    }
    if (r->block_requestSuccessful != successfulBlock)
    {
        r->block_requestSuccessful = successfulBlock;
    }
    
    AFHTTPRequestOperationManager * om = [[AFHTTPRequestOperationManager alloc] init];
    AFHTTPRequestOperation *oper = [om GET:[RQHost stringByAppendingString:requestUrl] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
    
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        r->block_requestSuccessful(dict);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        r->block_requestError(error);
    }];
    oper.responseSerializer = [AFCompoundResponseSerializer serializer];
    [oper start];

}
void requestPost(NSString *requestUrl,NSDictionary *parameter,requestError errorBlock,requestSuccessful successfulBlock)
{
    
    
    
    Request *r = [Request new];
    
    if (r->block_requestError != errorBlock)
    {
        r->block_requestError = errorBlock;
    }
    if (r->block_requestSuccessful != successfulBlock)
    {
        r->block_requestSuccessful = successfulBlock;
    }
    
    AFHTTPRequestOperationManager * om = [[AFHTTPRequestOperationManager alloc] init];
    
    AFHTTPRequestOperation *oper = [om POST:[RQHost stringByAppendingString:requestUrl] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        r->block_requestSuccessful(dict);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        r->block_requestError(error);
    }];
    oper.responseSerializer = [AFCompoundResponseSerializer serializer];
    [oper start];

}

void requestPostBody(NSString *requestUrl,NSDictionary *parameter,requestBody bodyBlock,requestError errorBlock,requestSuccessful successfulBlock)
{
    
    
    Request *r = [Request new];
    
    if (r->block_requestError != errorBlock)
    {
        r->block_requestError = errorBlock;
    }
    if (r->block_requestSuccessful != successfulBlock)
    {
        r->block_requestSuccessful = successfulBlock;
    }
    
    r->block_requestBody = bodyBlock;
    
    AFHTTPRequestOperationManager * om = [[AFHTTPRequestOperationManager alloc] init];
    AFHTTPRequestOperation *oper = [om POST:[RQHost stringByAppendingString:requestUrl] parameters:parameter constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        r->block_requestBody(formData);
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        r->block_requestSuccessful(dict);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        r->block_requestError(error);
    }];
    oper.responseSerializer = [AFCompoundResponseSerializer serializer];
    [oper start];
}

@end
