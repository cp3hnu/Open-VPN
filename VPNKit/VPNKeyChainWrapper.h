//
//  VPNKeyChainWrapper.h
//  VPN
//
//  Created by ZhaoWei on 15/6/9.
//  Copyright (c) 2015年 csdept. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VPNKeyChainWrapper : NSObject

+ (VPNKeyChainWrapper *)sharedInstance;
- (void)setPassword:(NSString *)password forVPNID:(NSString *)vpnID;
- (void)setSecret:(NSString *)secret forVPNID:(NSString *)vpnID;
- (NSData *)passwordForVPNID:(NSString *)vpnID;
- (NSData *)secretForVPNID:(NSString *)vpnID;

@end
