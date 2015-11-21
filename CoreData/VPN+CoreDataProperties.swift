//
//  VPN+CoreDataProperties.swift
//  VPN
//
//  Created by CP3 on 15/10/31.
//  Copyright © 2015年 CP3. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension VPN {

    @NSManaged var account: String?
    @NSManaged var disconnectOnSleep: Bool
    @NSManaged var groupName: String?
    @NSManaged var isOnDemand: Bool
    @NSManaged var password: String?
    @NSManaged var rule: String?
    @NSManaged var secretKey: String?
    @NSManaged var server: String?
    @NSManaged var title: String?

}
