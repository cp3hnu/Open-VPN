//
//  SubtitleTableCell.m
//  VPN
//
//  Created by ZhaoWei on 15/6/12.
//  Copyright (c) 2015年 csdept. All rights reserved.
//

#import "SubtitleTableCell.h"

@implementation SubtitleTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check_mark"]];
        [self.contentView addSubview:imageView];
        self.checkImageView = imageView;
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        UILabel *serverLabel = [[UILabel alloc] init];
        serverLabel.textColor = [UIColor blackColor];
        serverLabel.textAlignment = NSTextAlignmentLeft;
        serverLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:serverLabel];
        self.serverLabel = serverLabel;
        
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        serverLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[imageView]-15-[titleLabel]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(imageView, titleLabel)]];
        [imageView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[titleLabel]-5-[serverLabel]-10-|" options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight metrics:nil views:NSDictionaryOfVariableBindings(titleLabel, serverLabel)]];
    }
    
    return self;
}

@end
