//
//  EnryCollectionViewCell.swift
//  VPN
//
//  Created by CP3 on 15/11/14.
//  Copyright © 2015年 CP3. All rights reserved.
//

import UIKit

class EntryCollectionViewCell: UICollectionViewCell {
    
    var switchCtrl: UISwitch!
    var indicatorView: UIActivityIndicatorView!
    var titleLabel: UILabel!
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clearColor()
        
        let switchCtrl = UISwitch()
        switchCtrl.translatesAutoresizingMaskIntoConstraints = false
        switchCtrl.userInteractionEnabled = false
        self.contentView.addSubview(switchCtrl)
        self.switchCtrl = switchCtrl
        
        let indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .White)
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.hidesWhenStopped = true;
        indicatorView.backgroundColor = UIColor.clearColor()
        self.contentView.addSubview(indicatorView)
        self.indicatorView = indicatorView
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFontOfSize(14)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .Center
        label.textColor = UIColor.whiteColor()
        label.backgroundColor = UIColor.clearColor()
        self.contentView.addSubview(label)
        self.titleLabel = label;
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[label]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["label": label]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[switchCtrl]-5-[label]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["label": label, "switchCtrl": switchCtrl]))
        
        self.contentView.addConstraint(NSLayoutConstraint(item: switchCtrl, attribute: .CenterX, relatedBy: .Equal, toItem: self.contentView, attribute: .CenterX, multiplier: 1, constant: 0))
        
        self.contentView.addConstraint(NSLayoutConstraint(item: indicatorView, attribute: .CenterY, relatedBy: .Equal, toItem: switchCtrl, attribute: .CenterY, multiplier: 1, constant: 0))
        
        self.contentView.addConstraint(NSLayoutConstraint(item: indicatorView, attribute: .Right, relatedBy: .Equal, toItem: switchCtrl, attribute: .Right, multiplier: 1, constant: -3))
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
