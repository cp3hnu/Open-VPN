//
//  AddCollectionViewCell.swift
//  VPN
//
//  Created by CP3 on 15/11/14.
//  Copyright © 2015年 CP3. All rights reserved.
//

import UIKit

class AddCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clearColor()
        
        let imageView = UIImageView(image: UIImage(named: "add_book"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor.clearColor()
        self.contentView.addSubview(imageView)
        
        self.contentView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .CenterX, relatedBy: .Equal, toItem: self.contentView, attribute: .CenterX, multiplier: 1, constant: 3))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[imageView(==40)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["imageView": imageView]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[imageView(==50)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["imageView": imageView]))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
