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
#import "TextFieldTableCell.h"
#import "SwitchTableCell.h"

@interface VPNDetailViewController () <UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, strong) NSArray    *labelTextArray;
@property (nonatomic, strong) NSArray    *cells;
@property (nonatomic, strong) UILabel    *ruleLabel;
@property (nonatomic, strong) UITextView *ruleTextView;
@property (nonatomic, strong) UIView     *ruleView;
@property (nonatomic, assign) BOOL       isOnDemand;


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
    
    //[self createTableFooterView];
    
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"EEEEEE"];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldTextDidChanged:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(preferredContentSizeChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
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
    
    UITextField *textField;
    textField = [self textFieldInCellAtIndex:0];
    title = textField.text;
    
    textField = [self textFieldInCellAtIndex:1];
    server = textField.text;
    
    textField = [self textFieldInCellAtIndex:2];
    account = textField.text;
    
    textField = [self textFieldInCellAtIndex:3];
    password = textField.text ?: @"";
    
    textField = [self textFieldInCellAtIndex:4];
    groupName = textField.text ?: @"";
    
    textField = [self textFieldInCellAtIndex:5];
    secret = textField.text ?: @"";
    
    UISwitch *switchCtrl;
    switchCtrl = [self switchInCellAtIndex:6];
    disconnectOnSleep = !switchCtrl.isOn;
    
    switchCtrl = [self switchInCellAtIndex:7];
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
    
    [[VPNKeyChainWrapper sharedInstance] setPassword:password forVPNID:self.vpn.VPNID];
    [[VPNKeyChainWrapper sharedInstance] setSecret:secret forVPNID:self.vpn.VPNID];
    
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
    [self.tableView reloadData];
    
    if (sender.on)
    {
        [self.ruleTextView becomeFirstResponder];
    }
    else
    {
        [self.ruleTextView resignFirstResponder];
    }
}

#pragma mark - TableView Managerment
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
        TextFieldTableCell *cell = self.cells[indexPath.row];
        cell.label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        cell.textField.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        return cell;
    }
    else
    {
        SwitchTableCell *cell = self.cells[5 + indexPath.section];
        cell.label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 2 && self.isOnDemand)
    {
        return self.ruleView.bounds.size.height;
    }
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 2 && self.isOnDemand)
    {
        return self.ruleView;
    }
    
    return nil;
}

#pragma mark - Property
- (BOOL)isOnDemand
{
    UISwitch *switchCtrl = [self switchInCellAtIndex:7];
    return switchCtrl.on;
}

- (UIView *)ruleView
{
    if (!_ruleView)
    {
        CGFloat space = self.tableView.separatorInset.left;
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 160)];
        view.backgroundColor = [UIColor clearColor];
        _ruleView = view;
        
        UILabel *label = [[UILabel alloc] init];
        label.text = @"填写VPN的域名(以逗号或者换行符分割)";
        label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        label.textColor = [UIColor blackColor];
        label.textAlignment = NSTextAlignmentLeft;
        label.backgroundColor = [UIColor clearColor];
        label.adjustsFontSizeToFitWidth = YES;
        [_ruleView addSubview:label];
        self.ruleLabel = label;
        
        UITextView *textView = [[UITextView alloc] init];
        textView.textContainerInset = UIEdgeInsetsMake(10, space, 10, space);
        textView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textView.autocorrectionType = UITextAutocorrectionTypeNo;
        textView.spellCheckingType = UITextSpellCheckingTypeNo;
        textView.delegate = self;
        textView.backgroundColor = [UIColor whiteColor];
        [_ruleView addSubview:textView];
        self.ruleTextView = textView;
        
        label.translatesAutoresizingMaskIntoConstraints = NO;
        textView.translatesAutoresizingMaskIntoConstraints = NO;

        [_ruleView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-space-[label]-|" options:0 metrics:@{@"space":@(space)} views:NSDictionaryOfVariableBindings(label)]];
        [_ruleView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[textView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(textView)]];
        [_ruleView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[label]-10-[textView]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(label,textView)]];
        
        if (self.vpn)
        {
            self.ruleTextView.text = self.vpn.rule;
        }
    }
    
    return _ruleView;
}

#pragma mark - Create Cell
- (NSArray *)cells
{
    if (!_cells)
    {
        NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:8];
        for (int i = 0; i < 6; i++)
        {
            UITableViewCell *cell = [self createTextFieldCellForIndex:i];
            [mArray addObject:cell];
        }
        
        for (int i = 6; i < 8; i ++)
        {
            UITableViewCell *cell = [self createSwitchCellForForIndex:i];
            [mArray addObject:cell];
        }
        
        _cells = mArray;
    }
    
    return _cells;
}

- (UITextField *)textFieldInCellAtIndex:(NSUInteger)index
{
    if (index < 6)
    {
        TextFieldTableCell *cell = self.cells[index];
        return cell.textField;
    }
    
    return nil;
    
}

- (UISwitch *)switchInCellAtIndex:(NSUInteger)index
{
    if (index == 6 || index == 7)
    {
        SwitchTableCell *cell = self.cells[index];
        return cell.switchCtrl;
    }
    
    return nil;
}

- (UITableViewCell *)createTextFieldCellForIndex:(NSInteger)index
{
    TextFieldTableCell *cell = [[TextFieldTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    UILabel *label = cell.label;
    UITextField *textField = cell.textField;
    textField.delegate = self;
    
    label.text = self.labelTextArray[index];
    
    if (index >= 0 && index <= 2)
    {
        textField.placeholder = @"必填";
    }
    else if (index == 3)
    {
        textField.placeholder = @"每次均询问";
    }
    
    if (index == 3 || index == 5)
    {
        textField.secureTextEntry = YES;
    }
    
    if (index == 5)
    {
        textField.returnKeyType = UIReturnKeyDone;
    }
    
    if (self.vpn)
    {
        switch (index) {
            case 0:
                textField.text = self.vpn.title;
                break;
                
            case 1:
                textField.text = self.vpn.server;
                break;
                
            case 2:
                textField.text = self.vpn.account;
                break;
                
            case 3:
                textField.text = self.vpn.password;
                break;
                
            case 4:
                textField.text = self.vpn.groupName;
                break;
                
            default:
                textField.text = self.vpn.secretKey;
                break;
        }
    }
    
    return cell;
}

- (UITableViewCell *)createSwitchCellForForIndex:(NSInteger)index
{
    SwitchTableCell *cell = [[SwitchTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    UILabel *label = cell.label;
    UISwitch *switchCtrl = cell.switchCtrl;
    
    if (index == 6)
    {
        label.text = @"锁屏时保持连接";
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
    UITextField *titleField = [self textFieldInCellAtIndex:0];
    UITextField *serverField = [self textFieldInCellAtIndex:1];
    UITextField *accountField = [self textFieldInCellAtIndex:2];
    UITextField *passwordField = [self textFieldInCellAtIndex:3];
    UITextField *groupNameField = [self textFieldInCellAtIndex:4];
    UITextField *secretField = [self textFieldInCellAtIndex:5];
    
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

- (void)textFieldTextDidChanged:(NSNotification *)notification
{
    UITextField *titleField = [self textFieldInCellAtIndex:0];
    UITextField *serverField = [self textFieldInCellAtIndex:1];
    UITextField *accountField = [self textFieldInCellAtIndex:2];

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
    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect rect = [textView convertRect:textView.bounds toView:self.tableView];
        [self.tableView scrollRectToVisible:rect animated:YES];
    });
}

#pragma mark - Notification
- (void)preferredContentSizeChanged:(NSNotification *)notification
{
    self.ruleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    self.ruleTextView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
}

@end
