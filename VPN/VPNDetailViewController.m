//
//  VPNDetailViewController.m
//  VPN
//
//  Created by ZhaoWei on 15/6/5.
//  Copyright (c) 2015年 csdept. All rights reserved.
//

#import "VPNDetailViewController.h"
#import "VPNDataManager.h"
#import "Define.h"
#import "VPN.h"
#import "VPNDataManager.h"
#import "VPNKit.h"
#import "VPN+OnDemandRules.h"

#define kLabelTag     100
#define kTextFieldTag 101
#define kSwitchTag    102

@interface VPNDetailViewController () <UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, strong) NSArray *labelTextArray;

@property (nonatomic, strong) UITableViewCell *titleCell;
@property (nonatomic, strong) UITableViewCell *serverCell;
@property (nonatomic, strong) UITableViewCell *accoutCell;
@property (nonatomic, strong) UITableViewCell *passwordCell;
@property (nonatomic, strong) UITableViewCell *groupNameCell;
@property (nonatomic, strong) UITableViewCell *secretCell;
@property (nonatomic, strong) UITableViewCell *disconnectCell;
@property (nonatomic, strong) UITableViewCell *onDemandCell;
@property (nonatomic, strong) UITextView      *ruleTextView;
@property (nonatomic, strong) UIView          *tableFooterView;

@end

@implementation VPNDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _labelTextArray = @[@"描述", @"服务器", @"账户", @"密码", @"群组名称", @"密钥"];
    
    self.title = @"添加配置";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"存储" style:UIBarButtonItemStyleDone target:self action:@selector(saveNewVPN)];
    if (!self.vpn)
    {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
    [self createTableFooterView];
    
    if (!self.vpn || ![self.vpn.isOnDemand boolValue])
    {
        self.tableView.tableFooterView = [UIView new];
    }
    else
    {
        self.tableView.tableFooterView = self.tableFooterView;
    }
    
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"EEEEEE"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldTextDidChanged:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
}

- (void)createTableFooterView
{
    CGFloat width = self.view.bounds.size.width;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 130)];
    view.backgroundColor = [UIColor clearColor];
    self.tableFooterView = view;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, width - 15, 20)];
    label.text = @"填写VPN的域名(以逗号或者换行符分割)";
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.backgroundColor = [UIColor clearColor];
    [self.tableFooterView addSubview:label];
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 25, width, 90)];
    textView.textContainerInset = UIEdgeInsetsMake(10, 15, 15, 10);
    textView.font = [UIFont systemFontOfSize:16];
    textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textView.autocorrectionType = UITextAutocorrectionTypeNo;
    textView.spellCheckingType = UITextSpellCheckingTypeNo;
    textView.delegate = self;
    textView.backgroundColor = [UIColor whiteColor];
    [self.tableFooterView addSubview:textView];
    self.ruleTextView = textView;
    
    if (self.vpn)
    {
        self.ruleTextView.text = self.vpn.rule;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Button Action
- (void)cancel
{
    if (self.vpn)
    {
         [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
         [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)saveNewVPN
{
    NSString *title;
    NSString *server;
    NSString *account;
    NSString *password;
    NSString *groupName;
    NSString *secret;
    BOOL disconnectOnSleep;
    BOOL isOnDemand;
    NSString *rule;
    
    UITextField *textField = (UITextField *)[self.titleCell viewWithTag:kTextFieldTag];
    title = textField.text;
    
    textField = (UITextField *)[self.serverCell viewWithTag:kTextFieldTag];
    server = textField.text;
    
    textField = (UITextField *)[self.accoutCell viewWithTag:kTextFieldTag];
    account = textField.text;
    
    textField = (UITextField *)[self.passwordCell viewWithTag:kTextFieldTag];
    password = textField.text ?: @"";
    
    textField = (UITextField *)[self.groupNameCell viewWithTag:kTextFieldTag];
    groupName = textField.text ?: @"";
    
    textField = (UITextField *)[self.secretCell viewWithTag:kTextFieldTag];
    secret = textField.text ?: @"";
    
    UISwitch *switchCtrl = (UISwitch *)[self.disconnectCell viewWithTag:kSwitchTag];
    disconnectOnSleep = !switchCtrl.isOn;
    
    switchCtrl = (UISwitch *)[self.onDemandCell viewWithTag:kSwitchTag];
    isOnDemand = switchCtrl.isOn;
    
    rule = self.ruleTextView.text ?: @"";
    rule = [rule stringByTrimmingCharactersInSet:[VPN separatorCharacterSet]];
    
    BOOL isNewItem = NO;
    if (!self.vpn)
    {
        isNewItem = YES;
        self.vpn = [[VPNDataManager sharedInstance] insertVPN];
    }
    
    self.vpn.title = title;
    self.vpn.server = server;
    self.vpn.account = account;
    self.vpn.password = password;
    self.vpn.secretKey = secret;
    self.vpn.groupName = groupName;
    self.vpn.disconnectOnSleep = @(disconnectOnSleep);
    self.vpn.isOnDemand = @(isOnDemand);
    self.vpn.rule = rule;
    
    [[VPNDataManager sharedInstance] saveContext];
    
    if (!self.vpn.objectID.temporaryID)
    {
        [[VPNKeyChainWrapper sharedInstance] setPassword:password forVPNID:self.vpn.VPNID];
        [[VPNKeyChainWrapper sharedInstance] setSecret:secret forVPNID:self.vpn.VPNID];
    }
    
    if (![[VPNManager sharedInstance] stringForKey:kSelectedVPNID])
    {
        [[VPNManager sharedInstance] setObject:self.vpn.VPNID forKey:kSelectedVPNID];
    }
    
    if (isNewItem)
    {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)toggleOnDemand:(UISwitch *)sender
{
    if (sender.on)
    {
        self.tableView.tableFooterView = self.tableFooterView;
        [self.ruleTextView becomeFirstResponder];
    }
    else
    {
        self.tableView.tableFooterView = [UIView new];
    }
}

#pragma mark - TableView Managerment
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 6;
    }
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath.section)
    {
        switch (indexPath.row) {
            case 0:
                return self.titleCell;
                
            case 1:
                return self.serverCell;
                
            case 2:
                return self.accoutCell;
                
            case 3:
                return self.passwordCell;
                
            case 4:
                return self.groupNameCell;
                
            default:
                return self.secretCell;
        }
    }
    else if (indexPath.section == 1)
    {
        return self.disconnectCell;
    }
    else
    {
        return self.onDemandCell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 1)
    {
        return 35;
    }
    else if (section == 2)
    {
        return 15;
    }
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 1)
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 35)];
        view.backgroundColor = [UIColor colorWithHexString:@"EEEEEE"];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 3, view.bounds.size.width - 30, 20)];
        label.text = @"在锁屏的时候保持VPN连接";
        label.font = [UIFont systemFontOfSize:16];
        label.textColor = [UIColor blackColor];
        label.textAlignment = NSTextAlignmentLeft;
        label.backgroundColor = [UIColor clearColor];
        [view addSubview:label];
        
        return view;
    }
    
    return nil;
}

#pragma mark - Create Cell
- (UITableViewCell *)titleCell
{
    if (!_titleCell)
    {
        _titleCell = [self createInfoCellForRow:0];
    }
    
    return _titleCell;
}

- (UITableViewCell *)serverCell
{
    if (!_serverCell)
    {
        _serverCell = [self createInfoCellForRow:1];
    }
    
    return _serverCell;
}

- (UITableViewCell *)accoutCell
{
    if (!_accoutCell)
    {
        _accoutCell = [self createInfoCellForRow:2];
    }
    
    return _accoutCell;
}

- (UITableViewCell *)passwordCell
{
    if (!_passwordCell)
    {
        _passwordCell = [self createInfoCellForRow:3];
    }
    
    return _passwordCell;
}

- (UITableViewCell *)groupNameCell
{
    if (!_groupNameCell)
    {
        _groupNameCell = [self createInfoCellForRow:4];
    }
    
    return _groupNameCell;
}

- (UITableViewCell *)secretCell
{
    if (!_secretCell)
    {
        _secretCell = [self createInfoCellForRow:5];
    }
    
    return _secretCell;
}


- (UITableViewCell *)disconnectCell
{
    if (!_disconnectCell)
    {
        _disconnectCell = [self createSwitchCellForSection:1];
    }
    
    return _disconnectCell;
}

- (UITableViewCell *)onDemandCell
{
    if (!_onDemandCell)
    {
        _onDemandCell = [self createSwitchCellForSection:2];
    }
    
    return _onDemandCell;
}

- (UITableViewCell *)createInfoCellForRow:(NSInteger)row
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UILabel *label = [[UILabel alloc] init];
    label.tag = kLabelTag;
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:label];
    label.text = self.labelTextArray[row];
    
    UITextField *textfield = [[UITextField alloc] init];
    textfield.tag = kTextFieldTag;
    textfield.delegate = self;
    textfield.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textfield.font = [UIFont systemFontOfSize:16];
    textfield.textColor = [UIColor blackColor];
    textfield.autocorrectionType = UITextAutocorrectionTypeNo;
    textfield.spellCheckingType = UITextSpellCheckingTypeNo;
    textfield.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textfield.returnKeyType = UIReturnKeyNext;
    [cell.contentView addSubview:textfield];
    
    label.translatesAutoresizingMaskIntoConstraints = NO;
    textfield.translatesAutoresizingMaskIntoConstraints = NO;
    [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[label(==80)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(label)]];
    [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[label]-[textfield(>=0)]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(label, textfield)]];
    [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[label]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(label)]];
    [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[textfield]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(textfield)]];
    
    if (row >= 0 && row <= 2)
    {
        textfield.placeholder = @"必填";
    }
    else if (row == 3)
    {
        textfield.placeholder = @"每次均询问";
    }
    
    if (row == 3 || row == 5)
    {
        textfield.secureTextEntry = YES;
    }
    
    if (row == 1)
    {
        textfield.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    }
    
    if (row == 5)
    {
        textfield.returnKeyType = UIReturnKeyDone;
    }
    
    if (self.vpn)
    {
        switch (row) {
            case 0:
                textfield.text = self.vpn.title;
                break;
                
            case 1:
                textfield.text = self.vpn.server;
                break;
                
            case 2:
                textfield.text = self.vpn.account;
                break;
                
            case 3:
                textfield.text = self.vpn.password;
                break;
                
            case 4:
                textfield.text = self.vpn.groupName;
                break;
                
            default:
                textfield.text = self.vpn.secretKey;
                break;
        }
    }
    else
    {
        switch (row) {
            case 1:
                textfield.text = @"101.78.195.61";
                break;
                
            case 2:
                textfield.text = @"cp3hnu";
                break;
                
            case 3:
                textfield.text = @"22ec7965a";
                break;
                
            case 4:
                textfield.text = @"vpn";
                break;
                
            case 5:
                textfield.text = @"vpn.psk";
                break;
                
            default:
                
                break;
        }
    }
    
    return cell;
}

- (UITableViewCell *)createSwitchCellForSection:(NSInteger)section
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UILabel *label = [[UILabel alloc] init];
    label.tag = kLabelTag;
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:label];
    
    UISwitch *switchCtrl = [[UISwitch alloc] init];
    switchCtrl.tag = kSwitchTag;
    [cell.contentView addSubview:switchCtrl];
    
    label.translatesAutoresizingMaskIntoConstraints = NO;
    switchCtrl.translatesAutoresizingMaskIntoConstraints = NO;
    [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[label]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(label)]];
    [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[label]-(>=0)-[switchCtrl]-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:NSDictionaryOfVariableBindings(label, switchCtrl)]];
    
    if (section == 1)
    {
        label.text = @"保持连接";
        if (self.vpn)
        {
            switchCtrl.on = ![self.vpn.disconnectOnSleep boolValue];
        }
    }
    else
    {
        label.text = @"按需连接";
        switchCtrl.on = NO;
        if (self.vpn)
        {
            switchCtrl.on = [self.vpn.isOnDemand boolValue];
        }
        
        [switchCtrl addTarget:self action:@selector(toggleOnDemand:) forControlEvents:UIControlEventValueChanged];
    }
    
    return cell;
}

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    UITextField *titleField = (UITextField *)[self.titleCell viewWithTag:kTextFieldTag];
    UITextField *serverField = (UITextField *)[self.serverCell viewWithTag:kTextFieldTag];
    UITextField *accountField = (UITextField *)[self.accoutCell viewWithTag:kTextFieldTag];
    UITextField *passwordField = (UITextField *)[self.passwordCell viewWithTag:kTextFieldTag];
    UITextField *groupNameField = (UITextField *)[self.groupNameCell viewWithTag:kTextFieldTag];
    UITextField *secretField = (UITextField *)[self.secretCell viewWithTag:kTextFieldTag];
    
    if (textField == titleField)
    {
        [serverField becomeFirstResponder];
    }
    else if (textField == serverField)
    {
        [accountField becomeFirstResponder];
    }
    else if (textField == accountField)
    {
        [passwordField becomeFirstResponder];
    }
    else if (textField == passwordField)
    {
        [groupNameField becomeFirstResponder];
    }
    else if (textField == groupNameField)
    {
        [secretField becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
    }
    
    return YES;
}

- (void)textFieldTextDidChanged:(UITextField *)textField
{
    UITextField *titleField = (UITextField *)[self.titleCell viewWithTag:kTextFieldTag];
    UITextField *serverField = (UITextField *)[self.serverCell viewWithTag:kTextFieldTag];
    UITextField *accountField = (UITextField *)[self.accoutCell viewWithTag:kTextFieldTag];

    if (titleField.text && serverField.text && accountField.text && ![titleField.text isEqualToString:@""] && ![serverField.text isEqualToString:@""] && ![accountField.text isEqualToString:@""])
    {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else
    {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

#pragma mark - UITextView Delegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    CGRect rect = [textView convertRect:textView.bounds toView:self.tableView];
    [self.tableView scrollRectToVisible:rect animated:YES];
}

@end
