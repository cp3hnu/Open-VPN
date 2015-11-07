//
//  VPNManager.m
//  VPN
//
//  Created by ZhaoWei on 15/6/9.
//  Copyright (c) 2015年 csdept. All rights reserved.
//

#import "VPNManager.h"
#import "VPN.h"
#import "VPNKeyChainWrapper.h"
#import "VPN+OnDemandRules.h"
#import "UIDevice+Type.h"

static NSString * const kAppGroupIdentifier = @"group.com.zte.VPN";

@interface VPNManager ()

@property (nonatomic, strong) NEVPNManager   *manager;
@property (nonatomic, strong) NSUserDefaults *userDefault;

@end

@implementation VPNManager

+ (VPNManager *)sharedInstance
{
    static VPNManager *sharedInstance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[VPNManager alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _manager = [NEVPNManager sharedManager];
        
        _userDefault = [[NSUserDefaults alloc] initWithSuiteName:kAppGroupIdentifier];
    }
    return self;
}

- (NEVPNStatus)status
{
    return self.manager.connection.status;
}

- (void)loadFromPreferencesWithCompletionHandler:(void(^)(NSError *error))completionHandler
{
    [self.manager loadFromPreferencesWithCompletionHandler:^(NSError *error) {
        if (error)
        {
            NSLog(@"LoadFromPreferences error: %@", error);
        }
        
        if (completionHandler)
        {
            completionHandler(error);
        }
    }];
}

- (void)removeFromPreferencesWithCompletionHandler:(void(^)(NSError *error))completionHandler
{
    [self.manager removeFromPreferencesWithCompletionHandler:^(NSError *error) {
        if (error)
        {
            NSLog(@"RemoveFromPreferences error: %@", error);
        }
        
        if (completionHandler)
        {
            completionHandler(error);
        }
    }];
}

- (void)connectVPN:(VPN *)vpn titlePrefix:(NSString *)prefix completionHandler:(void(^)(NSError *error))completionHandler
{
    [self.manager loadFromPreferencesWithCompletionHandler:^(NSError *error) {
        if (error)
        {
            NSLog(@"LoadFromPreferences error: %@", error);

            if (completionHandler)
            {
                completionHandler(error);
            }
        }
        else
        {
            [self saveAndStartVPNTunnel:vpn titlePrefix:prefix completionHandler:completionHandler];
        }
    }];
}

- (void)saveAndStartVPNTunnel:(VPN *)vpn titlePrefix:(NSString *)prefix completionHandler:(void(^)(NSError *error))completionHandler
{
    NEVPNProtocolIPSec *p = [[NEVPNProtocolIPSec alloc] init];
    p.authenticationMethod = NEVPNIKEAuthenticationMethodSharedSecret;
    p.useExtendedAuthentication = YES;
    p.serverAddress = vpn.server;
    p.username = vpn.account;
    p.localIdentifier = vpn.groupName;
    p.disconnectOnSleep = [vpn.disconnectOnSleep boolValue];
    p.passwordReference = [[VPNKeyChainWrapper sharedInstance] passwordForVPNID:vpn.VPNID];
    p.sharedSecretReference = [[VPNKeyChainWrapper sharedInstance] secretForVPNID:vpn.VPNID];
    
    //iOS 9使用protocolConfiguration，代替protocol
    if ([[UIDevice currentDevice] isGEVersion:@"9"])
    {
        self.manager.protocolConfiguration = p;
    }
    else
    {
        self.manager.protocol = p;
    }
    
    self.manager.enabled = YES;
    
    if (![vpn.isOnDemand boolValue])
    {
        self.manager.onDemandEnabled = NO;
    }
    else
    {
        self.manager.onDemandEnabled = YES;
        NEEvaluateConnectionRule *connectRule = [[NEEvaluateConnectionRule alloc] initWithMatchDomains:[vpn onDemandRules] andAction:NEEvaluateConnectionRuleActionConnectIfNeeded];
        NEOnDemandRuleEvaluateConnection *rule = [NEOnDemandRuleEvaluateConnection new];
        rule.connectionRules = @[connectRule];
        self.manager.onDemandRules = @[rule];
    }
    
    NSString *displayName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    NSString *description;
    if (prefix)
    {
        description = [NSString stringWithFormat:@"%@-%@-%@", displayName, prefix, vpn.title];
    }
    else
    {
        description = [NSString stringWithFormat:@"%@-%@", displayName, vpn.title];
    }
    self.manager.localizedDescription = description;
    
    [self.manager saveToPreferencesWithCompletionHandler:^(NSError *error) {
        if (error)
        {
            NSLog(@"SaveToPreferences error: %@", error);
        
            if (completionHandler)
            {
                completionHandler(error);
            }
        }
        else
        {
            NSError *startError;
            [self.manager.connection startVPNTunnelAndReturnError:&startError];
            
            if (startError)
            {
                NSLog(@"StartVPNTunnel error: %@", startError);
                
                //iOS 9第一次saveToPreferences安装VPN到设备之后回到App，需要再调用loadFromPreferences，加载VPN设置
                if (startError.domain == NEVPNErrorDomain && startError.code == NEVPNErrorConfigurationInvalid)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[VPNManager sharedInstance] loadFromPreferencesWithCompletionHandler:nil];
                    });
                }
                
                if (completionHandler)
                {
                    completionHandler(startError);
                }
            }
            else
            {
                if (completionHandler)
                {
                    completionHandler(nil);
                }
            }
        }
    }];
}

- (void)disConnect
{
    [self.manager.connection stopVPNTunnel];
}

#pragma mark - NSUserDefault
- (void)setObject:(id)object forKey:(id)key
{
    [self.userDefault setObject:object forKey:key];
    [self.userDefault synchronize];
}

- (NSString *)stringForKey:(NSString *)key
{
    return [self.userDefault stringForKey:key];
}

- (void)removeObjectForKey:(NSString *)key
{
    [self.userDefault removeObjectForKey:key];
}

@end
