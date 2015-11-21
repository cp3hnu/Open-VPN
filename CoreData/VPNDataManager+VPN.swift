//
//  VPNDataManager+VPN.swift
//  VPN
//
//  Created by CP3 on 15/11/1.
//  Copyright © 2015年 CP3. All rights reserved.
//

import Foundation
import CoreData

extension VPNDataManager {
    
    func fetchAllVPNs() -> [VPN] {
        
        var vpns = [VPN]()
        
        //let request = NSFetchRequest(entityName: kEntityName)
        
        let entity = NSEntityDescription.entityForName(kEntityName, inManagedObjectContext: self.managedObjectContext)
        
        let request = NSFetchRequest()
        request.entity = entity
        
        do {
            let result = try managedObjectContext .executeFetchRequest(request)
            vpns = result as! [VPN]
            
        } catch let error as NSError {
            print("CoreData fetch all VPNs error = \(error)")
        }
        
        return vpns
    }
    
    func insertVPN() -> VPN {
        
        let entity = NSEntityDescription.entityForName(kEntityName, inManagedObjectContext: managedObjectContext)
        let managedObject = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedObjectContext)
        return managedObject as! VPN
    }
    
    func deleteVPN(vpn: VPN) {
        
        managedObjectContext.deleteObject(vpn)
        saveContext()
    }
}
