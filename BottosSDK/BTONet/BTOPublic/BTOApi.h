
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BTORespObj.h"
#import "BTOReqObj.h"

/*!
 * @class BTOApi
 * @brief SDK入口
 */
@interface BTOApi : NSObject

/*!
 * @brief 注册ID
 * @param AppID a) 请确保AppID已经添加在Xcode工程info.plist-> URL types -> URL Schemes里!
 *              b) AppID也作为App回调时的URL跳转, 务必设置好AppID!
 *              c) 为了避免误操作其他App的跳转请求，请设置一个唯一的appID给BTOSDK, 建议为各个SDK添加命名后缀, 如xxxforBTOsdk;
 *
 * @disucss 在AppDelegate -(application:didFinishLaunchingWithOptions:)方法里注册
 */
+ (void)registerAppID:(NSString *)AppID;

/*!
 * @brief 向BTO发起请求
 * @param obj 接收SDK内BTOReqObj的业务子类, 如交易/转账BTOTransferObj, ...
 * @return 成功发起请求会返回YES, 其他情况返回NO;
 */
- (BOOL)sendObj:(BTOReqObj *)obj success:(void (^)(NSDictionary *responseData))success failure:(void(^)(NSError *error))failure;

/*!
 * @brief   处理BTO的回调跳转
 * @discuss 在AppDelegate -(application:openURL:options:)方法里调用
 */
+ (BOOL)handleURL:(NSURL *)url
          options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
           result:(void(^)(BTORespObj *respObj))result;
@end



