//
//  VPNDataManager.swift
//  VPN
//
//  Created by CP3 on 15/10/31.
//  Copyright © 2015年 CP3. All rights reserved.
//

let kAppModelName = "VPN"
let kEntityName = "VPN"
let kSqliteFileName = "VPN.sqlite"
let kAppGroupIdentifier = "group.com.zte.VPN"

import UIKit
import CoreData

class VPNDataManager: NSObject {

    static let sharedInstance = VPNDataManager()
    
    ///App与Extension共享的目录
    lazy var directoryURL: NSURL! = {
        
        return NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(kAppGroupIdentifier)
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        
        let modelURL = NSBundle.mainBundle().URLForResource(kAppModelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL:modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        
        let storeURL = self.directoryURL.URLByAppendingPathComponent(kSqliteFileName)
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        do {
            try persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL:storeURL, options: nil)
        } catch let error as NSError {
            print("CoreData add persistent store coordinator error = \(error)")
        }
        
        return persistentStoreCoordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
    }()
    
    func saveContext() {
        
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch let error as NSError {
                print("CoreData save context error = \(error)")
            }
        }
    }
}



