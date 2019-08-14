//
//  BTOObj.h
//  AnyWallet
//
//  Created by ZZL on 2019/5/23.
//  Copyright © 2019 ZZL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BTOObj : NSObject

+(instancetype)share;

@property (strong, nonatomic) NSDictionary *blockHeight_;
@property (strong, nonatomic) NSDictionary *blockDetail_;

@end
