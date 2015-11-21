//
//  VPN.swift
//  VPN
//
//  Created by CP3 on 15/10/31.
//  Copyright © 2015年 CP3. All rights reserved.
//

import Foundation
import CoreData

@objc(VPN)
class VPN: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    
    var VPNID: String {
        
        return self.objectID.URIRepresentation().absoluteString
    }
    
    ///将rule:String转换成[String]，以换行符和逗号(,)作为分隔符
    func onDemandRules() -> [String] {
        
        var rules = [String]()
        
        guard let ruleString = rule else {
            return rules
        }
        
        if ruleString.isEmpty {
            return rules
        }
        
        let characterSet = VPN.separatorCharacterSet()
        let array = ruleString.componentsSeparatedByCharactersInSet(characterSet)
        for str in array {
            
            let trimWhitespace = str.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            if !trimWhitespace.isEmpty {
                rules.append(trimWhitespace)
            }
        }
        
        return rules
    }
    
    ///使用换行符和逗号(,)作为分隔符
    static func separatorCharacterSet() -> NSCharacterSet {
        
        let characterSet = NSMutableCharacterSet.newlineCharacterSet()
        characterSet.addCharactersInString(",")
        return characterSet
    }
}
