//
//  SwitchTableCell.h
//  VPN
//
//  Created by ZhaoWei on 15/6/12.
//  Copyright (c) 2015年 csdept. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const kSwitchValueChangedNotification;

@interface SwitchTableCell : UITableViewCell

@property (nonatomic, strong) UILabel  *label;
@property (nonatomic, strong) UISwitch *switchCtrl;

@end
