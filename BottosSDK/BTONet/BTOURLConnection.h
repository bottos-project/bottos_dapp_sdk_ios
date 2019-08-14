//
//  BTOURLConnection.h
//  mobiipay
//
//  Created by ZZL on 14-10-23.
//  Copyright (c) 2014年 mobiipay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BTOURLConnection : NSObject <NSURLConnectionDelegate>

- (void)requestPost:(NSString *)url body:(NSString *)body success:(void (^)(NSString *responseData))success failure:(void (^)(NSString *error))failure;
- (void)requestGet:(NSString *)url success:(void (^)(NSString *responseData))success failure:(void (^)(NSString *error))failure;

@end
