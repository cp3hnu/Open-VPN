//
//  VPNListViewController.m
//  VPN
//
//  Created by ZhaoWei on 15/6/5.
//  Copyright (c) 2015年 csdept. All rights reserved.
//

@import NetworkExtension;

#import "VPNListViewController.h"
#import "VPNDetailViewController.h"
#import "Define.h"
#import "VPN.h"
#import "VPNDataManager.h"
#import "VPNKit.h"
#import "SwitchTableCell.h"
#import "SubtitleTableCell.h"

static NSString * const kSwitchTableCellReuseIdentifier = @"switchTableCell";
static NSString * const kSubtitleTableCellReuseIdentifier = @"subtitleTableCell";

#define kLabelTag   100
#define kSwitchTag  101

@interface VPNListViewController ()

@property (nonatomic, strong) NSMutableArray *vpns;
@property (nonatomic, strong) NSString       *VPNStatus;
@property (nonatomic, assign) BOOL           isConnected;

@end

@implementation VPNListViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _vpns = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.isConnected = NO;
    self.VPNStatus = @"未连接";
    
    self.title = @"VPN";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(addVPNItem)];
    
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerClass:[SwitchTableCell class] forCellReuseIdentifier:kSwitchTableCellReuseIdentifier];
    [self.tableView registerClass:[SubtitleTableCell class] forCellReuseIdentifier:kSubtitleTableCellReuseIdentifier];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 53, 0, 0);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(vpnStatusDidChange:)
                                                 name:NEVPNStatusDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(vpnConnectedError:)
                                                 name:kConnectVPNErrorNofitication
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(toggleVPNConnection:)
                                                 name:kSwitchValueChangedNotification
                                               object:nil];
    
    [self.vpns removeAllObjects];
    [self.vpns addObjectsFromArray:[[VPNDataManager sharedInstance] fetchAllVPNs]];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSwitchValueChangedNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Button Action
- (void)addVPNItem
{
    VPNDetailViewController *detailCtrler = [[VPNDetailViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController presentViewController:[[UINavigationController alloc] initWithRootViewController:detailCtrler] animated:YES completion:nil];
}

- (void)toggleVPNConnection:(NSNotification *)notification
{
    UISwitch *sender = notification.object;
    NSString *vpnID = [[VPNManager sharedInstance] stringForKey:kSelectedVPNID];
    if (vpnID)
    {
        for (VPN *vpn in self.vpns)
        {
            if ([vpn.VPNID isEqualToString:vpnID])
            {
                if (sender.on)
                {
                    [[VPNManager sharedInstance] connectVPN:vpn titlePrefix:nil];
                }
                else
                {
                    [[VPNManager sharedInstance] disConnect];
                }
                
                break;
            }
        }
    }
    else
    {
        UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:@"未选择VPN" message:@"请先选择一个VPN，再连接" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alterView show];
    }
}

- (void)vpnStatusDidChange:(NSNotification *)notification
{
    switch ([VPNManager sharedInstance].status) {

        case NEVPNStatusDisconnected: {
            self.VPNStatus = @"未连接";
            self.isConnected = NO;
            break;
        }
        case NEVPNStatusConnecting:
        case NEVPNStatusReasserting:{
            self.VPNStatus = @"正在连接...";
            self.isConnected = YES;
            break;
        }
        case NEVPNStatusConnected: {
            self.VPNStatus = @"已连接";
            self.isConnected = YES;
            break;
        }
        case NEVPNStatusDisconnecting: {
            self.VPNStatus = @"正在断开连接...";
            self.isConnected = NO;
            break;
        }
        default: {
            self.VPNStatus = @"未连接";
            self.isConnected = NO;
            break;
        }
    }
    
    [self.tableView reloadData];
}

- (void)vpnConnectedError:(NSNotification *)notification
{
    self.VPNStatus = @"未连接";
    self.isConnected = NO;
    
    [self.tableView reloadData];
    
    //iOS 9第一次saveToPreferences安装VPN到设备之后回到App，需要再调用loadFromPreferences，加载VPN设置
    [[VPNManager sharedInstance] loadFromPreferencesWithCompletionHandler:nil];
}

#pragma mark - TableView Managerment
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!section)
    {
        return 1;
    }
    
    return self.vpns.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath.section)
    {
        SwitchTableCell *cell = (SwitchTableCell *)[tableView dequeueReusableCellWithIdentifier:kSwitchTableCellReuseIdentifier];
        
        cell.label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        cell.label.text = self.VPNStatus;
        
        cell.switchCtrl.enabled = (self.vpns.count != 0);
        cell.switchCtrl.on = self.isConnected;
        
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
        
        return cell;
    }
    else
    {
        SubtitleTableCell *cell = (SubtitleTableCell *)[tableView dequeueReusableCellWithIdentifier:kSubtitleTableCellReuseIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
        
        VPN *vpn = self.vpns[indexPath.row];
        
        cell.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        cell.titleLabel.text = vpn.title;
        cell.serverLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
        cell.serverLabel.text = vpn.server;
        
        NSString *vpnID = [[VPNManager sharedInstance] stringForKey:kSelectedVPNID];
        if ([vpnID isEqualToString:vpn.VPNID])
        {
            cell.checkImageView.hidden = NO;
        }
        else
        {
            cell.checkImageView.hidden = YES;
        }
        
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!indexPath.section)
    {
        return;
    }
    
    NSString *vpnID = [[VPNManager sharedInstance] stringForKey:kSelectedVPNID];
    VPN *vpn = self.vpns[indexPath.row];
    
    if (![vpn.VPNID isEqualToString:vpnID])
    {
        [[VPNManager sharedInstance] setObject:vpn.VPNID forKey:kSelectedVPNID];
        
        if ([VPNManager sharedInstance].status == NEVPNStatusConnecting ||
            [VPNManager sharedInstance].status == NEVPNStatusConnected  ||
             [VPNManager sharedInstance].status == NEVPNStatusReasserting)
        {
            [[VPNManager sharedInstance] disConnect];
        }
        
        [tableView reloadData];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    VPN *vpn = self.vpns[indexPath.row];
    VPNDetailViewController *detailCtrler = [[VPNDetailViewController alloc] initWithStyle:UITableViewStyleGrouped];
    detailCtrler.vpn = vpn;
    [self.navigationController pushViewController:detailCtrler animated:YES];
}

#pragma mark - TalbleView Editting
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
        return YES;
    
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *vpnID = [[VPNManager sharedInstance] stringForKey:kSelectedVPNID];
    
    VPN *vpn = self.vpns[indexPath.row];
    [[VPNDataManager sharedInstance] deleteVPN:vpn];
    
    if ([vpn.VPNID isEqualToString:vpnID])
    {
        if ([VPNManager sharedInstance].status == NEVPNStatusConnecting ||
            [VPNManager sharedInstance].status == NEVPNStatusConnected  ||
            [VPNManager sharedInstance].status == NEVPNStatusReasserting)
        {
            [[VPNManager sharedInstance] disConnect];
        }
    }
    
    if (self.vpns.count == 1)
    {
        [[VPNManager sharedInstance] removeObjectForKey:kSelectedVPNID];
    }
    else
    {
        if ([vpnID isEqualToString:vpn.VPNID])
        {
            VPN *anotherVPN;
            if (!indexPath.row)
            {
                anotherVPN = self.vpns[indexPath.row + 1];
            }
            else
            {
                anotherVPN = self.vpns[0];
            }
            
            [[VPNManager sharedInstance] setObject:anotherVPN.VPNID forKey:kSelectedVPNID];
        }
    }
    
    [self.tableView beginUpdates];
    [self.vpns removeObject:vpn];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    
    [self.tableView reloadData];
}

@end
