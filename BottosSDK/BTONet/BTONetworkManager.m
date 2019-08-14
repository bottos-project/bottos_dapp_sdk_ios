//
//  BTONetworkManager.m
//  AnyWallet
//
//  Created by Tioks on 2019/8/12.
//  Copyright © 2019 ZZL. All rights reserved.
//

#define SignIn_URL @"http://wallet.chainbottos.com:6869" //注册帐号
#define Check_SignIn_URL @"http://wallet.chainbottos.com:8689" //查询账号信息
#define ServiceNode1_URL @"http://servicenode1.chainbottos.com:8689" //接收普通交易
#define Explore_URL @"http://125.94.34.23:8080" //查询记录类

#import "BTONetworkManager.h"
#import "BTOTool.h"

@interface BTONetworkManager()<NSCopying,NSMutableCopying>

@end

static BTONetworkManager *manager = nil;

@implementation BTONetworkManager
+ (instancetype)share{
    
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manager = [[BTONetworkManager alloc] init];
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

- (NSString *)getCheckSignIn_URL:(NSString *)url {
    return [NSString stringWithFormat:@"%@%@",Check_SignIn_URL,url];
}

- (NSString *)getSignIn_URL:(NSString *)url{
    return [NSString stringWithFormat:@"%@%@",SignIn_URL,url];
}

- (NSString *)getServiceNode1_URL:(NSString *)url {
    return [NSString stringWithFormat:@"%@%@",ServiceNode1_URL,url];
}

- (NSString *)getExplore_URL:(NSString *)url {
    return [NSString stringWithFormat:@"%@%@",Explore_URL,url];
}

@end
