//
//  VPNKeyChainManager.swift
//  VPN
//
//  Created by CP3 on 15/11/2.
//  Copyright © 2015年 CP3. All rights reserved.
//

import UIKit

let kKeyChainService = "VPNKeyChainService"
let kKeyChainAccessGroup = "5M6234DYMA.com.zte.VPN"

public class VPNKeyChainManager: NSObject {
    
    public static let sharedInstance = VPNKeyChainManager()
    
    private let keyChain = Keychain(service: kKeyChainService, accessGroup: kKeyChainAccessGroup)
    
    public func setPassword(password: String, forVPNID vpnID: String) {
        
        let key = (vpnID as NSString).lastPathComponent
        do {
            try self.keyChain.set(password, key: key)
        } catch let error as NSError {
            print("KeyChain set password error = \(error)")
        }
    }
    
    public func setSecret(secret: String, forVPNID vpnID: String) {
        var key = (vpnID as NSString).lastPathComponent
        key = key.stringByAppendingString("_secret")
        do {
            try self.keyChain.set(secret, key: key)
        } catch let error as NSError {
            print("KeyChain set secret error = \(error)")
        }
    }
    
    public func passwordForVPNID(vpnID: String) -> NSData? {
        let key = (vpnID as NSString).lastPathComponent
        let persistentRef = self.keyChain[attributes: key]?.persistentRef
        return persistentRef
    }
    
    public func secretForVPNID(vpnID: String) -> NSData? {
        var key = (vpnID as NSString).lastPathComponent
        key = key.stringByAppendingString("_secret")
        let persistentRef = self.keyChain[attributes: key]?.persistentRef
        return persistentRef
    }
}
