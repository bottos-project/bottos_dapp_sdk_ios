//
//  BTOTool.h
//  AnyWallet
//
//  Created by Tioks on 2019/8/12.
//  Copyright © 2019 ZZL. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BTOTool : NSObject
+(instancetype)share;
- (NSString *)hexStringFormData:(NSData *)data;
- (NSString *)convertDataToHexStr:(NSData *)data;
- (NSData *)convertHexStrToData:(NSString *)str;
//NSString-------->NSDictionary
- (NSDictionary *)convertToDictionary:(NSString *)jsonString;
// NSDictionary-------->NSString
- (NSString *)convertToJsonString:(NSDictionary *)dic;
@end

NS_ASSUME_NONNULL_END
