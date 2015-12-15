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
    func loadVPNPreferences(completionHandler: CompletionHandler? = nil) {
        
        manager.loadFromPreferencesWithCompletionHandler {
            (error: NSError?) -> Void in
            
            if let loadError = error {
                print("Load VPN preferences error = \(loadError)")
            }
            
            if let completion = completionHandler {
                completion(error)
            }
        }
    }
    
    /**
     This function removes the VPN configuration from the caller's VPN preferences.
     - parameter completionHandler: A block that will be called on the main thread when the remove operation is completed
     */
    func removeVPNPreferences(completionHandler: CompletionHandler? = nil) {
        
        manager.removeFromPreferencesWithCompletionHandler { (error: NSError?) -> Void in
            
            if let removeError = error {
                print("Remove VPN preferences error = \(removeError)")
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
     - parameter completionHandler: A block that will be called on the main thread when the connect operation is completed
     */
    func connectVPN(vpn: VPN, titlePrefix prefix: String? = nil, completionHandler: CompletionHandler? = nil) {
        
        self.saveVPN(vpn, titlePrefix: prefix) { [unowned self] (error: NSError?) -> Void in
            
            //Save preferences error
            if let saveError = error {
                if let completion = completionHandler {
                    completion(saveError)
                }
            } else {
                //startVPNTunnel
                self.startConnect(completionHandler)
            }
        }
    }
    
    /**
     Save VPN preferences.
     
     - parameter vpn:               The connecting VPN.
     - parameter prefix:            Distinguish App from App Extension
     - parameter completionHandler: A block that will be called on the main thread when the save operation is completed
     */
    func saveVPN(vpn: VPN, titlePrefix prefix: String?, completionHandler: CompletionHandler? = nil) {
        
        self.loadVPNPreferences { [unowned self] (error: NSError?) -> Void in
            
            //Load preferences error
            if let loadError = error {
                if let completion = completionHandler {
                    completion(loadError)
                }
            } else {
                
                //Save preferences
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
                    self.manager.protocolConfiguration = ipsec
                } else {
                    self.manager.`protocol` = ipsec
                }
                
                self.manager.enabled = true
                
                if vpn.isOnDemand {
                    self.manager.onDemandEnabled = true
                    
                    let connectRule = NEEvaluateConnectionRule(matchDomains: vpn.onDemandRules(), andAction: .ConnectIfNeeded)
                    let rule = NEOnDemandRuleEvaluateConnection()
                    rule.connectionRules = [connectRule]
                    self.manager.onDemandRules = [rule]
                } else {
                    self.manager.onDemandEnabled = false
                }
                
                let displayName = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleDisplayName") as! String
                let title = vpn.title ?? ""
                var description: String
                if let descPrefix = prefix {
                    description = displayName + "-" + descPrefix + "-" + title
                } else {
                    description = displayName + "-" + title
                }
                self.manager.localizedDescription = description
                
                self.manager.saveToPreferencesWithCompletionHandler { (error: NSError?) -> Void in
                    
                    if let saveError = error {
                        print("Save VPN preferences error = \(saveError)")
                    }
                    
                    if let completion = completionHandler {
                        completion(error)
                    }
                }
            }
        }
    }
    
    /**
     Connect VPN according to the current VPN preferences. First call saveVPN method before it.
     
     - parameter completionHandler: A block that will be called on the main thread when the start operation is completed
     */
    func startConnect(completionHandler: CompletionHandler? = nil) {
        do {
            try self.manager.connection.startVPNTunnel()
            if let completion = completionHandler {
                completion(nil)
            }
        } catch let catchError as NSError {
            print("VPN start VPN tunnel error = \(catchError)")
            
            //iOS 9第一次saveToPreferences安装VPN到设备，需要再调用loadFromPreferences，加载VPN设置
            if (catchError.domain == NEVPNErrorDomain && catchError.code == NEVPNError.ConfigurationInvalid.rawValue)
            {
                dispatch_async(dispatch_get_main_queue(), {
                    self.loadVPNPreferences()
                })
            }
            
            if let completion = completionHandler {
                completion(catchError)
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

