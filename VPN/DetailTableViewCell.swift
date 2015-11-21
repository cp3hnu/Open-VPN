//
//  DetailTableViewCell.swift
//  VPN
//
//  Created by CP3 on 15/11/8.
//  Copyright © 2015年 CP3. All rights reserved.
//

import UIKit

class DetailTableViewCell: UITableViewCell {

    var descLabel: UILabel!
    var textField: UITextField!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .None
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.blackColor()
        label.textAlignment = .Left
        label.backgroundColor = UIColor.clearColor()
        self.contentView.addSubview(label)
        descLabel = label
        
        let textfield = UITextField()
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.contentVerticalAlignment = .Center
        textfield.textColor = UIColor.blackColor()
        textfield.autocorrectionType = .No
        textfield.spellCheckingType = .No
        textfield.autocapitalizationType = .None
        textfield.returnKeyType = .Next
        self.contentView.addSubview(textfield)
        textField = textfield
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[label(==80)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["label": descLabel]))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[label]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["label": descLabel]))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[label]-[textfield(>=0)]-|", options: [NSLayoutFormatOptions.AlignAllTop, NSLayoutFormatOptions.AlignAllBottom], metrics: nil, views: ["label": descLabel, "textfield": textfield]))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
