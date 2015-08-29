//
//  TextFieldTableCell.m
//  VPN
//
//  Created by CP3 on 15/8/29.
//  Copyright (c) 2015年 csdept. All rights reserved.
//

#import "TextFieldTableCell.h"

@implementation TextFieldTableCell

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
        
        UITextField *textfield = [[UITextField alloc] init];
        textfield.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textfield.textColor = [UIColor blackColor];
        textfield.autocorrectionType = UITextAutocorrectionTypeNo;
        textfield.spellCheckingType = UITextSpellCheckingTypeNo;
        textfield.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textfield.returnKeyType = UIReturnKeyNext;
        [self.contentView addSubview:textfield];
        self.textField = textfield;
        
        label.translatesAutoresizingMaskIntoConstraints = NO;
        textfield.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[label(==80)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(label)]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[label]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(label)]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[label]-[textfield(>=0)]-|" options:NSLayoutFormatAlignAllTop|NSLayoutFormatAlignAllBottom metrics:nil views:NSDictionaryOfVariableBindings(label, textfield)]];
    }
    
    return self;
}

@end
