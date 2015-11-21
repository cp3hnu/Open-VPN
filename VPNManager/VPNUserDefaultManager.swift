//
//  UserDefaultManager.swift
//  VPN
//
//  Created by CP3 on 15/11/1.
//  Copyright © 2015年 CP3. All rights reserved.
//

import UIKit

let kSelectedVPNID = "Selected_VPNID_UserDefault"

class VPNUserDefaultManager: NSObject {
    
    static let sharedInstance = VPNUserDefaultManager()
    
    lazy var userDefault = NSUserDefaults.standardUserDefaults()
    
    func setSelectVPNID(value: String?) {
        setObject(value, forKey: kSelectedVPNID)
    }
    
    func selectVPNID() -> String? {
        return userDefault.stringForKey(kSelectedVPNID)
    }
    
    func clearSelectVPNID() {
        removeObjectForKey(kSelectedVPNID)
    }
    
    //MARK: - Private
    private func setObject(object: AnyObject?, forKey key: String) {
        userDefault.setObject(object, forKey: key)
        userDefault.synchronize()
    }
    
    private func stringForKey(key: String) -> String? {
        return userDefault.stringForKey(key)
    }
    
    private func removeObjectForKey(key: String) {
        userDefault.removeObjectForKey(key)
    }
}


