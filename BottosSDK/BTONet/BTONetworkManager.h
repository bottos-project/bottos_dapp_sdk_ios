//
//  BTONetworkManager.h
//  AnyWallet
//
//  Created by Tioks on 2019/8/12.
//  Copyright © 2019 ZZL. All rights reserved.
//

//--------------------------------------接口--------------------------------------
#define create_account @"/v1/wallet/createaccount"//注册
#define account_info @"/v1/account/info"//个人信息
#define aw_block_height @"/v1/block/height"//获取区块高度信息
#define aw_block_detail @"/v1/block/detail"//获取区块信息
#define aw_get_hash @"/v1/transaction/getHashForSign2"//获取Hash
#define aw_transaction_send @"/v1/transaction/send"//发送交易信息
#define aw_transaction_get @"/v1/transaction/get"//查询交易信息
#define aw_transaction_status @"/v1/transaction/status"//查询交易状态
#define aw_transaction_status2 @"/v1/transaction/get"//查询交易状态2
#define aw_register_status @"/v1/transaction/status"//查询注册状态
#define aw_account_brief @"/v1/account/brief"//查询账户基本信息
#define aw_account_info @"/v1/account/info"//查询账户详情
#define aw_contract_abi @"/v1/contract/abi"//查询合约ABI
#define aw_contract_code @"/v1/contract/code"//查询合约代码
#define aw_delegate_getall @"/v1/delegate/getall"//查询所有生产者
#define aw_proposal_review @"/v1/proposal/review"//获取转账提案详情
#define aw_transaction_list @"/transferl/queryPersonalTransferlListAuto"//查询交易记录列表
#define aw_transcation_detail @"/trade/queryTradeDetailAuto"//交易记录详情
#define aw_votenote_all_list @"/v1/delegate/getall"//查询所有生产者
#define aw_votehistory_all_list @"/api/historys/vote"//投票记录
#define aw_vote_detail @"/superNode/queryNodeDetailAuto"//节点详情
#define aw_outblock_history @"/block/queryBlockListAuto"//出块历史block/queryBlockListAuto
#define aw_queryVoterList  @"/superNode/queryVoterList" //投票人接口
#define aw_supernode_list @"/superNode/queryNodeListAuto"//超级节点列表
#define aw_multiSignAccount_list @"/getMsignaccount"//多签账号列表
#define aw_multiSignProposal_list @"/getMsignProposal"//多签提案列表
#define aw_supernode_updataNodeInfo @"/superNode/updateNodeInfo" //上传超级节点信息
//-------------------------------------------------------------------------------

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface BTONetworkManager : NSObject
+ (instancetype)share;
- (NSString *)getSignIn_URL:(NSString *)url;
- (NSString *)getCheckSignIn_URL:(NSString *)url;
- (NSString *)getServiceNode1_URL:(NSString *)url;
- (NSString *)getExplore_URL:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
