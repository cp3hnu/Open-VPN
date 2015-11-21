//
//  UIColor+HexString.swift
//  VPN
//
//  Created by CP3 on 15/11/1.
//  Copyright © 2015年 CP3. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init(hexString: String) {
        
        var rgbValue: UInt32 = 0
        
        let regExStr = "^[0-9a-fA-F]{6}$"
        let regEx = try! NSRegularExpression(pattern: regExStr, options: NSRegularExpressionOptions(rawValue: 0))
        let firstMatch = regEx.firstMatchInString(hexString, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, hexString.characters.count))
        
        if firstMatch != nil {
            NSScanner(string: hexString).scanHexInt(&rgbValue)
        } else {
            print("The format of hex string is Wrong. The correct format is RRGGBB(such as \"FF0000\" for red color)")
        }
        
        let red = UInt8((rgbValue & 0xFF0000) >> 16)
        let green = UInt8((rgbValue & 0xFF00) >> 8)
        let blue = UInt8(rgbValue & 0xFF)
        
        self.init(redInt: red, greenInt: green, blueInt: blue, alpha: 1.0)
    }
    
    convenience init(redInt: UInt8, greenInt: UInt8, blueInt: UInt8, alpha: CGFloat) {
        
        self.init(red: CGFloat(redInt)/255.0, green: CGFloat(greenInt)/255.0, blue: CGFloat(blueInt)/255.0, alpha: alpha)
    }
    
    static func tintColor() -> UIColor {
        return UIColor(redInt: 0, greenInt: 122, blueInt: 255, alpha: 1.0)
    }

}
