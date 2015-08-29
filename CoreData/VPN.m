//
//  VPN.m
//  VPN
//
//  Created by ZhaoWei on 15/6/8.
//  Copyright (c) 2015年 csdept. All rights reserved.
//

#import "VPN.h"

@implementation VPN

@dynamic account;
@dynamic disconnectOnSleep;
@dynamic groupName;
@dynamic password;
@dynamic secretKey;
@dynamic server;
@dynamic title;
@dynamic isOnDemand;
@dynamic rule;

- (NSString *)VPNID
{
    return self.objectID.URIRepresentation.absoluteString;
}

@end
