//
//  VPN.h
//  VPN
//
//  Created by ZhaoWei on 15/6/8.
//  Copyright (c) 2015年 csdept. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface VPN : NSManagedObject

@property (nonatomic, retain) NSString * account;
@property (nonatomic, retain) NSNumber * disconnectOnSleep;
@property (nonatomic, retain) NSNumber * isOnDemand;
@property (nonatomic, retain) NSString * groupName;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * secretKey;
@property (nonatomic, retain) NSString * server;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * rule;

- (NSString *)VPNID;

@end
