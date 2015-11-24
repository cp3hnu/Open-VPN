//
//  AppDelegate.swift
//  VPN
//
//  Created by CP3 on 15/10/31.
//  Copyright © 2015年 CP3. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        VPNDataManager.sharedInstance.saveContext()
    }

    // MARK: - Open URL
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        let naviCtrler = self.window!.rootViewController as! UINavigationController
        naviCtrler.popToRootViewControllerAnimated(false)
        
        let listCtrler = naviCtrler.topViewController as! VPNListViewController
        
        if naviCtrler.presentedViewController != nil {
            naviCtrler.dismissViewControllerAnimated(false, completion: {
                listCtrler.addVPNItem()
            })
        } else {
            listCtrler.addVPNItem()
        }
        
        return true
    }
    
    // MARK: - Handoff
    func application(application: UIApplication, willContinueUserActivityWithType userActivityType: String) -> Bool {
        return true
    }
    
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        
        if let userInfo = userActivity.userInfo {
            if let version = userInfo[ActivityVersionKey] as? String where version == ActivityVersionValue {
                
                let naviCtrler = self.window!.rootViewController as! UINavigationController
                naviCtrler.popToRootViewControllerAnimated(false)
                
                let listCtrler = naviCtrler.topViewController as! VPNListViewController
                listCtrler.restoreUserActivityState(userActivity)
                
                return true
            }
        }
        
        return false
    }
    
    func application(application: UIApplication, didFailToContinueUserActivityWithType userActivityType: String, error: NSError) {
        
        if error.code != NSUserCancelledError {
            let message = "The connection to your other device may have been interrupted. Please try again. \(error.localizedDescription)"
            let alertView = UIAlertView(title: "Handoff Error", message:
                message, delegate: nil, cancelButtonTitle: "Dismiss")
            alertView.show()
        }
    }
    
    func application(application: UIApplication, didUpdateUserActivity userActivity: NSUserActivity) {
        userActivity.addUserInfoEntriesFromDictionary([ActivityVersionKey: ActivityVersionValue])
    }
}

