//
//  KeystoreKeyTool.m
//  keystoreDemo
//
//  Created by WuJiLei on 2018/7/17.
//  Copyright © 2018年 bottos. All rights reserved.
//

#import "KeystoreKeyTool.h"
#import "AnyWallet-Swift.h"
#import "BTOTool.h"

@implementation KeystoreKeyTool

/*创建公私钥*/
- (void)creatPrivateKeyAndPublicKeyWithCompleted: (completedBlock)completedblock{
    NSError *error;
    NSString *key = [KeystoreKeyCreatTool creatPrivateKeyAndPublicKeyAndReturnError:&error];
    if (error) {
        //NSLocalizedString(@"PublicPrivateFail", nil) --> Public and Private Key Creation Failed
        NSError *error = [NSError errorWithDomain:@"PrivateKeyAndPublicKey"
                                             code:-1
                                         userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"PublicPrivateFail", nil) }];
        completedblock(@"",error);
    }else{
        completedblock(key,nil);
    }
}

/*根据私钥和密码生成keystorekey*/
- (void)creatKeyStoreKeyWithPrivateKey:(NSString *)privateKey password:(NSString *)password completed: (completedBlock)completedblock{
    NSError *error;
    NSString *key =  [KeystoreKeyCreatTool creatKeyStoreKeyWithPrivateKey:privateKey password:password error:&error];
    if (error) {
        //NSLocalizedString(@"KeyStoreKeyFail", nil) --> KeyStoreKey creation failed, please pass in the correct privateKey/password
        NSError *error = [NSError errorWithDomain:@"KeyStoreKey"
                                             code:-1
                                         userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"KeyStoreKeyFail", nil) }];
        completedblock(@"",error);
    }else{
        completedblock(key,nil);
    }
    
}

/*根据keystoreKey和密码解出私钥*/
- (void)recoverPrivateKeyWithKeystoreKeyJson:(NSString *)keystoreKeyJson password:(NSString *)password completed: (completedBlock)completedblock{
    
    NSError *error;
    
    //安卓和iOS端生成的version类型不同 这里做了转换 统一替换成int类型
    if (![keystoreKeyJson hasPrefix:@"{"] && ![keystoreKeyJson hasSuffix:@"}"]) {
        //NSLocalizedString(@"login-enter-correct-Keystore", nil) --> Please enter the correct Keystore
        error = [NSError errorWithDomain:@"dataError" code:-2 userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"login-enter-correct-Keystore", nil) }];
        completedblock(@"",error);
    } else {
        NSMutableDictionary *keyDict = [[BTOTool share] convertToDictionary:keystoreKeyJson].mutableCopy;
        if (!keyDict) {
            //NSLocalizedString(@"sdk-json-error", nil) --> Json parsing failed
            error = [NSError errorWithDomain:@"jsonParseError" code:-2 userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"sdk-json-error", nil) }];
            completedblock(@"",error);
        }
        NSString *version = [NSString stringWithFormat:@"%@",keyDict[@"version"]];
        [keyDict setObject:@([version intValue]) forKey:@"version"];
        NSString *keyStoreString = [[BTOTool share] convertToJsonString:keyDict];
        
        NSString *key =  [KeystoreKeyCreatTool recoverKeystoreKeyPrivateKeyWithKeystoreKeyJson:keyStoreString password:password error:&error];
        if (error) {
            //NSLocalizedString(@"sdk-privatekey-password", nil) --> Failed to get PrivateKey, please pass in the correct keystoreKeyJson/password
            NSError *error = [NSError errorWithDomain:@"recoverPrivateKey"
                                                 code:-1
                                             userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"sdk-privatekey-password", nil) }];
            completedblock(@"",error);
        }else{
            completedblock(key,nil);
        }
    }
}

/*根据私钥生成公钥*/
- (void)getPublicKeyWithPrivateKey:(NSString *)privateKey completed: (completedBlock)completedblock{
  NSError *error;
  NSString *key = [KeystoreKeyCreatTool getPublicKeyWithPrivateKey:privateKey error:&error];
  if (error) {
      //NSLocalizedString(@"PrivateKeyCorrect", nil) --> PublicKey calculation, please pass in the correct privateKey
    NSError *error = [NSError errorWithDomain:@"getPublicKey"
                                         code:-1
                                     userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"PrivateKeyCorrect", nil) }];
    completedblock(@"",error);
  }else{
    completedblock(key,nil);
  }
}

@end
