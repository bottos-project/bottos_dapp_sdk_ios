//
//  BTOApi.m
//  AnyWallet
//
//  Created by ZZL on 2019/5/23.
//  Copyright © 2019 ZZL. All rights reserved.
//

#import "BTOApi.h"
#import "BTOObj.h"
#import "BTOTool.h"
#import "BTOChainAction.h"
#import "BTOHashManager.h"
#import "BTOURLConnection.h"
#import <TrezorCrypto/TrezorCrypto.h>

@interface BTOApi ()
/**
 成功回调
 */
@property (nonatomic, copy) void(^success)(NSDictionary *responseData);

/**
 失败回调
 */
@property (nonatomic, copy) void(^failure)(NSError *error);
@end

@implementation BTOApi

/*!
 * @brief 向BTO发起请求
 * @param obj 接收SDK内BTOReqObj的业务子类, 如交易/转账BTOTransferObj, ...
 * @param success 请求成功回调
 * @param failure 请求成功回掉
 * @return 成功发起请求会返回YES, 其他情况返回NO;
 */
- (BOOL)sendObj:(BTOReqObj *)obj success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure
{
    self.success = success;
    self.failure = failure;
    if ([BTOObj share].blockHeight_ == NULL) {
        [[BTOChainAction share] getBlockHeight:^(NSString * _Nonnull responseData) {

            [BTOObj share].blockHeight_ = [[BTOTool share] convertToDictionary:responseData];
            NSLog(@"blockHeight------------------%@",[BTOObj share].blockHeight_);

            [self sendObj2:obj];
            
        } failure:^(NSString * _Nonnull error) {
            self.failure([NSError errorWithDomain:error code:-1 userInfo:nil]);
        }];
        
    }else{
         [self sendObj2:obj];
    }

    return YES;
}

/**
 * @brief 向BTO发起请求,调取块详情
 * @param obj 接收SDK内BTOReqObj的业务子类, 如交易/转账BTOTransferObj, ...
 */
- (void)sendObj2:(BTOReqObj *)obj
{
    [[BTOChainAction share] getBlockDetail:^(NSString * _Nonnull responseData) {
        [BTOObj share].blockDetail_ = [[BTOTool share] convertToDictionary:responseData];
        NSLog(@"blockDetail------------------%@",[BTOObj share].blockDetail_);

        [self sendObj3:obj];

    } failure:^(NSString * _Nonnull error) {
        self.failure([NSError errorWithDomain:error code:-1 userInfo:nil]);
    }];
}


/**
 * @brief 向BTO发起请求,获取参数hash
 * @param obj 接收SDK内BTOReqObj的业务子类, 如交易/转账BTOTransferObj, ...
 */
- (void)sendObj3:(BTOReqObj *)obj
{
    [[BTOChainAction share] getResponseDic:obj success:^(NSDictionary *responseData) {
        NSLog(@"getResponse:%@",responseData);
        //请求签名
        [[BTOChainAction share] getHash:responseData success:^(NSString *hashData) {
            NSLog(@"getHash------------------%@",hashData);
            NSDictionary *sendParams = [[BTOTool share] convertToDictionary:hashData];
            NSString *privateKey = obj.privateKey;
            if (![[NSString stringWithFormat:@"%@",sendParams[@"errcode"]] isEqualToString:@"0"]) {
                self.failure(sendParams[@"msg"]);
            } else {
                [self sendObj4:sendParams privateKey:privateKey];
            }
        } failure:^(NSString *error) {
            self.failure([NSError errorWithDomain:error code:-1 userInfo:nil]);
        }];
    } failure:^(NSString *error) {
        self.failure([NSError errorWithDomain:error code:-1 userInfo:nil]);
    }];
}

/**
 * @brief 对params，privateKey进行签名
 * @param sendParms params hash
 * @param privateKey 私钥
 */
- (void)sendObj4:(NSDictionary *)sendParms privateKey:(NSString *)privateKey {

    //key：私钥字符串
    NSDictionary *resultDic = sendParms[@"result"];
    NSMutableDictionary *trxDic = (NSMutableDictionary *)resultDic[@"trx"];
    //params的hash值
    NSString *hash_for_sign = resultDic[@"hash_for_sign"];
    NSData *hashData = [[BTOTool share] convertHexStrToData:hash_for_sign];
    
    //私钥字符串转化成 16进制数据
    NSData *priData = [[BTOTool share] convertHexStrToData:privateKey];
    //生成签名 把Crypto signHash方法体挪出来修改创建Data的空间为64
    NSMutableData *signature = [[NSMutableData alloc] initWithLength:64];
    uint8_t by = 0;
    ecdsa_sign_digest(&secp256k1, priData.bytes, hashData.bytes, signature.mutableBytes, &by, nil);
    ((uint8_t *)signature.mutableBytes)[64] = by;
    NSData *signData = signature;
    
    //生成签名字符串
    NSString *signStr = [[BTOTool share]convertDataToHexStr:signData];
    [trxDic setObject:signStr forKey:@"signature"];
    NSLog(@"---trxDic-----%@",trxDic);
    //send to chain
    [self sendObj5:trxDic];
    
}

/**
 * @brief 数据发送到链
 * @param trxDic 交易字典
 */
- (void)sendObj5:(NSDictionary *)trxDic {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [[BTOChainAction share]sendToChain:trxDic success:^(NSString *responseData) {
            NSLog(@"responseData = %@",responseData);
            NSDictionary *responseDic = [[BTOTool share] convertToDictionary:responseData];
            if ([responseDic[@"errcode"] intValue] == 0) {
                NSDictionary *resultDic = responseDic[@"result"];
                NSString *trx_hash = resultDic[@"trx_hash"];
                NSString *method = responseDic[@"result"][@"trx"][@"method"];
                //根据Hash获取合约状态
                BTOHashManager *hashManager = [[BTOHashManager alloc] init];
                if ([method isEqualToString:@"transfer"]) {
                    [hashManager getHashStatus2:trx_hash status:^(NSDictionary * _Nonnull response) {
                        //转账查询回调
                        [self handleResponseActionWithTrxHash2:trx_hash response:response];
                    } failure:^(NSString * _Nonnull error) {
                        self.failure([NSError errorWithDomain:error code:-1 userInfo:nil]);
                    }];
                } else {
                    [hashManager getHashStatus:trx_hash status:^(NSDictionary * _Nonnull response) {
                        //处理查询回调
                        [self handleResponseActionWithTrxHash:trx_hash response:response];
                    } failure:^(NSString * _Nonnull error) {
                        self.failure([NSError errorWithDomain:error code:-1 userInfo:nil]);
                    }];
                }
            } else {
                self.failure([NSError errorWithDomain:NSLocalizedString(@"TransferFail", nil) code:-1 userInfo:nil]);
            }
        } failure:^(NSString *error) {
            self.failure([NSError errorWithDomain:error code:-1 userInfo:nil]);
        }];
    });
}

/**
 * @brief 查询普通结果
 * @param trxHash 交易hash
 * @param response 发送到链响应数据
 */
- (void)handleResponseActionWithTrxHash:(NSString *)trxHash response:(NSDictionary *)response {
    
    NSDictionary *resultDic = response[@"result"];
    NSInteger errcode = [response[@"errcode"] intValue];
    NSString *status = resultDic[@"status"];
    switch (errcode) {
        case AWErrorCodeCommitted: {
            self.success(@{@"msg":@"success",@"trx_hash":trxHash});
        }
            break;
        case AWErrorCodePending:
        case AWErrorCodePacked:
        case AWErrorCodeSending:
        case AWErrorCodeNotFound:{
            NSLog(@"-------------requesting");
        }
            break;
        default: {
            self.failure([NSError errorWithDomain:status code:errcode userInfo:nil]);
        }
            break;
    }
}

/**
 * @brief 查询转账结果
 * @param trxHash2 交易hash
 * @param response 发送到链响应数据
 */
- (void)handleResponseActionWithTrxHash2:(NSString *)trxHash2 response:(NSDictionary *)response {
    
    NSInteger errcode = [response[@"errcode"] intValue];
    NSString *msg = response[@"msg"];
    switch (errcode) {
        case 0: {
            self.success(@{@"msg":msg,@"trx_hash":trxHash2});
        }
            break;
        case 10201:
        case 20301:{
            NSLog(@"--------requesting");
        }
            break;
            
        default: {
            self.failure([NSError errorWithDomain:msg code:errcode userInfo:nil]);
        }
            break;
    }
    
}

#pragma mark - 暂无开放
/*!
 * @brief 注册ID
 * @param AppID a) 请确保AppID已经添加在Xcode工程info.plist-> URL types -> URL Schemes里!
 *              b) AppID也作为App回调时的URL跳转, 务必设置好AppID!
 *              c) 为了避免误操作其他App的跳转请求，请设置一个唯一的appID给BTOSDK, 建议为各个SDK添加命名后缀, 如xxxforBTOsdk;
 *
 * @disucss 在AppDelegate -(application:didFinishLaunchingWithOptions:)方法里注册
 */
+ (void)registerAppID:(NSString *)AppID
{
    //暂无
}

/*!
 * @brief   处理BTO的回调跳转
 * @discuss 在AppDelegate -(application:openURL:options:)方法里调用
 */
+ (BOOL)handleURL:(NSURL *)url
          options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
           result:(void(^)(BTORespObj *respObj))result
{
    return YES;
}

@end
