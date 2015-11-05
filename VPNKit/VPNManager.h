//
//  VPNManager.h
//  VPN
//
//  Created by ZhaoWei on 15/6/9.
//  Copyright (c) 2015年 csdept. All rights reserved.
//

@import NetworkExtension;
@import Foundation;
@class VPN;

extern NSString * const kConnectVPNErrorNofitication;

@interface VPNManager : NSObject

@property (nonatomic, assign, readonly) NEVPNStatus status;

+ (VPNManager *)sharedInstance;

/**
 * loads the current VPN configuration from the caller's VPN preferences
 * @see NEVPNManager
 **/
- (void)loadFromPreferencesWithCompletionHandler:(void(^)(NSError *error))completionHandler;

/**
 * removes the VPN configuration from the caller's VPN preferences
 * @see NEVPNManager
 **/
- (void)removeFromPreferencesWithCompletionHandler:(void(^)(NSError *error))completionHandler;

/**
 * 连接VPN
 * @param prefix VPN标题前缀，区分App与Extension
 **/
- (void)connectVPN:(VPN *)vpn titlePrefix:(NSString *)prefix;

/**
 * 断开VPN连接
 **/
- (void)disConnect;

//UserDefault
- (void)setObject:(id)object forKey:(id)key;
- (NSString *)stringForKey:(NSString *)key;
- (void)removeObjectForKey:(NSString *)key;

@end
