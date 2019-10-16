//
//  KeystoreKeyTool.h
//  keystoreDemo
//
//  Created by WuJiLei on 2018/7/17.
//  Copyright © 2018年 bottos. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^completedBlock)(NSString *key,NSError *error);

@interface KeystoreKeyTool : NSObject
/*创建公私钥*/
- (void)creatPrivateKeyAndPublicKeyWithCompleted: (completedBlock)completedblock;
/*根据私钥,密码,账号生成keystore*/
- (void)creatKeyStoreKeyWithPrivateKey:(NSString *)privateKey password:(NSString *)password account:(NSString *)account completed:(completedBlock)completedblock;
/*根据keystoreKey和密码解出私钥*/
- (void)recoverPrivateKeyWithKeystoreKeyJson:(NSString *)keystoreKeyJson password:(NSString *)password completed: (completedBlock)completedblock;
/*根据私钥计算公钥*/
- (void)getPublicKeyWithPrivateKey:(NSString *)privateKey completed: (completedBlock)completedblock;
@end
