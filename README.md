# iOS BottosSDK使用介绍
## 一：SDK集成（CocoaPods）
##### 1:使用CocoaPods导入以下第三方到项目中
> pod 'CryptoSwift', '~> 0.10.0'
>
> pod 'TrezorCrypto', '~> 0.0.9'
>
> pod 'TrustCore', :git=>'https://github.com/TrustWallet/trust-core', :branch=> 'master'
##### 2:下载BottosSDK添加到项目中，导入BTOSDK.h。
##### 3:因为SDK中的KeystoreTool相关方法通过Swift和Objective-C混编生成，若要使用，必须先在项目中进行相关设置，设置如下。
（1）：Build Setting-->Packaing-->Defines Module置为YES
（2）：Build Setting-->Packaing-->Product Module Name设置为AnyWallet
## 二：创建公钥、私钥、Keystore
##### 1:首先在需要创建的类中，导入KeystoreKeyTool.h。
##### 2:然后调用实例方法,进行公私钥创建。方法如下：
>-(void)creatPrivateKeyAndPublicKeyWithCompleted: (completedBlock)completedblock
##### 3:完成后“completedBlock”内部会包含公私钥的json字符串，可通过BTOTool.h中的convertToDictionary实例方法转化成字典。并取出公私钥。
##### 4:拿到私钥后，输入密码。之后将密码和私钥传入KeystoreKeyTool类中的创建Keystore实例方法中。方法如下：
>-(void)creatKeyStoreKeyWithPrivateKey:(NSString *)privateKey password:(NSString *)password completed: (completedBlock)completedblock
##### “completedblock”block中包含Keystore，取出并进行保存.
##### 5:后续进行交易操作时，需要传递私钥进行签名验证。可通过传入Keystore和密码，调用KeystoreKeyTool类中解出私钥方法进行获取。方法如下：
>-(void)recoverPrivateKeyWithKeystoreKeyJson:(NSString *)keystoreKeyJson password:(NSString *)password completed: (completedBlock)completedblock

## 三：接口相关说明
###### 注：所有接口与域名均以宏的形式定义在BTONetworkManager类中，可以根据需要自行使用。
### 创建账号
>**接口说明**：注册Bottos钱包账号
>
>**URL**：/v1/wallet/createaccount
>
> **返回格式**：JSON
>
> **请求方式**：POST
>
> | 参数                | 必选 | 类型 | 默认值 | 说明 |
> | -------------- | ------- | -------- | ------ | -------- |
> | account_name|   True   |   string   |    无    |   账户名   |
> |public_key|   True   |   string   |    无    |   账户公钥  |
> | referrer |   False   |   string   |    无    |    引荐人  |

**响应字段：**

| 参数         | 类型       | 说明                                 |
| ------------ | ---------- | ------------------------------------ |
| errcode      | uint32     | 错误码，0-相应成功，其他见错误码章节 |
| msg          | string     | 响应描述                             |
| result       | jsonObject | 响应结果，具体数据详情               |

**接口示例**

> 地址：<http://127.0.0.1:6869/v1/wallet/createaccount >

- 请求：

```
{
"account_name": "testaccount1",
"public_key": "0454f1c2223d553aa6ee53ea1ccea8b7bf78b8ca99f3ff622a3bb3e62dedc712089033d6091d77296547bc071022ca2838c9e86dec29667cf740e5c9e654b6127f",
"referrer": "bottos"    
}
```

- 响应：

```
HTTP/1.1 200 OK
{
"errcode": 0,
"msg": "success",
"result": {
"trx": {
"version": 65536,
"cursor_num": 1933,
"cursor_label": 503463811,
"lifetime": 1548325777,
"sender": "bottos",
"contract": "bottos",
"method": "newaccount",
"param": "dc0002da000c746573746163636f756e7431da008230343534663163323232336435353361613665653533656131636365613862376266373862386361393966336666363232613362623365363264656463373132303839303333643630393164373732393635343762633037313032326361323833386339653836646563323936363763663734306535633965363534623631323766",
"sig_alg": 1,
"signature": "b3b5dedc31a63947b5cd058cae8723daf9e0489439f9a9328b2c3e089bcf1df97d245ad36a553619f99ac166cbb7d4a81be6aaf4960c0dd5d8a22ad58f9f7a95"
},
"trx_hash": "e5281d1bbc7b70f955136fa9c32cfecadebf6f07956a55ad85ff7a5f9e32428a"
}
}
```



### 交易相关
###### 注：所有交易相关接口，均通过同一个接口实现。内部根据所传递的参数不同，对业务进行区分。其中所有参数传递均是通过BTOReqObj类进行，BTOReqObj类中包含所有交易相关接口的共同参数属性，需根据要求进行传递。在每项业务单独需要的参数中需实现BTOReqObj子类中所定义的属性值进行传递。为避免自己继承BTOReqObj, 发起请求时只发送SDK内部的BTOReqObj子类。

#### BTOReqObj通用参数
>**接口说明**： 发送交易信息
>
>**URL**：/v1/transaction/send
>
> **返回格式**：JSON
>
> **请求方式**：POST
>
> | 属性                | 必选 | 类型 | 默认值 | 说明 |
> | -------------- | ------- | -------- | ------ | -------- |
> | method|   True   |   string   |    无    |   业务方法名（必须全为小写,详细请查看对象试例中method属性值）   |
> |sender|   True   |   string   |    无    |   执行人  |
> | privateKey |   True   |   string   |    无    |    私钥（只在签名时需要，不会做保存操作）  |
> |memo|   False   |   string   |    无    |  备注 |

#### 1:BTOTransferObj（转账/交易）
该子类共包含5个特有参数
> | 属性                | 必选 | 类型 | 默认值 | 说明 |
> | -------------- | ------- | -------- | ------ | -------- |
> | from|   True   |   string   |    无    |   付款人的BTO账号   |
> |to|   True   |   string   |    无    |   收款人的BTO账号  |
> | amount |   True   |   float   |    无    |    转账数额  |
> | symbol |   True   |   string   |    BTO   |    转账的token名称(传默认值)  |
> | contract |   True   |   string   |   bottos    |    转账的token所属的contract账号名(传默认值)  |
- 构建转账请求对象实例：
```
BTOTransferObj *transfer = [BTOTransferObj new];
transfer.sender = @"senderAccount";
transfer.symbol = @"BTO";
transfer.contract = @"bottos";
transfer.to = @"receiveAccount";
transfer.memo = @"aaa";
transfer.privateKey = privateKey;
transfer.amount = @(1.0);
transfer.method = @"transfer";
```
#### 2:BTOStakeObj（质押/赎回）
> | 属性                | 必选 | 类型 | 默认值 | 说明 |
> | -------------- | ------- | -------- | ------ | -------- |
> | amount |   True   |   float   |    无    |    数量  |
> |target|   True   |   string   |    time/space   |   仅在质押操作时使用：时间/空间 传入time/space字符串  time:质押时间资源 space:质押空间资源  |
> | source |   True   |   string   |    time/space    |    仅在赎回操作时使用：时间/空间 传入time/space字符串  time:赎回时间资源 space:赎回空间资源  |
- 构建**质押**请求对象实例：
```
BTOStakeObj *stakeSpaceObj = [BTOStakeObj new];
stakeSpaceObj.sender = @"senderAccount";
stakeSpaceObj.method = @"stake";
stakeSpaceObj.amount = @"1.34";
stakeSpaceObj.target = @"space";//空间质押  若为时间质押则传time
stakeSpaceObj.privateKey = privateKey;
```
- 构建**赎回**请求对象实例：
```
BTOStakeObj *stakeSpaceObj = [BTOStakeObj new];
stakeSpaceObj.sender = @"senderAccount";
stakeSpaceObj.method = @"unstake";
stakeSpaceObj.amount = @"1.34";
stakeSpaceObj.source = @"space";//空间赎回  若为时间赎回则传time
stakeSpaceObj.privateKey = privateKey;
```

#### 3:BTOClaimObj（提现）
> | 属性                | 必选 | 类型 | 默认值 | 说明 |
> | -------------- | ------- | -------- | ------ | -------- |
> | amount |   True   |   string   |    无    |    提现数量  |
- 构建**提现**请求对象实例：
```
BTOClaimObj *claimObj = [BTOClaimObj new];
claimObj.method = @"claim";
claimObj.sender = @"senderAccount";
claimObj.amount = @"1.34";
claimObj.privateKey = privateKey;
```

#### 4:BTOVoteObj（投票）
> | 属性                | 必选 | 类型 | 默认值 | 说明 |
> | -------------- | ------- | -------- | ------ | -------- |
> | voteop |   True   |   string   |    无    |    是否全部投票1：全投；  |
> |voter|   True   |   string   |    无  |  投票人|
> | delegate |   True   |   string   |    无    |    投票节点 |
- 构建**投票**请求对象实例：
```
BTOVoteObj *voteObj = [BTOVoteObj new];
voteObj.sender = @"senderAccount";
voteObj.method = @"votedelegate"
voteObj.privateKey = privateKey;
voteObj.voteop = @"1";
voteObj.voter = @"voterAccount";
```

#### 5:BTORewardObj（提取奖励）
> | 属性                | 必选 | 类型 | 默认值 | 说明 |
> | -------------- | ------- | -------- | ------ | -------- |
> | account |   True   |   string   |    无    |    用户名  |

- 构建**提取奖励**请求对象实例：
```
BTORewardObj *rewardObj = [BTORewardObj new];
rewardObj.sender = @"senderAccount";
rewardObj.method = @"claimreward";
rewardObj.account = @"rewardAccount";
rewardObj.privateKey = privateKey;
```

#### 6:BTOProposalObj（提案/创建多签账户）
> | 属性                | 必选 | 类型 | 默认值 | 说明 |
> | -------------- | ------- | -------- | ------ | -------- |
> | to |   False   |   string   |    无    |  收款人的BTO账号【name为pushmsignproposal（发起提案）时必填,其余情况不填】  |
> | amount |   False   |   string   |    无    | BTO数量【name为pushmsignproposal（发起提案）时必填,其余情况不填】 |
> | threshold |   False   |   int   |    无    |    门限值【name为newmsignaccount（注册多签账号）时必填,其余情况不填】  |
> | authority |   False   |   string(数组json字符串) eg:[{\"author_account\":\"awanghui12\",\"weight\":3},{\"author_account\":\"suibian001\",\"weight\":3}]   |    无    |    授权人列表【name为newmsignaccount（注册多签账号）时必填,其余情况不填】  |
> | proposer |   True   |   string   |    无    |    提案发起人【name为newmsignaccount（注册多签账号）时**不填**,其余情况均必填  <--- 注意】  |
> | proposal |   True   |   string   |    无    |    提案名称【name为newmsignaccount（注册多签账号）时不填,其余情况均必填  <--- 注意】  |
> | account |   True   |   string   |    无    |    多签账号  |

- 构建**创建多签账号**请求对象实例：
```
BTOProposalObj *proposalObj = [BTOProposalObj new];
proposalObj.sender = @"senderAccount";
proposalObj.method = @"newmsignaccount";
proposalObj.account = @"MsignAccount";
proposalObj.threshold = 3;
proposalObj.privateKey = privateKey;
proposalObj.authority = [{\"author_account\":\"awanghui12\",\"weight\":3},{\"author_account\":\"suibian001\",\"weight\":3}] ;
```

- 构建**发起提案**请求对象实例：
```
BTOProposalObj *proposal = [BTOProposalObj new];
proposal.sender = @"senderAccount";
proposal.account = @"MsignAccount";
proposal.method = @"pushmsignproposal";
proposal.proposal = @"proposalName";
proposal.proposer = @"proposer";
proposal.to = @"receiveAccount";
proposal.memo = @"memo";
proposal.amount = @"123";
proposal.privateKey = privateKey;
```

#### 构建请求对象完成，发送网络请求。具体实现如下：
```
BTOApi *api = [BTOApi new];
[api sendObj:obj success:^(NSDictionary *responseData) {
//success
} failure:^(NSError *error) {
//failure
}];
```
**接口示例**

> 地址：< http://servicenode1.chainbottos.com:8689/v1/transaction/send >

- 请求：
```
{
"version": 1,
"cursor_num": 719,
"cursor_label": 2997806499,
"lifetime": 1534143531,
"sender": "bottos",
"contract": "bottos",
"method": "newaccount",
"param": "dc0002da0009757365727465737431da008230346430373538383030353634383861393864613365643234623766613265633061623864383464343764623534366333663138316137363462613366613165383237396637363434303963343164653031623030383065623161616565623935303966373932333535323061373565333432343432393134346234336331303462",
"sig_alg": 1,
"signature": "f0069bc363a55dc22207c75d15cc75524bf4950159130c6bf385f6f1ca877177362ad5ab51108e7f396043e3aee7058f1ca6a40fd6c79a8483e439d2e2bccf2c"
}
```

- 响应：
```
HTTP/1.1 200 OK
{
"errcode": 0,
"msg": "trx receive succ",
"result": {
"trx": {
"version": 1,
"cursor_num": 719,
"cursor_label": 2997806499,
"lifetime": 1534143531,
"sender": "delta",
"contract": "bottos",
"method": "newaccount",
"param": "dc0002da0009757365727465737431da008230346430373538383030353634383861393864613365643234623766613265633061623864383464343764623534366333663138316137363462613366613165383237396637363434303963343164653031623030383065623161616565623935303966373932333535323061373565333432343432393134346234336331303462",
"sig_alg": 1,
"signature": "f0069bc363a55dc22207c75d15cc75524bf4950159130c6bf385f6f1ca877177362ad5ab51108e7f396043e3aee7058f1ca6a40fd6c79a8483e439d2e2bccf2c"
},
"trx_hash": "1815f4d4dfb52b88fb445efc255a5be6275fc3ad694f802c01c40644f09b651f"
}
}
```

###### 注：其中BTOApi为BottosSDK中的网络请求类，sendObj方法为处理交易的方法。obj对象为以上业务所构建的对象实例。调用者只需关注子类对象参数，和子类业务类型即可。responseData和error为网络请求返回的正确或错误的数据，调用者根据自身需求进行业务处理。
