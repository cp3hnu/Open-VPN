//
//  VPNDetailViewController.swift
//  VPN
//
//  Created by CP3 on 15/11/3.
//  Copyright © 2015年 CP3. All rights reserved.
//

import UIKit
import VPNKit

class VPNDetailViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate {

    let ruleViewHeight: CGFloat = 160.0
    var vpn: VPN?
    var activityUserInfo : [NSObject : AnyObject]?
    var descriptions = ["描述", "服务器", "账户", "密码", "群组名称", "密钥"]
    var cells = [UITableViewCell]()
    var ruleLabel: UILabel!
    var ruleTextView: UITextView!
    var ruleView: UIView!
    
    var vpnTitle: String {
        let textField = textFieldInCellAtIndex(0)
        return textField.text ?? ""
    }
    
    var server: String {
        let textField = textFieldInCellAtIndex(1)
        return textField.text ?? ""
    }
    
    var account: String {
        let textField = textFieldInCellAtIndex(2)
        return textField.text ?? ""
    }
    
    var password: String {
        let textField = textFieldInCellAtIndex(3)
        return textField.text ?? ""
    }
    
    var groupName: String {
        let textField = textFieldInCellAtIndex(4)
        return textField.text ?? ""
    }
    
    var secret: String {
        let textField = textFieldInCellAtIndex(5)
        return textField.text ?? ""
    }
    
    var rule: String {
        return self.ruleTextView.text ?? ""
    }

    var isOnDemand: Bool {
        let switchCtrl = switchInCellAtIndex(7)
        return switchCtrl.on
    }

    var disconnectOnSleep: Bool {
        let switchCtrl = switchInCellAtIndex(6)
        return !switchCtrl.on
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        for i in 0 ..< 6 {
            let cell = createTextFieldCellForIndex(i)
            self.cells.append(cell)
        }
        
        for i in 6 ..< 8 {
            let cell = createSwithchCellForIndex(i)
            self.cells.append(cell)
        }
        
        createRuleView()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "存储", style: .Done, target: self, action: "saveNewVPN")
        self.navigationItem.rightBarButtonItem?.enabled = false
        
        if let vpnInstance = vpn {
            self.title = vpnInstance.title
        } else {
            self.title = "添加配置"
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .Plain, target: self, action: "cancel")
        }
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        
        startUserActivity()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldTextDidChanged:", name: UITextFieldTextDidChangeNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "preferredContentSizeChanged:", name: UIContentSizeCategoryDidChangeNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.view.endEditing(true)
        
        stopUserActivity()
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Custom Methods
    func createTextFieldCellForIndex(index: NSInteger) -> UITableViewCell {
        let cell = DetailTableViewCell(style: .Default, reuseIdentifier: nil)
        let label = cell.descLabel
        let textField = cell.textField
        textField.delegate = self
        label.text = descriptions[index]
        
        if index >= 0 && index <= 2 || index == 5 {
            textField.placeholder = "必填"
        } else if index == 3 {
            textField.placeholder = "每次均询问"
        }
        
        if index == 3 || index == 5 {
            textField.secureTextEntry = true
        }
        
        if index == 5 {
            textField.returnKeyType = .Done
        }
        
        if let vpnDetail = self.vpn {
            switch (index) {
            case 0:
                textField.text = vpnDetail.title
            case 1:
                textField.text = vpnDetail.server
            case 2:
                textField.text = vpnDetail.account
            case 3:
                textField.text = vpnDetail.password
            case 4:
                textField.text = vpnDetail.groupName
            default:
                textField.text = vpnDetail.secretKey
            }
        } else if let dict = self.activityUserInfo {
            switch (index) {
            case 0:
                textField.text = dict[ActivityTitleKey] as? String
            case 1:
                textField.text = dict[ActivityServerKey] as? String
            case 2:
                textField.text = dict[ActivityAccountKey] as? String
            case 3:
                textField.text = dict[ActivityPasswordKey] as? String
            case 4:
                textField.text = dict[ActivityGroupNameKey] as? String
            default:
                textField.text = dict[ActivitySecretKey] as? String
            }
        }
        
        return cell
    }
    
    func createSwithchCellForIndex(index: NSInteger) -> ConnetTableViewCell {
        
        let cell = ConnetTableViewCell(style: .Default, reuseIdentifier: nil)
        
        let label = cell.statusLabel
        let switchControl = cell.connectSwitch
        
        if index == 6 {
            label.text = "锁屏时保持连接"
            if let vpnItem = self.vpn {
                switchControl.on = !vpnItem.disconnectOnSleep
            } else if let dict = self.activityUserInfo {
                switchControl.on = !(dict[ActivityDisconnectOnSleepKey] as! Bool)
            }
            
            switchControl.addTarget(self, action: "toggleDisconnectOnSleep", forControlEvents: .ValueChanged)
        } else {
            label.text = "按需连接"
            switchControl.on = false
            if let vpnItem = self.vpn {
                switchControl.on = vpnItem.isOnDemand
            } else if let dict = self.activityUserInfo {
                switchControl.on = dict[ActivityOnDemandKey] as! Bool
            }
            
            switchControl.addTarget(self, action: "toggleOnDemand:", forControlEvents: .ValueChanged)
        }
        
        return cell
    }
    
    func textFieldInCellAtIndex(index: Int) -> UITextField {
        let cell = self.cells[index] as! DetailTableViewCell
        return cell.textField
    }
    
    func switchInCellAtIndex(index: Int) -> UISwitch {
        let cell = self.cells[index] as! ConnetTableViewCell
        return cell.connectSwitch
    }
    
    func createRuleView() {
        
        let space = self.tableView.separatorInset.left
        
        let view = UIView(frame: CGRectMake(0, 0, 0, ruleViewHeight))
        view.backgroundColor = UIColor.clearColor()
        ruleView = view
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.blackColor()
        label.textAlignment = .Left
        label.text = "填写VPN的域名(以逗号或者换行符分割)"
        label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        label.numberOfLines = 0
        label.backgroundColor = UIColor.clearColor()
        ruleView.addSubview(label)
        ruleLabel = label
        
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textContainerInset = UIEdgeInsetsMake(10, space, 10, space)
        textView.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        textView.autocapitalizationType = .None
        textView.autocorrectionType = .No
        textView.spellCheckingType = .No
        textView.delegate = self
        textView.backgroundColor = UIColor.whiteColor()
        ruleView.addSubview(textView)
        ruleTextView = textView
        if let vpnItem = self.vpn {
            ruleTextView.text = vpnItem.rule
        }  else if let dict = self.activityUserInfo {
            ruleTextView.text = dict[ActivityRuleKey] as? String
        }
        
        ruleView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-space-[label]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["space": space], views: ["label": ruleLabel]))
        ruleView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[textView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["textView": ruleTextView]))
        
        let constraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[label]-10-[textView]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["label": ruleLabel, "textView": ruleTextView])
        for constraint in constraints {
            constraint.priority = UILayoutPriorityDefaultLow
        }
        ruleView.addConstraints(constraints)
    }
    
    func makePropertyChange() {
        if self.vpn != nil && self.navigationItem.rightBarButtonItem!.enabled == false {
            enableRightBarButtonItem()
        }
    }
    
    func enableRightBarButtonItem() {
        
        let titleField = textFieldInCellAtIndex(0)
        let serverField = textFieldInCellAtIndex(1)
        let accountField = textFieldInCellAtIndex(2)
        
        if let title = titleField.text, let server = serverField.text, let account = accountField.text where !title.isEmpty && !server.isEmpty && !account.isEmpty {
            self.navigationItem.rightBarButtonItem!.enabled = true
            
        } else {
            self.navigationItem.rightBarButtonItem!.enabled = false
        }
    }
    
    // MARK: - Button Action
    func cancel() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveNewVPN() {
        
        //修改连接的VPN时，先断开连接
        if VPNManager.sharedInstance.status == .Connected || VPNManager.sharedInstance.status == .Connecting || VPNManager.sharedInstance.status == .Reasserting {
            
            if let vpnInstance = self.vpn, let selectID = VPNUserDefaultManager.sharedInstance.selectVPNID() where vpnInstance.VPNID == selectID {
                
                VPNManager.sharedInstance.disConnect()
            }
        }
        
        var isNewItem = false
        if self.vpn == nil {
            isNewItem = true
            self.vpn = VPNDataManager.sharedInstance.insertVPN()
        }
        
        let trimmedRule = self.rule.stringByTrimmingCharactersInSet(VPN.separatorCharacterSet())
        
        self.vpn!.title = self.vpnTitle
        self.vpn!.server = self.server
        self.vpn!.account = self.account
        self.vpn!.password = self.password
        self.vpn!.secretKey = self.secret
        self.vpn!.groupName = self.groupName
        self.vpn!.disconnectOnSleep = self.disconnectOnSleep
        self.vpn!.isOnDemand = self.isOnDemand
        self.vpn!.rule = trimmedRule
        
        VPNDataManager.sharedInstance.saveContext()
        
        VPNKeyChainManager.sharedInstance.setPassword(password, forVPNID: self.vpn!.VPNID)
        VPNKeyChainManager.sharedInstance.setSecret(secret, forVPNID: self.vpn!.VPNID)
        
        let selectID = VPNUserDefaultManager.sharedInstance.selectVPNID()
        
        if selectID == nil {
            VPNUserDefaultManager.sharedInstance.setSelectVPNID(self.vpn!.VPNID)
        }
        
        if isNewItem {
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        } else {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func toggleDisconnectOnSleep() {
        self.userActivity?.needsSave = true
        makePropertyChange()
    }
    
    func toggleOnDemand(sender: UISwitch) {
        self.userActivity?.needsSave = true
        makePropertyChange()
        
        self.tableView.reloadData()
        
        dispatch_async(dispatch_get_main_queue()) {
            if (sender.on) {
                self.ruleTextView.becomeFirstResponder()
            } else {
                self.ruleTextView.resignFirstResponder()
            }
        }
    }
    
    // MARK: - Handoff
    func userInfoDict() -> [NSObject : AnyObject] {
        return [
            ActivityTitleKey: self.vpnTitle,
            ActivityServerKey: self.server,
            ActivityAccountKey: self.account,
            ActivityPasswordKey: self.password,
            ActivityGroupNameKey: self.groupName,
            ActivitySecretKey: self.secret,
            ActivityDisconnectOnSleepKey: self.disconnectOnSleep,
            ActivityOnDemandKey: self.isOnDemand,
            ActivityRuleKey: self.rule
        ]
    }
    
    func startUserActivity() {
        
        let activity = NSUserActivity(activityType: ActivityTypeAdd)
        activity.title = "Add VPN Item"
        activity.userInfo = userInfoDict()
        self.userActivity = activity
        self.userActivity?.becomeCurrent()
    }
    
    func stopUserActivity() {
        self.userActivity?.invalidate()
    }
    
    override func updateUserActivityState(activity: NSUserActivity) {
        activity.addUserInfoEntriesFromDictionary(userInfoDict())
        super.updateUserActivityState(activity)
    }
    
    // MARK: - UITableView Manager
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 6
        }
        
        return 1
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = self.cells[indexPath.row] as! DetailTableViewCell
            cell.selectionStyle = .None
            
            cell.descLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
            cell.textField.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
            
            return cell
        } else {
            let cell = self.cells[5 + indexPath.section] as! ConnetTableViewCell
            cell.selectionStyle = .None
            
            cell.statusLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section == 2 && self.isOnDemand {
            return ruleViewHeight
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 2 && self.isOnDemand {
            return self.ruleView
        }
        
        return nil
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        let titleField = textFieldInCellAtIndex(0)
        let serverField = textFieldInCellAtIndex(1)
        let accountField = textFieldInCellAtIndex(2)
        let passwordField = textFieldInCellAtIndex(3)
        let groupNameField = textFieldInCellAtIndex(4)
        let secretField = textFieldInCellAtIndex(5)
       
        switch textField {
        case titleField:
            serverField.becomeFirstResponder()
        case serverField:
            accountField.becomeFirstResponder()
        case accountField:
            passwordField.becomeFirstResponder()
        case passwordField:
            groupNameField.becomeFirstResponder()
        case groupNameField:
            secretField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    func textFieldTextDidChanged(notification: NSNotification) {
        self.userActivity?.needsSave = true
        enableRightBarButtonItem()
    }

    // MARK: - UITextViewDelegate
    func textViewDidBeginEditing(textView: UITextView) {
        
        dispatch_async(dispatch_get_main_queue()) {
            let rect = textView.convertRect(textView.bounds, toView: self.tableView)
            self.tableView.scrollRectToVisible(rect, animated: true)
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        self.userActivity?.needsSave = true
        makePropertyChange()
    }

    // MARK: - Notification
    func preferredContentSizeChanged(notification: NSNotification) {
        self.tableView.reloadData()
    }
}
