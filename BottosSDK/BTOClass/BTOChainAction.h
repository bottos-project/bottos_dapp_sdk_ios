//
//  BTOChainAction.h
//  AnyWallet
//
//  Created by ZZL on 2019/5/23.
//  Copyright © 2019 ZZL. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BTOReqObj;

@interface BTOChainAction : NSObject
//创建对象
+(instancetype)share;

/**
 获取块高
 @param success 成功
 @param failure 失败
 */
-(void)getBlockHeight:(void (^)(NSString *responseData))success failure:(void (^)(NSString *error))failure;

/**
 获取块详情
 @param success 成功
 @param failure 失败
 */
-(void)getBlockDetail:(void (^)(NSString *responseData))success failure:(void (^)(NSString *error))failure;

/**
 构建请求数据结构
 @param obj 请求对象
 @param success 成功
 @param failure 失败
 */
-(void)getResponseDic:(id)obj success:(void (^)(NSDictionary *responseData))success failure:(void (^)(NSString *error))failure;

/**
 获取参数hash
 @param obj 请求参数
 @param success 成功
 @param failure 失败
 */
-(void)getHash:(NSDictionary *)obj success:(void (^)(NSString *hashData))success failure:(void (^)(NSString *error))failure;

/**
 发送到链
 @param obj 请求参数
 @param success 成功
 @param failure 失败
 */
-(void)sendToChain:(NSDictionary *)obj success:(void (^)(NSString *responseData))success failure:(void (^)(NSString *error))failure;

@end
