//
//  ListTableViewCell.swift
//  VPN
//
//  Created by CP3 on 15/11/8.
//  Copyright © 2015年 CP3. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {

    var checkImageView: UIImageView!
    var titleLabel: UILabel!
    var serverLabel: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .None
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "check_mark")
        self.contentView.addSubview(imageView)
        checkImageView = imageView
        
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.blackColor()
        label.textAlignment = .Left
        label.backgroundColor = UIColor.clearColor()
        self.contentView.addSubview(label)
        titleLabel = label
        
        label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.blackColor()
        label.textAlignment = .Left
        label.backgroundColor = UIColor.clearColor()
        self.contentView.addSubview(label)
        serverLabel = label
        
        checkImageView.setContentHuggingPriority(UILayoutPriorityRequired, forAxis: .Horizontal)
        self.contentView.addConstraint(NSLayoutConstraint(item: checkImageView, attribute: .CenterY, relatedBy: .Equal, toItem: self.contentView, attribute: .CenterY, multiplier: 1, constant: 0))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[imageView]-15-[titleLabel]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["imageView": checkImageView, "titleLabel": titleLabel]))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[titleLabel]-5-[serverLabel]-10-|", options: [NSLayoutFormatOptions.AlignAllLeft, NSLayoutFormatOptions.AlignAllRight], metrics: nil, views: ["titleLabel": titleLabel, "serverLabel": serverLabel]))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
