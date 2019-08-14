//
//  BTOChainAction.m
//  AnyWallet
//
//  Created by ZZL on 2019/5/23.
//  Copyright © 2019 ZZL. All rights reserved.
//

#import "BTOChainAction.h"
#import "BTOObj.h"
#import "BTOTool.h"
#import "BTOReqObj.h"
#import "BTONetworkManager.h"
#import "BTOURLConnection.h"

@interface BTOChainAction ()<NSCopying,NSMutableCopying>

@end

static BTOChainAction *manager = nil;
@implementation BTOChainAction

+ (instancetype)share{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manager = [[BTOChainAction alloc] init];
    });
    return manager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [super allocWithZone:zone];
        }
    });
    return manager;
}

- (id)copyWithZone:(NSZone *)zone {
    return manager;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return manager;
}

/**
 获取块高
 @param success 成功
 @param failure 失败
 */
- (void)getBlockHeight:(void (^)(NSString *responseData))success failure:(void (^)(NSString *error))failure
{
    NSString *url = [[BTONetworkManager share] getServiceNode1_URL:aw_block_height];
    
    BTOURLConnection *urlConnection = [[BTOURLConnection alloc] init];
    [urlConnection requestGet:url success:^(NSString *responseData) {
    
        success(responseData);
        
    } failure:^(NSString *error) {
        failure(NSLocalizedString(@"FailHeight", nil));
    }];
}

/**
 获取块详情
 @param success 成功
 @param failure 失败
 */
- (void)getBlockDetail:(void (^)(NSString *responseData))success failure:(void (^)(NSString *error))failure
{
    NSDictionary *blockHeight = [BTOObj share].blockHeight_[@"result"];
    
    NSString *url = [[BTONetworkManager share] getServiceNode1_URL:aw_block_detail];
    NSDictionary *bodyDic = @{@"block_num":blockHeight[@"head_block_num"],
                              @"block_hash":blockHeight[@"head_block_hash"]};
    NSString *bodyStr = [[BTOTool share] convertToJsonString:bodyDic];
    
    
    BTOURLConnection *urlConnection = [[BTOURLConnection alloc] init];
    [urlConnection requestPost:url body:bodyStr success:^(NSString *responseData) {

        success(responseData);

    } failure:^(NSString *error) {
        failure(NSLocalizedString(@"FailInfo", nil));
    }];
}

/**
 构建请求数据结构

 @param obj 请求对象
 @param success 成功
 @param failure 失败
 */
- (void)getResponseDic:(id)obj success:(void (^)(NSDictionary *responseData))success failure:(void (^)(NSString *error))failure {
    
    if ([obj isKindOfClass:[BTOTransferObj class]]) {
        //转账
        [self getTransferDic:obj success:success failure:failure];
    } else if ([obj isKindOfClass:[BTOPushTransactionObj class]]) {
        //普通合约
        [self getTransactionDic:obj success:success failure:failure];
    } else if ([obj isKindOfClass:[BTOStakeObj class]]) {
        //质押
        [self getStakeDic:obj success:success failure:failure];
    } else if ([obj isKindOfClass:[BTOVoteObj class]]){
        //投票
        [self getVoteDic:obj success:success failure:failure];
    } else if ([obj isKindOfClass:[BTORewardObj class]]){
        //提取奖励
        [self getRewardDic:obj success:success failure:failure];
    } else if ([obj isKindOfClass:[BTOProposalObj class]]) {
        //提案
        [self getProposalDic:obj success:success failure:failure];
    } else if ([obj isKindOfClass:[BTOClaimObj class]]) {
        //提现
        [self getClaimDic:obj success:success failure:failure];
    }
}

/**
 提现
 @param obj 入参对象(BTOClaimObj)
 @param success 成功
 @param failure 失败
 */
- (void)getClaimDic:(BTOClaimObj *)obj success:(void (^)(NSDictionary *responseData))success failure:(void (^)(NSString *error))failure {
    NSDictionary *blockHeight = [BTOObj share].blockHeight_[@"result"];
    int64_t amountInt = (int64_t)([obj.amount doubleValue] * 100000000);
    NSMutableDictionary *bodyDic = @{@"version":blockHeight[@"head_block_version"],
                              @"cursor_num":blockHeight[@"head_block_num"],
                              @"cursor_label":blockHeight[@"cursor_label"],
                              @"lifetime":blockHeight[@"head_block_time"],
                              @"contract":@"bottos",
                              @"method":obj.method,
                              @"param":@{@"amount":[NSString stringWithFormat:@"%lld",amountInt]}
                              }.mutableCopy;
    if (obj.sender.length > 0) {
        [bodyDic setObject:obj.sender forKey:@"sender"];
        success(bodyDic);
    } else {
        failure(@"sender字段不能为空");
    }
}

/**
 质押
 @param obj 入参对象(BTOStakeObj)
 @param success 成功
 @param failure 失败
 */
- (void)getStakeDic:(BTOStakeObj *)obj success:(void (^)(NSDictionary *responseData))success failure:(void (^)(NSString *error))failure {
    NSDictionary *blockHeight = [BTOObj share].blockHeight_[@"result"];
    int64_t amountInt = (int64_t)([obj.amount doubleValue] * 100000000);
    NSDictionary *stakeDic = @{};
    if ([obj.method isEqualToString:@"stake"]) {
        stakeDic = @{@"amount":[NSString stringWithFormat:@"%lld",amountInt],
                                   @"target":obj.target,
                                   };
    }else{
        stakeDic = @{@"amount":[NSString stringWithFormat:@"%lld",amountInt],
                                   @"source":obj.source,
                                   };
    }

    NSMutableDictionary *bodyDic = @{@"version":blockHeight[@"head_block_version"],
                              @"cursor_num":blockHeight[@"head_block_num"],
                              @"cursor_label":blockHeight[@"cursor_label"],
                              @"lifetime":blockHeight[@"head_block_time"],
                              @"contract":@"bottos",
                              @"method":obj.method,
                              @"param":stakeDic}.mutableCopy;
    if (obj.sender.length > 0) {
        [bodyDic setObject:obj.sender forKey:@"sender"];
        success(bodyDic);
    } else {
        failure(@"sender字段不能为空");
    }
}

/**
 投票
 @param obj 入参对象(BTOVoteObj)
 @param success 成功
 @param failure 失败
 */
- (void)getVoteDic:(BTOVoteObj *)obj success:(void (^)(NSDictionary *responseData))success failure:(void (^)(NSString *error))failure {
    NSDictionary *blockHeight = [BTOObj share].blockHeight_[@"result"];
    int64_t voteop = (int64_t)([obj.voteop intValue]);
    NSDictionary *stakeDic = @{@"voteop":[NSString stringWithFormat:@"%lld",voteop],
                               @"voter":obj.voter,
                               @"delegate":obj.delegate,
                               };
    NSMutableDictionary *bodyDic = @{@"version":blockHeight[@"head_block_version"],
                              @"cursor_num":blockHeight[@"head_block_num"],
                              @"cursor_label":blockHeight[@"cursor_label"],
                              @"lifetime":blockHeight[@"head_block_time"],
                              @"contract":@"bottos",
                              @"method":obj.method,
                              @"param":stakeDic}.mutableCopy;
    if (obj.sender.length > 0) {
        [bodyDic setObject:obj.sender forKey:@"sender"];
        success(bodyDic);
    } else {
        failure(@"sender字段不能为空");
    }
}

/**
 提取奖励
 @param obj 入参对象(BTORewardObj)
 @param success 成功
 @param failure 失败
 */
- (void)getRewardDic:(BTORewardObj *)obj success:(void (^)(NSDictionary *responseData))success failure:(void (^)(NSString *error))failure {
    NSDictionary *blockHeight = [BTOObj share].blockHeight_[@"result"];
    NSDictionary *stakeDic = @{@"account":obj.account,
                               };
    NSMutableDictionary *bodyDic = @{@"version":blockHeight[@"head_block_version"],
                              @"cursor_num":blockHeight[@"head_block_num"],
                              @"cursor_label":blockHeight[@"cursor_label"],
                              @"lifetime":blockHeight[@"head_block_time"],
                              @"contract":@"bottos",
                              @"method":obj.method,
                              @"param":stakeDic}.mutableCopy;
    if (obj.sender.length > 0) {
        [bodyDic setObject:obj.sender forKey:@"sender"];
        success(bodyDic);
    } else {
        failure(@"sender字段不能为空");
    }
}

/**
 提案
 @param obj 入参对象(BTOProposalObj)
 @param success 成功
 @param failure 失败
 */
- (void)getProposalDic:(BTOProposalObj *)obj success:(void (^)(NSDictionary *responseData))success failure:(void (^)(NSString *error))failure  {
    NSDictionary *blockHeight = [BTOObj share].blockHeight_[@"result"];
    NSString *proposer = obj.proposer.length>0?obj.proposer:@"";
    NSString *proposal = obj.proposal.length>0?obj.proposal:@"";
    NSMutableDictionary *proposalDic = @{@"proposer":proposer,
                                         @"proposal":proposal,
                                         }.mutableCopy;
    if ([obj.method isEqualToString:@"pushmsignproposal"]) {
        
        int64_t amountInt = (int64_t)([obj.amount doubleValue] * 100000000);
        
        NSDictionary *transferDic = @{@"from":obj.account,@"to": obj.to,@"amount": [NSString stringWithFormat:@"%lld",amountInt],@"memo": obj.memo};
        
        //发起提案
        [proposalDic setObject:obj.account forKey:@"account"];
        [proposalDic setObject:[[BTOTool share] convertToJsonString:transferDic] forKey:@"transfer"];
    } else if ([obj.method isEqualToString:@"newmsignaccount"]){
        proposalDic = @{@"account":obj.account,
                        @"authority":[self removeSpaceAndNewline:obj.authority],
                        @"threshold":@(obj.threshold).stringValue
                        }.mutableCopy;
        
    } else {
        if ([obj.method isEqualToString:@"approvemsignproposal"] || [obj.method isEqualToString:@"unapprovemsign"]) {
            //签署/取消签署
            [proposalDic setObject:obj.sender forKey:@"account"];
        }
    }
    
    NSMutableDictionary *bodyDic = @{@"version":blockHeight[@"head_block_version"],
                              @"cursor_num":blockHeight[@"head_block_num"],
                              @"cursor_label":blockHeight[@"cursor_label"],
                              @"lifetime":blockHeight[@"head_block_time"],
                              @"contract":@"bottos",
                              @"method":obj.method,
                              @"param":proposalDic
                              }.mutableCopy;
    if (obj.sender.length > 0) {
        [bodyDic setObject:obj.sender forKey:@"sender"];
        success(bodyDic);
    } else {
        failure(@"sender字段不能为空");
    }
}

/**
 转账数据

 @param transfer 请求对象(BTOTransferObj)
 @param success 成功
 @param failure 失败
 */
- (void)getTransferDic:(BTOTransferObj *)transfer success:(void (^)(NSDictionary *responseData))success failure:(void (^)(NSString *error))failure
{
    
    NSDictionary *blockHeight = [BTOObj share].blockHeight_[@"result"];
//    NSDictionary *blockDetail = [BTOObj share].blockDetail_[@"result"];
    
    int64_t amountInt = (int64_t)([transfer.amount doubleValue] * 100000000);
    
    
    
    NSMutableDictionary *bodyDic = @{@"version":blockHeight[@"head_block_version"],
                              @"cursor_num":blockHeight[@"head_block_num"],
                              @"cursor_label":blockHeight[@"cursor_label"],
                              @"lifetime":blockHeight[@"head_block_time"],
                              @"contract":transfer.contract,
                              @"method":@"transfer"
                                     }.mutableCopy;
    
    if (transfer.sender.length > 0) {
        [bodyDic setObject:transfer.sender forKey:@"sender"];
        NSDictionary *transferDic = @{@"from":transfer.sender,
                                      @"to": transfer.to,
                                      @"value": [NSString stringWithFormat:@"%lld",amountInt],
                                      @"memo": transfer.memo};
        [bodyDic setObject:transferDic forKey:@"param"];
        success(bodyDic);
    } else {
        failure(@"sender字段不能为空");
    }
}


- (void)getTransactionDic:(BTOPushTransactionObj *)transaction success:(void (^)(NSDictionary *responseData))success failure:(void (^)(NSString *error))failure
{
    NSArray *array = transaction.actions;
    if (array.count > 0) {
        
        NSDictionary *blockHeight = [BTOObj share].blockHeight_[@"result"];
//        NSDictionary *blockDetail = [BTOObj share].blockDetail_[@"result"];
        
        NSDictionary *dic = array[0];
        
        NSDictionary *bodyDic = @{@"version":blockHeight[@"head_block_version"],
                                  @"cursor_num":blockHeight[@"head_block_num"],
                                  @"cursor_label":blockHeight[@"cursor_label"],
                                  @"lifetime":blockHeight[@"head_block_time"],
                                  @"sender":dic[@"account"],
                                  @"contract":@"bottos",
                                  @"method":dic[@"name"],
                                  @"param":dic[@"data"]};
        success(bodyDic);
    }else{
        failure(NSLocalizedString(@"ErrorData", nil));
    }
}

/**
 获取参数hash
 
 @param obj 请求参数
 @param success 成功
 @param failure 失败
 */
- (void)getHash:(NSDictionary *)obj success:(void (^)(NSString *hashData))success failure:(void (^)(NSString *error))failure
{
    
    NSString *url = [[BTONetworkManager share] getServiceNode1_URL:aw_get_hash];
    
    NSDictionary *bodyDic = @{@"sender":obj[@"sender"],
                              @"contract":obj[@"contract"],
                              @"method":obj[@"method"],
                              @"param":obj[@"param"]};
    NSString *bodyStr = [[BTOTool share] convertToJsonString:bodyDic];
    NSLog(@"HashStr------------------%@",bodyStr);

    BTOURLConnection *urlConnection = [[BTOURLConnection alloc] init];
    [urlConnection requestPost:url body:bodyStr success:^(NSString *responseData) {
        
        success(responseData);
        
    } failure:^(NSString *error) {
        failure(error);
    }];
}

/**
 发送到链
 
 @param obj 请求参数
 @param success 成功
 @param failure 失败
 */
- (void)sendToChain:(NSDictionary *)obj success:(void (^)(NSString *responseData))success failure:(void (^)(NSString *error))failure
{
    NSString *bodyStr = [[BTOTool share] convertToJsonString:obj];
    
    NSString *url = [[BTONetworkManager share] getServiceNode1_URL:aw_transaction_send];
    
    BTOURLConnection *urlConnection = [[BTOURLConnection alloc] init];
    [urlConnection requestPost:url body:bodyStr success:^(NSString *responseData) {
        
        success(responseData);
        
    } failure:^(NSString *error) {
        failure(error);
    }];
}

//- (NSString*)dictionaryToJson:(NSDictionary *)dic
//{
//    NSError *parseError = nil;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
//    if(parseError) {
//        NSLog(@"----------dictionary-->json 解析失败：%@",parseError);
//        return nil;
//    }
//    return [self removeSpaceAndNewline:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
//}
//
- (NSString *)removeSpaceAndNewline:(NSString *)str{
    NSString *temp = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return temp;
}

@end
