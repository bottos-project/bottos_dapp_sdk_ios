//
//  BTOHashManager.m
//  AnyWallet
//
//  Created by ZZL on 2019/5/28.
//  Copyright © 2019 ZZL. All rights reserved.
//

#import "BTOHashManager.h"
#import "BTOURLConnection.h"
#import "BTOTool.h"
@interface BTOHashManager()

@property(nonatomic,strong) void(^statusBlock)(NSDictionary *statusStr);
@property(nonatomic,strong) void(^failureBlock)(NSString *error);

@property (strong, nonatomic) NSTimer *timerFire;
@property (assign, nonatomic) int timerInt;
@property (copy, nonatomic) NSString *statusStr;
@property (nonatomic, assign) NSInteger isRegister;
@end

@implementation BTOHashManager

- (void)getHashStatus:(NSString *)statusStr status:(void (^)(NSDictionary * _Nonnull))status failure:(void (^)(NSString * _Nonnull))failure {
    self.statusStr = statusStr;
    self.statusBlock = status;
    self.failureBlock = failure;
    self.isRegister = NO;
    _timerFire = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    [_timerFire fire];
    
    _timerInt = 0;
}

- (void)getRegisterStatus:(NSString *)statusStr status:(void (^)(NSDictionary * _Nonnull))status failure:(void (^)(NSString * _Nonnull))failure {
    self.statusStr = statusStr;
    self.statusBlock = status;
    self.failureBlock = failure;
    self.isRegister = YES;
    self->_timerFire = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    [self->_timerFire fire];
    self->_timerInt = 0;
}

- (void)timerAction{
    _timerInt++;
    NSLog(@"----------%d",_timerInt);
    if (_timerInt == 30) {
        [_timerFire invalidate];
        _timerFire = nil;
        self.failureBlock(@"Request not responded");
        return;
    }
    
    NSString *url;
    if (self.isRegister) {
        url = [[BTONetworkManager share] getCheckSignIn_URL:aw_register_status];
    } else {
        url = [[BTONetworkManager share] getServiceNode1_URL:aw_transaction_status];
    }
    NSDictionary *bodyDic = @{@"trx_hash":self.statusStr};
    NSString *bodyStr = [[BTOTool share] convertToJsonString:bodyDic];
    BTOURLConnection *urlConnection = [[BTOURLConnection alloc] init];
    [urlConnection requestPost:url body:bodyStr success:^(NSString *responseData) {
        NSDictionary *responseDic = [[BTOTool share] convertToDictionary:responseData];
        NSLog(@"getHash------------------%@----%p",responseDic,&responseDic);
        NSInteger code = [responseDic[@"errcode"] intValue];
        NSLog(@"errcode------------------%ld\n",code);
        
        if (code != AWErrorCodePending && code != AWErrorCodePacked && code != AWErrorCodeSending && code != AWErrorCodeNotFound) {
            NSLog(@"%p timer already fire",&self->_timerFire);
            [self->_timerFire invalidate];
            self->_timerFire = nil;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.statusBlock(responseDic);
        });
    } failure:^(NSString *error) {
        self.failureBlock(error);
    }];
}

//查询接口2
- (void)getHashStatus2:(NSString *)statusStr status:(void (^)(NSDictionary * _Nonnull))status failure:(void (^)(NSString * _Nonnull))failure {
    self.statusStr = statusStr;
    self.statusBlock = status;
    self.failureBlock = failure;
    _timerFire = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerAction2) userInfo:nil repeats:YES];
    [_timerFire fire];
    
    _timerInt = 0;
}

- (void)timerAction2 {
    _timerInt++;
    NSLog(@"----------%d",_timerInt);
    if (_timerInt == 30) {
        [_timerFire invalidate];
        _timerFire = nil;
//        self.failureBlock(NSLocalizedString(@"RequestNot", nil));
        self.failureBlock(@"Request not responded");
        return;
    }
    
    NSString *url = [[BTONetworkManager share] getServiceNode1_URL:aw_transaction_status2];
    NSDictionary *bodyDic = @{@"trx_hash":self.statusStr};
    NSString *bodyStr = [[BTOTool share] convertToJsonString:bodyDic];
    BTOURLConnection *urlConnection = [[BTOURLConnection alloc] init];
    [urlConnection requestPost:url body:bodyStr success:^(NSString *responseData) {
        NSDictionary *responseDic = [[BTOTool share] convertToDictionary:responseData];
        NSLog(@"getHash2------------------%@",responseDic);
        NSInteger code = [responseDic[@"errcode"] intValue];
        NSLog(@"errcode------------------%ld\n",code);
        self.statusBlock(responseDic);
        if (code != AWErrorCodePending && code != AWErrorCodePacked && code != AWErrorCodeSending && code != 10201) {
            [self->_timerFire invalidate];
            self->_timerFire = nil;
        }
    } failure:^(NSString *error) {
        self.failureBlock(error);
    }];
}

@end

