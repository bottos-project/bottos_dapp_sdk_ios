//
//  BTOHashManager.h
//  AnyWallet
//
//  Created by ZZL on 2019/5/28.
//  Copyright © 2019 ZZL. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSInteger {
    AWErrorCodeCommitted                        = 0,        //提交成功
    AWErrorCodeAccountNameNotFound              = 10102,    //account name not found
    AWErrorCodeNameAlreadyExist                 = 10103,    //account name already exist
    AWErrorCodeAlreadyClaimed                   = 10128,    //push trx: already claimed within past day
    AWErrorCodethereNoAuthExecuteProposal       = 10706,    //is not enough authority to execute msign proposal
    AWErrorCodePending                          = 20300,    //trx is pending
    AWErrorCodeNotFound                         = 20301,    //trx execute failed because of not found
    AWErrorCodePacked                           = 20302,    //trx is packed
    AWErrorCodeSending                          = 20303,    //trx is sending
} AWErrorCode;

@interface BTOHashManager : NSObject <NSURLConnectionDelegate>
//查询为每秒一次，查询30次，超过30次未查询到结果，即为查询失败。

//一般查询
- (void)getHashStatus:(NSString *)statusStr status:(void (^)(NSDictionary *status))status failure:(void (^)(NSString *error))failure;
//注册查询
- (void)getRegisterStatus:(NSString *)statusStr status:(void (^)(NSDictionary *status))status failure:(void (^)(NSString *error))failure;
//转账查询
- (void)getHashStatus2:(NSString *)statusStr status:(void (^)(NSDictionary * status))status failure:(void (^)(NSString * error))failure;

@end

NS_ASSUME_NONNULL_END
