//
//  VPNManager.h
//  VPN
//
//  Created by ZhaoWei on 15/6/9.
//  Copyright (c) 2015年 csdept. All rights reserved.
//

@import NetworkExtension;
#import <Foundation/Foundation.h>
@class VPN;

extern NSString * const kConnectVPNErrorNofitication;
extern NSString * const kSaveVPNErrorNofitication;

@interface VPNManager : NSObject

@property (nonatomic, assign, readonly) NEVPNStatus status;

+ (VPNManager *)sharedInstance;
- (void)loadFromPreferencesWithCompletionHandler:(void(^)())completionHandler;
- (void)removeFromPreferences;
- (void)connectVPN:(VPN *)vpn titlePrefix:(NSString *)prefix;
- (void)disConnect;

//UserDefault
- (void)setObject:(id)object forKey:(id)key;
- (NSString *)stringForKey:(NSString *)key;
- (void)removeObjectForKey:(NSString *)key;



@end
