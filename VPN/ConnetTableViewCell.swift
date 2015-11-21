//
//  ConnetTableViewCell.swift
//  VPN
//
//  Created by CP3 on 15/11/8.
//  Copyright © 2015年 CP3. All rights reserved.
//

import UIKit

class ConnetTableViewCell: UITableViewCell {
    
    var statusLabel: UILabel!
    var connectSwitch: UISwitch!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .None
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.blackColor()
        label.textAlignment = .Left
        label.backgroundColor = UIColor.clearColor()
        self.contentView.addSubview(label)
        statusLabel = label
        
        let switchControl = UISwitch()
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(switchControl)
        connectSwitch = switchControl
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[label]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["label": statusLabel]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[label]-(>=0)-[switchControl]-|", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: ["label": label, "switchControl": connectSwitch]))
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
