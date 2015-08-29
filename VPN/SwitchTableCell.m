//
//  SwitchTableCell.m
//  VPN
//
//  Created by ZhaoWei on 15/6/12.
//  Copyright (c) 2015年 csdept. All rights reserved.
//

#import "SwitchTableCell.h"

NSString * const kSwitchValueChangedNotification = @"Switch_Value_Changed_Notification";

@implementation SwitchTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *label = [[UILabel alloc] init];
        label.textColor = [UIColor blackColor];
        label.textAlignment = NSTextAlignmentLeft;
        label.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:label];
        self.label = label;
        
        UISwitch *switchCtrl = [[UISwitch alloc] init];
        [switchCtrl addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:switchCtrl];
        self.switchCtrl = switchCtrl;
        
        label.translatesAutoresizingMaskIntoConstraints = NO;
        switchCtrl.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[label]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(label)]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[label]-(>=0)-[switchCtrl]-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:NSDictionaryOfVariableBindings(label, switchCtrl)]];
    }
    return self;
}

- (void)switchValueChanged:(UISwitch *)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kSwitchValueChangedNotification object:sender];
}

@end
