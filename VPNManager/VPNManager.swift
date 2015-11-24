//
//  VPNManager.swift
//  VPN
//
//  Created by CP3 on 15/10/31.
//  Copyright © 2015年 CP3. All rights reserved.
//

import UIKit
import NetworkExtension
import VPNKit

typealias CompletionHandler = ((NSError?) -> Void)

class VPNManager: NSObject {
    
    static let sharedInstance = VPNManager()
    
    var manager = NEVPNManager.sharedManager()
    
    /// VPN connection status.
    var status: NEVPNStatus {
        return manager.connection.status
    }
    
    /**
     This function loads the current VPN configuration from the caller's VPN preferences.
     - parameter completionHandler: A block that will be called on the main thread when the load operation is completed
     */
    func loadFromPreferencesWithCompletionHandler(completionHandler: CompletionHandler? = nil) {
        
        manager.loadFromPreferencesWithCompletionHandler {
            (error: NSError?) -> Void in
            
            if let loadError = error {
                print("VPN load from preferences error = \(loadError)")
            }
            
            if let completion = completionHandler {
                completion(error)
            }
        }
    }
    
    /**
     This function removes the VPN configuration from the caller's VPN preferences.
     - parameter completionHandler: A block that will be called on the main thread when the load operation is completed
     */
    func removeFromPreferencesWithCompletionHandler(completionHandler: CompletionHandler? = nil) {
        
        manager.removeFromPreferencesWithCompletionHandler { (error: NSError?) -> Void in
            
            if let removeError = error {
                print("VPN remove from preferences error = \(removeError)")
            }
            
            if let completion = completionHandler {
                completion(error)
            }
        }
    }
    
    /**
     Connecting VPN.
     
     - parameter vpn:               The connecting VPN.
     - parameter prefix:            Distinguish App from App Extension
     - parameter completionHandler: A block that will be called on the main thread when the load operation is completed
     */
    func connectVPN(vpn: VPN, titlePrefix prefix: String? = nil, completionHandler: CompletionHandler? = nil) {
        
        manager.loadFromPreferencesWithCompletionHandler { (error: NSError?) -> Void in
            
            if let loadError = error {
                print("VPN connect to load from preferences error = \(loadError)")
                if let completion = completionHandler {
                    completion(error)
                }
            } else {
                self.saveVPN(vpn, titlePrefix: prefix, completionHandler: completionHandler)
            }
        }
    }
    
    private func saveVPN(vpn: VPN, titlePrefix prefix: String?, completionHandler: CompletionHandler?) {
        
        let ipsec = NEVPNProtocolIPSec()
        ipsec.authenticationMethod = .SharedSecret
        ipsec.useExtendedAuthentication = true
        ipsec.serverAddress = vpn.server
        ipsec.username = vpn.account
        ipsec.localIdentifier = vpn.groupName
        ipsec.disconnectOnSleep = vpn.disconnectOnSleep
        ipsec.passwordReference = VPNKeyChainManager.sharedInstance.passwordForVPNID(vpn.VPNID)
        ipsec.sharedSecretReference = VPNKeyChainManager.sharedInstance.secretForVPNID(vpn.VPNID)
        
        if #available(iOS 9.0, *) {
            manager.protocolConfiguration = ipsec
        } else {
            manager.`protocol` = ipsec
        }
        
        manager.enabled = true
        
        if vpn.isOnDemand {
            manager.onDemandEnabled = true
            
            let connectRule = NEEvaluateConnectionRule(matchDomains: vpn.onDemandRules(), andAction: .ConnectIfNeeded)
            let rule = NEOnDemandRuleEvaluateConnection()
            rule.connectionRules = [connectRule]
            manager.onDemandRules = [rule]
        } else {
            manager.onDemandEnabled = false
        }
        
        let displayName = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleDisplayName") as! String
        let title = vpn.title ?? ""
        var description: String
        if let descPrefix = prefix {
            description = displayName + "-" + descPrefix + "-" + title
        } else {
            description = displayName + "-" + title
        }
        manager.localizedDescription = description
        
        manager.saveToPreferencesWithCompletionHandler { (error: NSError?) -> Void in
            
            if let saveError = error {
                print("VPN save to preferences error = \(saveError)")
                if let completion = completionHandler {
                    completion(error)
                }
            } else {
                do {
                    try self.manager.connection.startVPNTunnel()
                    if let completion = completionHandler {
                        completion(nil)
                    }
                } catch let catchError as NSError {
                    print("VPN start VPN tunnel error = \(catchError)")
                    
                    //iOS 9第一次saveToPreferences安装VPN到设备之后回到App，需要再调用loadFromPreferences，加载VPN设置
                    if (catchError.domain == NEVPNErrorDomain && catchError.code == NEVPNError.ConfigurationInvalid.rawValue)
                    {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.loadFromPreferencesWithCompletionHandler()
                        })
                    }
                    
                    if let completion = completionHandler {
                        completion(catchError)
                    }
                }
            }
        }
    }
    
    /**
     This function is used to stop the VPN tunnel.
     */
    func disConnect() {
        
        manager.connection.stopVPNTunnel()
    }
}

