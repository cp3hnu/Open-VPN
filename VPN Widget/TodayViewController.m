//
//  TodayViewController.m
//  VPN Widget
//
//  Created by ZhaoWei on 15/6/15.
//  Copyright (c) 2015年 csdept. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "VPNKit.h"
#import "VPN.h"
#import "VPNDataManager.h"

#define NormalHeight 90

#define kSelectedVPNID @"Selected_Today_VPNID_UserDefault"

static NSString * const VPNCellReuseIdentifier = @"VPNCell";
static NSString * const AddCellReuseIdentifier = @"AddCell";

@interface VPNCell : UICollectionViewCell

@property (nonatomic, strong) UISwitch                *switchCtrl;
@property (nonatomic, strong) UILabel                 *titleLabel;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation VPNCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        UISwitch *switchCtrl = [[UISwitch alloc] init];
        switchCtrl.translatesAutoresizingMaskIntoConstraints = NO;
        switchCtrl.userInteractionEnabled = NO;
        [self.contentView addSubview:switchCtrl];
        self.switchCtrl = switchCtrl;
        
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] init];
        indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        indicatorView.hidesWhenStopped = YES;
        indicatorView.backgroundColor = [UIColor clearColor];
        indicatorView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:indicatorView];
        self.indicatorView = indicatorView;
        
        UILabel *label = [[UILabel alloc] init];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.font = [UIFont systemFontOfSize:14];
        label.adjustsFontSizeToFitWidth = YES;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:label];
        self.titleLabel = label;
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[label]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(label)]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[switchCtrl]-5-[label]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(switchCtrl, label)]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:switchCtrl attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:indicatorView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:switchCtrl attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:indicatorView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:switchCtrl attribute:NSLayoutAttributeRight multiplier:1 constant:-3]];
    }
    
    return self;
}

@end

@interface AddCell : UICollectionViewCell

@end

@implementation AddCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        UIImageView *imageView = [UIImageView new];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        imageView.image = [UIImage imageNamed:@"add_book"];
        imageView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:imageView];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[imageView(==50)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(imageView)]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[imageView(==50)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(imageView)]];
    }
    
    return self;
}

@end

@interface TodayViewController () <NCWidgetProviding, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *vpns;
@property (nonatomic, strong) NSString *selectedID;

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(vpnStatusDidChange:)
                                                 name:NEVPNStatusDidChangeNotification
                                               object:nil];
    
    self.preferredContentSize = CGSizeMake(0, NormalHeight);
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(80, 80);
    layout.minimumLineSpacing = 10;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [collectionView registerClass:[VPNCell class] forCellWithReuseIdentifier:VPNCellReuseIdentifier];
    [collectionView registerClass:[AddCell class] forCellWithReuseIdentifier:AddCellReuseIdentifier];
    collectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[collectionView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(collectionView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[collectionView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(collectionView)]];
    
    self.vpns = [[VPNDataManager sharedInstance] fetchAllVPNs];
    self.preferredContentSize = CGSizeMake(0, (self.vpns.count + 1 + 3)/4 * 90);
    [self.collectionView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.preferredContentSize = CGSizeMake(0, self.collectionView.contentSize.height);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NCWidgetProviding
- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets
{
    return UIEdgeInsetsZero;
}

#pragma mark - Property
- (NSString *)selectedID
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kSelectedVPNID];
}

- (void)setSelectedID:(NSString *)selectedID
{
    if (selectedID)
    {
        [[NSUserDefaults standardUserDefaults] setObject:selectedID forKey:kSelectedVPNID];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSelectedVPNID];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - CollectionView Management
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.vpns.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != self.vpns.count)
    {
        VPNCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:VPNCellReuseIdentifier forIndexPath:indexPath];
        
        VPN *vpn = self.vpns[indexPath.row];
        cell.titleLabel.text = vpn.title;
        
        if ([vpn.VPNID isEqualToString:self.selectedID])
        {
            switch ([VPNManager sharedInstance].status) {
                case NEVPNStatusConnecting:
                case NEVPNStatusReasserting:{
                    cell.titleLabel.textColor = [UIColor yellowColor];
                    cell.switchCtrl.on = YES;
                    cell.indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
                    [cell.indicatorView startAnimating];
                    break;
                }
                    
                case NEVPNStatusDisconnecting: {
                    cell.titleLabel.textColor = [UIColor yellowColor];
                    cell.switchCtrl.on = NO;
                    cell.indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
                    [cell.indicatorView startAnimating];
                    break;
                }
                case NEVPNStatusConnected: {
                    cell.titleLabel.textColor = [UIColor colorWithRed:0 green:0.75 blue:1 alpha:1];
                    cell.switchCtrl.on = YES;
                    [cell.indicatorView stopAnimating];
                    break;
                }
                default: {
                    cell.titleLabel.textColor = [UIColor whiteColor];
                    cell.switchCtrl.on = NO;
                    [cell.indicatorView stopAnimating];
                    break;
                }
            }
        }
        else
        {
            cell.titleLabel.textColor = [UIColor whiteColor];
            cell.switchCtrl.on = NO;
            [cell.indicatorView stopAnimating];
        }
        
        return cell;
    }
    else
    {
        AddCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:AddCellReuseIdentifier forIndexPath:indexPath];
        return cell;
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([VPNManager sharedInstance].status == NEVPNStatusConnecting || [VPNManager sharedInstance].status == NEVPNStatusConnected ||
        [VPNManager sharedInstance].status == NEVPNStatusReasserting)
    {
        [[VPNManager sharedInstance] disConnect];
    }
    
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == self.vpns.count)
    {
        [self.extensionContext openURL:[NSURL URLWithString:@"ztevpn://"] completionHandler:nil];
    }
    else
    {
        VPN *vpn = self.vpns[indexPath.row];
        
        if (![vpn.VPNID isEqualToString:self.selectedID])
        {
            [[VPNManager sharedInstance] connectVPN:vpn titlePrefix:@"Widget"];
            self.selectedID = vpn.VPNID;
        }
        else
        {
            if ([VPNManager sharedInstance].status == NEVPNStatusInvalid || [VPNManager sharedInstance].status == NEVPNStatusDisconnected)
            {
                [[VPNManager sharedInstance] connectVPN:vpn titlePrefix:@"Widget"];
            }
        }
    }
}

#pragma mark - NSNotification
- (void)vpnStatusDidChange:(NSNotification *)notification
{
    [self.collectionView reloadData];
}

@end
