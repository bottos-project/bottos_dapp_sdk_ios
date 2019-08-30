
#import <Foundation/Foundation.h>

FOUNDATION_EXTERN NSString *const kBTOSDKActionLogin;
FOUNDATION_EXTERN NSString *const kBTOSDKActionTransfer;
FOUNDATION_EXTERN NSString *const kBTOSDKActionPushTransaction;


#pragma mark ~~~~ BTOReqObj ~~~~

/*! @class   BTOReqObj
 * @abstract 发起请求的基本数据
 * @discuss  避免自己继承BTOReqObj, 发起请求时只发送SDK内部的BTOReqObj子类;
 */
@interface BTOReqObj : NSObject
@property (nonatomic, copy) NSString *method;         // 方法名 <必须>
@property (nonatomic, copy) NSString *sender;       //合约执行人<必须>,   注册操作时该字段为引荐人账号
@property (nonatomic, copy) NSString *privateKey;   // 私钥，用于签名（不会保存在本地或服务器，只在签名时使用）<必须>,  注册操作时该字段为引荐人私钥
@property (nonatomic, copy, readonly) NSString *protocol;     // 协议名，钱包用来区分不同协议，本协议为 SimpleWallet
@property (nonatomic, copy, readonly) NSString *version;      // 协议版本信息，如1.0
@property (nonatomic, copy) NSString *dappName;     // dapp名字，用于在钱包APP中展示;   <可选>
@property (nonatomic, copy) NSString *dappIcon;     // dapp图标Url，用于在钱包APP中展示，<可选>
@property (nonatomic, copy) NSString *blockchain;   // 底层  "bto"
@property (nonatomic, copy) NSString *actionId;     // 本次支付的唯一标识;
@property (nonatomic, copy) NSNumber *expired;      // 过期时间，unix时间戳
@property (nonatomic, copy) NSString *callback;     // 回调方法名
/**
 * 转账时:
 * @abstract 由dapp生成的业务参数信息，需要钱包在转账时附加在memo中发出去;
 * @discuss  格式为:k1=v1&k2=v2; 钱包转账时还可附加ref参数标明来源;   <可选>
 *           如:k1=v1&k2=v2&ref=walletname
 * 登录时:
 *      作为附加展示信息
 */
@property (nonatomic, copy) NSString *memo;
@property (nonatomic, strong) NSString *dappData;
/*!
 * @abstract 压缩后的协议内容
 * @discuss  a.如果使用了压缩算法，则该字段表示整个json字符串压缩后的内容
 *           b.如果没有压缩，该字段可以为空
 */
@property (nonatomic, copy) NSString *compressedData;
@property (nonatomic, assign) int compress;     //对协议内容压缩方式; 0 表示不压缩, 其他待定

/**
 * @abstract 处理完成后的回调，回调通知DApp;
 * @discuss  格式为: xxx://xxx?param;  xxx部分可自定义;
 */
@property (nonatomic, copy) NSString *callbackSchema;

@end

#pragma mark ~~~ BTORegisterObj ~~~

/*!
 * @class BTORegisterObj
 * @brief 注册授权数据
 */
@interface BTORegisterObj : BTOReqObj

@property (nonatomic, copy) NSString *name;           //用户名;       <必选>

@property (nonatomic, copy) NSString *pubKey;         //公钥;         <必选>

@end

#pragma mark ~~~~ BTOLoginObj ~~~~

/*!
 * @class BTOLoginObj
 * @brief 登录授权数据
 */
@interface BTOLoginObj : BTOReqObj

@property (nonatomic, copy) NSString *wallet;         // 请求授权的BTO账号;   <可选>

@end


#pragma mark ~~~~ BTOTransferObj ~~~~

/*!
 * @class BTOTransferObj
 * @brief 交易/转账数据
 */
@interface BTOTransferObj : BTOReqObj

@property (nonatomic, copy) NSString *from;         // 付款人的BTO账号;   <必须>
@property (nonatomic, copy) NSString *to;           // 收款人的BTO账号;   <必须>
@property (nonatomic, copy) NSNumber *amount;       // 转账数额; <float> <必须>
@property (nonatomic, copy) NSString *symbol;       // 转账的token名称;   <必须>
@property (nonatomic, copy) NSString *contract;     // 转账的token所属的contract账号名;  <必须>
//@property (nonatomic, copy) NSNumber *precision;    // 转账的token精度，小数点后面的位数; <int> <必须>


/*!
 * @abstract 交易的说明信息，钱包在付款UI展示给用户
 * @discuss  最长不要超过128个字节;  <可选>
 */
@property (nonatomic, copy) NSString *desc;

@end

#pragma mark ~~~~ BTOPushTransactionObj ~~~~

/*!
 * @class BTOPushTransactionObj
 * @brief 登录授权数据
 */
@interface BTOPushTransactionObj : BTOReqObj

@property (nonatomic, strong) NSArray *actions;         // json数组 每个对象是一个action

@end

#pragma mark ~~~~ BTOStakeObj ~~~~

/**
 * @class BTOStakeObj
 * @brief 质押/赎回 授权数据
 */
@interface BTOStakeObj : BTOReqObj

@property (nonatomic, copy) NSString *amount; //数量<必须>

@property (nonatomic, copy) NSString *target; //仅在质押操作时使用：时间/空间 传入time/space字符串 time:质押时间资源 space:质押空间资源 <必须>

@property (nonatomic, copy) NSString *source; //仅在赎回操作时使用：时间/空间 传入time/space字符串 time:赎回时间资源 space:赎回空间资源 <必须>

@end

#pragma mark ~~~~ BTOClaimObj ~~~~

/**
 * @class BTOClaimObj
 * @brief 提现
 */
@interface BTOClaimObj : BTOReqObj

@property (nonatomic, copy) NSString *amount; //提现数量<必须>

@end

#pragma mark ~~~~ BTOVoteObj ~~~~

/**
 * @class BTOVoteObj
 * @brief 投票
 */
@interface BTOVoteObj : BTOReqObj

@property (nonatomic, copy) NSString *voteop;       //是否全部投票1：全投；   <必须>
@property (nonatomic, copy) NSString *voter;        //投票人;  <必须>
@property (nonatomic, copy) NSString *delegate;     //投票节点; <必须>
//@property (nonatomic, copy) NSString *amount;       //投票人; <可选>
//@property (nonatomic, copy) NSString *target;       //投票节点; <可选>

@end

#pragma mark ~~~~ BTORewardObj ~~~~

/**
 * @class BTORewardObj
 * @brief 提取奖励
 */
@interface BTORewardObj : BTOReqObj

@property (nonatomic, copy) NSString *account;      //用户名;  <必须>

@end

#pragma mark ~~~~ BTOProposalObj ~~~~

/**
 * @class BTOProposalObj
 * @brief 提案
 */
@interface BTOProposalObj : BTOReqObj

//name为pushmsignproposal（发起提案）时必须,其余情况不填
@property (nonatomic, copy) NSString *to;             // 收款人的BTO账号; <必须>
//name为pushmsignproposal（发起提案）时必须,其余情况不填
@property (nonatomic, copy) NSString *amount;         // BTO数量; <必须>

//name为newmsignaccount（注册多签账号）时必须,其余情况不填
@property (nonatomic, assign) NSInteger threshold; //门限值; <必须>
//name为newmsignaccount（注册多签账号）时必须,其余情况不填
@property (nonatomic, copy) NSString *authority; //授权人列表; <必须>


//name为newmsignaccount（注册多签账号）时不填,其余情况均必填  <--- 注意
@property (nonatomic, copy) NSString *proposer; //提案发起人 <选填>
//name为newmsignaccount（注册多签账号）时不填,其余情况均必填  <--- 注意
@property (nonatomic, copy) NSString *proposal; //提案名称 <选填>

@property (nonatomic, copy) NSString *account; //账号名<必须>

//@property (nonatomic, copy) NSString *symbol;       // 转账的token名称;   <必须>
//@property (nonatomic, copy) NSString *contract;     // 转账的token所属的contract账号名;  <必须>

@end


