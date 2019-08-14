//
//  BTOURLConnection.m
//  mobiipay
//
//  Created by ZZL on 14-10-23.
//  Copyright (c) 2014年 mobiipay. All rights reserved.
//

#import "BTOURLConnection.h"

@interface BTOURLConnection()

@end

@implementation BTOURLConnection

- (void)requestPost:(NSString *)url body:(NSString *)body success:(void (^)(NSString *responseData))success failure:(void (^)(NSString *error))failure{

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Accept"];
    
    //创建NSURLSession
    NSURLSession *session = [NSURLSession sharedSession];
    
    
    //创建任务
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            NSString *receiveStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            dispatch_async(dispatch_get_main_queue(), ^{
                //切换回主线程 子线程无法开启定时器
                success(receiveStr);
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(NSLocalizedString(@"TryAgain", nil));
            });
        }
    }];
    
    //开始任务
    [task resume];
}

- (void)requestGet:(NSString *)url success:(void (^)(NSString *responseData))success failure:(void (^)(NSString *error))failure{

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    
    [request setHTTPMethod:@"Get"];
    [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Accept"];
    
    //创建NSURLSession
    NSURLSession *session = [NSURLSession sharedSession];
    
    //创建任务
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            NSString *receiveStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            dispatch_async(dispatch_get_main_queue(), ^{
                success(receiveStr);
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(NSLocalizedString(@"TryAgain", nil));
            });
        }
    }];
    
    //开始任务
    [task resume];
}

- (void)dealloc
{
    
}

@end
