//
//  BTOObj.m
//  AnyWallet
//
//  Created by ZZL on 2019/5/23.
//  Copyright © 2019 ZZL. All rights reserved.
//

#import "BTOObj.h"

@interface BTOObj ()

@end

@implementation BTOObj

+ (instancetype)share{
    static BTOObj *share;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        share = [[BTOObj alloc] init];
    });
    return share;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.blockHeight_ = NULL;
        self.blockDetail_ = NULL;
    }
    return self;
}

@end
