//
//  KeystoreKeyCreatTool.swift
//  keystoreDemo
//
//  Created by WuJiLei on 2018/7/16.
//  Copyright © 2018年 bottos. All rights reserved.
//

import UIKit
import Foundation //Members
import TrustCore

@objcMembers class KeystoreKeyCreatTool: NSObject {
  //1 生成公私钥
  @objc  class  public  func creatPrivateKeyAndPublicKey() throws -> String{
    let privateKey = PrivateKey()
    let publicKeyData =  Crypto.getPublicKey(from: (privateKey.data))
    //以太坊币 应是对应以太坊公钥
    let publicKey =  PublicKey(data: publicKeyData)
    if publicKey == nil {
      return ""
    }
    let privateKeyStr =  "\(privateKey)"
    let publicKeyStr =  "\(publicKey!)"
    var dict = [String : String]()
    dict["privateKey"] = privateKeyStr
    dict["publicKey"] = publicKeyStr
    //print("dict=\(dict)")
    let  jsonData = try? JSONSerialization.data(withJSONObject: dict, options: [])
    let jsonResult = String.init(data: jsonData!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
    return jsonResult!
  }
  
  //2 根据私钥和密码生成keystorekey
  @objc  class  public  func creatKeyStoreKeyWith(privateKey:String, password:String ) throws -> String{
    let privateKeyData =  self.hexStringToBytes(hexString: privateKey)!
    guard let privateKey = PrivateKey(data: privateKeyData) else {
      throw KeyStore.Error.invalidKey
    }
    //钱币类型用以太坊币
    let keystoreKey = try KeystoreKey.init(password: password, key: privateKey, coin: SLIP.CoinType.ethereum)
    let  keystoreKeyData = try?  JSONEncoder().encode(keystoreKey)
    let keystoreKeyJsonString = String.init(data: keystoreKeyData!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
    return keystoreKeyJsonString
  }
  //3 根据keystoreKey和密码解出私钥
  @objc  class  public  func recoverKeystoreKeyPrivateKey(keystoreKeyJson:String, password:String) throws -> String{
    let keystoreKeyData =  keystoreKeyJson.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
    let keystoreKey = try JSONDecoder().decode(KeystoreKey.self, from: keystoreKeyData!)
    
    
    var privateKeyData = try keystoreKey.decrypt(password: password)
    // print("privateKeyData=\(privateKeyData)")
    defer {
      privateKeyData.clear()
    }
    guard let privateKey = PrivateKey(data: privateKeyData) else {
      throw KeyStore.Error.invalidKey
    }
    return "\(privateKey)"
  }
  //4 根据私钥生成publicKey
  @objc  class  public  func getPublicKeyWith(privateKey:String) throws -> String{
    let privateKeyData =  self.hexStringToBytes(hexString: privateKey)!
    guard let privateKey = PrivateKey(data: privateKeyData) else {
      throw KeyStore.Error.invalidKey
    }
    
    let publicKeyData =  Crypto.getPublicKey(from: (privateKey.data))
    //以太坊币 应是对应以太坊公钥
    let publicKey =  PublicKey(data: publicKeyData)
    if publicKey == nil {
      return ""
    }
    return "\(publicKey!)"
  }
  
  class  public func hexStringToBytes(hexString: String) -> Data? {
    //  guard let chars = hexString.cStringUsingEncoding(NSUTF8StringEncoding) else { return nil}
    guard let chars = hexString.cString(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) else { return nil}
    var i = 0
    let length = hexString.count //characters.count
    
    let data = NSMutableData(capacity: length/2)
    var byteChars: [CChar] = [0, 0, 0]
    
    var wholeByte: CUnsignedLong = 0
    
    while i < length {
      byteChars[0] = chars[i]
      i+=1
      byteChars[1] = chars[i]
      i+=1
      wholeByte = strtoul(byteChars, nil, 16)
      data?.append(&wholeByte, length: 1)
    }
    return data as Data?
  }
}
