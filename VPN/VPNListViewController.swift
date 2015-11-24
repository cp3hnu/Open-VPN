//
//  VPNListViewController.swift
//  VPN
//
//  Created by CP3 on 15/11/3.
//  Copyright © 2015年 CP3. All rights reserved.
//

import UIKit
import NetworkExtension
import CoreData

let kConnectIdentifier = "connectIdentifier"
let kVpnsIdentifier = "vpnsIdentifier"

class VPNListViewController: UITableViewController {

    var vpns = [VPN]()
    
    var isConnected: Bool {
        switch VPNManager.sharedInstance.status {
        case .Connected, .Connecting, .Reasserting:
            return true
        default:
            return false
        }
    }
    
    var VPNStatus: String {
        switch VPNManager.sharedInstance.status {
        case .Connecting, .Reasserting:
            return "正在连接..."
        case .Connected:
            return "已连接"
        case .Disconnecting:
            return "正在断开连接..."
        default:
            return "未连接"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "VPN"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "添加", style: .Plain, target: self, action: "rightBarButtonAction")
        
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 53, 0, 0)
        self.tableView.registerClass(ConnetTableViewCell.self, forCellReuseIdentifier: kConnectIdentifier)
        self.tableView.registerClass(ListTableViewCell.self, forCellReuseIdentifier: kVpnsIdentifier)
        
        self.vpns.removeAll()
        self.vpns = VPNDataManager.sharedInstance.fetchAllVPNs()
        
        VPNManager.sharedInstance.loadFromPreferencesWithCompletionHandler()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "vpnStatusDidChange:", name: NEVPNStatusDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "vpnsDidSave:", name: NSManagedObjectContextDidSaveNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Custom Methods
    func addVPNItem(userInfo: [NSObject : AnyObject]? = nil) {

        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("VPNDetailVC") as! VPNDetailViewController
        controller.activityUserInfo = userInfo
        
        self.navigationController?.presentViewController(UINavigationController(rootViewController: controller), animated: true, completion: nil)
    }
    
    func rightBarButtonAction() {
        addVPNItem()
    }
    
    func toggleVPNConnection(sender: UISwitch) {
    
        if let vpnID = VPNUserDefaultManager.sharedInstance.selectVPNID() {
            if sender.on {
                for vpn in self.vpns {
                    if  vpn.VPNID == vpnID {
                            VPNManager.sharedInstance.connectVPN(vpn, titlePrefix: nil, completionHandler: { (error: NSError?) -> Void in
                                
                                if let connectError = error where connectError.domain == NEVPNErrorDomain && connectError.code == NEVPNError.ConfigurationReadWriteFailed.rawValue {
                                    
                                    self.tableView.reloadData()
                                    
                                    let controller = UIAlertController(title: "连接失败", message: "请点击\"Allow\"，成功添加VPN配置后，才能连接VPN", preferredStyle: .Alert)
                                    let action = UIAlertAction(title: "确定", style: .Cancel, handler: nil)
                                    controller.addAction(action)
                                    self.presentViewController(controller, animated: true, completion: nil)
                                }//error
                            })
                        break
                    } //vpnID
                } //for
            } else {
                VPNManager.sharedInstance.disConnect()
            }
        } else {
            let controller = UIAlertController(title: "未选择VPN", message: "请先选择一个VPN，再连接", preferredStyle: .Alert)
            let action = UIAlertAction(title: "确定", style: .Cancel, handler: nil)
            controller.addAction(action)
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    // MARK: - NSNotification
    func vpnStatusDidChange(notification: NSNotification) {
        self.tableView.reloadData()
    }
    
    func vpnsDidSave(notification: NSNotification) {
        self.vpns.removeAll()
        self.vpns = VPNDataManager.sharedInstance.fetchAllVPNs()
        self.tableView.reloadData()
    }

    // MARK: - UITableView Manager
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if section == 0 {
            return 1
        }
        
        return self.vpns.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if (indexPath.section == 0)
        {
            let cell = tableView.dequeueReusableCellWithIdentifier(kConnectIdentifier, forIndexPath: indexPath) as! ConnetTableViewCell
            
            cell.connectSwitch.addTarget(self, action: "toggleVPNConnection:", forControlEvents: .ValueChanged)
            cell.connectSwitch.enabled = (self.vpns.count != 0)
            cell.connectSwitch.on = self.isConnected
            
            cell.statusLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
            cell.statusLabel.text = self.VPNStatus
            
            cell.setNeedsUpdateConstraints()
            cell.updateConstraintsIfNeeded()
            
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCellWithIdentifier(kVpnsIdentifier, forIndexPath: indexPath) as! ListTableViewCell
            cell.accessoryType = .DetailButton
            
            let vpn = self.vpns[indexPath.row]
            
            cell.titleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
            cell.titleLabel.text = vpn.title
            
            cell.serverLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2)
            cell.serverLabel.text = vpn.server
            
            if let vpnID = VPNUserDefaultManager.sharedInstance.selectVPNID() where vpnID == vpn.VPNID {
                cell.checkImageView.hidden = false
            } else {
                cell.checkImageView.hidden = true
            }
            
            cell.setNeedsUpdateConstraints()
            cell.updateConstraintsIfNeeded()
            
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        guard indexPath.section != 0 else { return }
        
        let vpn = self.vpns[indexPath.row]
        let vpnID: String? = VPNUserDefaultManager.sharedInstance.selectVPNID()
        if vpnID == nil || vpn.VPNID != vpnID {
            VPNUserDefaultManager.sharedInstance.setSelectVPNID(vpn.VPNID)
            
            if VPNManager.sharedInstance.status == .Connected || VPNManager.sharedInstance.status == .Connecting || VPNManager.sharedInstance.status == .Reasserting {
                VPNManager.sharedInstance.disConnect()
            }
            
            self.tableView.reloadData()
        }
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        
        let vpn = self.vpns[indexPath.row]
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("VPNDetailVC") as! VPNDetailViewController
        controller.vpn = vpn
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    //MARK: - TalbleView Editting
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        if indexPath.section == 0 {
            return false
        }
        
        return true
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }
    
    override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return "删除"
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let vpn = self.vpns[indexPath.row]
        let vpnID = VPNUserDefaultManager.sharedInstance.selectVPNID()
       
        if vpn.VPNID == vpnID {
            if VPNManager.sharedInstance.status == .Connected || VPNManager.sharedInstance.status == .Connecting || VPNManager.sharedInstance.status == .Reasserting {
                VPNManager.sharedInstance.disConnect()
            }
        }
        
        if self.vpns.count == 1 {
            VPNUserDefaultManager.sharedInstance.clearSelectVPNID()
        } else {
            if vpn.VPNID == vpnID {
                var anotherVPN: VPN
                if indexPath.row == 0 {
                    anotherVPN = self.vpns[indexPath.row + 1]
                } else {
                    anotherVPN = self.vpns[0]
                }
                
                VPNUserDefaultManager.sharedInstance.setSelectVPNID(anotherVPN.VPNID)
            }
        }
        
        self.tableView.beginUpdates()
        self.vpns.removeAtIndex(indexPath.row)
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        self.tableView.endUpdates()
        self.tableView.reloadData()
        
        VPNDataManager.sharedInstance.deleteVPN(vpn)
    }
    
    // MARK: - Handoff
    override func restoreUserActivityState(activity: NSUserActivity) {
        
        let naviCtrler = self.navigationController!
        
        if naviCtrler.presentedViewController != nil {
            naviCtrler.dismissViewControllerAnimated(false, completion: {
                self.addVPNItem(activity.userInfo)
            })
        } else {
             addVPNItem(activity.userInfo)
        }
    }
}
