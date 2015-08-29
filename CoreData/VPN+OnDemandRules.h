//
//  VPN+OnDemandRules.h
//  VPN
//
//  Created by ZhaoWei on 15/6/12.
//  Copyright (c) 2015年 csdept. All rights reserved.
//

#import "VPN.h"

@interface VPN (OnDemandRules)

+ (NSCharacterSet *)separatorCharacterSet;
- (NSArray *)onDemandRules;

@end
