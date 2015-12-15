//
//  TodayViewController.swift
//  VPN-Widget
//
//  Created by CP3 on 15/10/31.
//  Copyright © 2015年 CP3. All rights reserved.
//

import UIKit
import NotificationCenter
import NetworkExtension
import CoreData

let NormalHeight: Int = 90
let VPNCellReuseIdentifier = "VPNCell"
let AddCellReuseIdentifier = "AddCell"

@objc (TodayViewController)
class TodayViewController: UIViewController, NCWidgetProviding, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var collectionView: UICollectionView!
    var vpns = [VPN]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        
        VPNManager.sharedInstance.loadVPNPreferences()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "vpnStatusDidChange:", name: NEVPNStatusDidChangeNotification, object: nil)
        
        self.preferredContentSize = CGSizeMake(0, CGFloat(NormalHeight))
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSizeMake(80, 10+31+5+17+10)
        layout.minimumLineSpacing = 10
        
        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.registerClass(EntryCollectionViewCell.self, forCellWithReuseIdentifier: VPNCellReuseIdentifier)
        collectionView.registerClass(AddCollectionViewCell.self, forCellWithReuseIdentifier: AddCellReuseIdentifier)
        collectionView.backgroundColor = UIColor.clearColor()
        self.view.addSubview(collectionView)
        self.collectionView = collectionView
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[collectionView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["collectionView": collectionView]))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[collectionView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["collectionView": collectionView]))
        
        self.vpns = VPNDataManager.sharedInstance.fetchAllVPNs()
        self.preferredContentSize = CGSizeMake(0, CGFloat((self.vpns.count + 1 + 3)/4 * NormalHeight))
        self.collectionView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.preferredContentSize = CGSizeMake(0, self.collectionView.contentSize.height)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - NCWidgetProviding
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        print("widgetPerformUpdateWithCompletionHandler")
        completionHandler(NCUpdateResult.NewData)
    }
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }
    
    // MARK: - UICollectionViewDelegate
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.vpns.count + 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if (indexPath.row != self.vpns.count) {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(VPNCellReuseIdentifier, forIndexPath: indexPath) as! EntryCollectionViewCell
            
            let vpn = self.vpns[indexPath.row];
            cell.titleLabel.text = vpn.title;
            
            if let selectID = VPNUserDefaultManager.sharedInstance.selectVPNID() where vpn.VPNID == selectID {
                
                switch (VPNManager.sharedInstance.status) {
                case .Connecting,
                    .Reasserting:
                    cell.titleLabel.textColor = UIColor.yellowColor()
                    cell.switchCtrl.on = true
                    cell.indicatorView.activityIndicatorViewStyle = .Gray;
                    cell.indicatorView.startAnimating()
                    
                case .Disconnecting:
                    cell.titleLabel.textColor = UIColor.yellowColor()
                    cell.switchCtrl.on = false
                    cell.indicatorView.activityIndicatorViewStyle = .White;
                    cell.indicatorView.startAnimating()
                    
                case .Connected:
                    cell.titleLabel.textColor = UIColor(red: 0.0, green: 0.75, blue: 1.0, alpha: 1.0)
                    cell.switchCtrl.on = true
                    cell.indicatorView.stopAnimating()
                    
                default:
                    cell.titleLabel.textColor = UIColor.whiteColor()
                    cell.switchCtrl.on = false
                    cell.indicatorView.stopAnimating()
                    
                }
            } else {
                cell.titleLabel.textColor = UIColor.whiteColor()
                cell.switchCtrl.on = false
                cell.indicatorView.stopAnimating()
            }
            
            return cell;
        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(AddCellReuseIdentifier, forIndexPath: indexPath) as! AddCollectionViewCell
            return cell;
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        
        if (indexPath.row == self.vpns.count) {
            self.extensionContext?.openURL(NSURL(string: "ztevpn://")!, completionHandler: nil)
        } else {
            let vpn = self.vpns[indexPath.row];
            
            if let selectID = VPNUserDefaultManager.sharedInstance.selectVPNID() where vpn.VPNID == selectID
            {
                switch VPNManager.sharedInstance.status {
                case .Connecting,
                     .Connected,
                     .Reasserting:
                    
                    VPNManager.sharedInstance.disConnect()
                        
                case .Invalid,
                     .Disconnected:
                    
                    VPNManager.sharedInstance.connectVPN(vpn, titlePrefix: "Widget", completionHandler: nil)
                default:
                    break
                
                }
            }
            else
            {
                //如已经连上其它VPN，先断开连接
                if (VPNManager.sharedInstance.status == .Connecting ||
                    VPNManager.sharedInstance.status == .Connected  ||
                    VPNManager.sharedInstance.status == .Reasserting)
                {
                    VPNManager.sharedInstance.disConnect()
                }
                
                VPNManager.sharedInstance.connectVPN(vpn, titlePrefix: "Widget", completionHandler: nil)
                
                VPNUserDefaultManager.sharedInstance.setSelectVPNID(vpn.VPNID)
            }
        }
    }
    
    // MARK: - NSNotification
    func vpnStatusDidChange(notification: NSNotification) {
        self.collectionView.reloadData()
    }
}
