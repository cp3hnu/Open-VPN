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
        [_manager loadFromPreferencesWithCompletionHandler:^(NSError *error) {
            if (error)
            {
                NSLog(@"Failed to load preferences: %@", error);
            }
        }];
        _manager.localizedDescription = @"VPN";
        _manager.enabled = YES;
        
        _userDefault = [[NSUserDefaults alloc] initWithSuiteName:kAppGroupIdentifier];
    }
    return self;
}

- (NEVPNStatus)status
{
    return self.manager.connection.status;
}

- (void)connectVPN:(VPN *)vpn titlePrefix:(NSString *)prefix;
{
    NEVPNProtocolIPSec *p = [[NEVPNProtocolIPSec alloc] init];
    p.username = vpn.account;
    p.passwordReference = [[VPNKeyChainWrapper sharedInstance] passwordForVPNID:vpn.VPNID];
    p.serverAddress = vpn.server;
    p.authenticationMethod = NEVPNIKEAuthenticationMethodSharedSecret;
    p.sharedSecretReference = [[VPNKeyChainWrapper sharedInstance] secretForVPNID:vpn.VPNID];
    p.localIdentifier = vpn.groupName;
    p.useExtendedAuthentication = YES;
    p.disconnectOnSleep = [vpn.disconnectOnSleep boolValue];
    
    [self.manager setEnabled:YES];
    [self.manager setProtocol:p];
    
    if (![vpn.isOnDemand boolValue])
    {
        [self.manager setOnDemandEnabled:NO];
    }
    else
    {
        [self.manager setOnDemandEnabled:YES];
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
    
    [self.manager setLocalizedDescription:description];
    
    [self.manager saveToPreferencesWithCompletionHandler:^(NSError *error) {
        if (error)
        {
            NSLog(@"SaveToPreferences error: %@", error);
        }
        else
        {
            NSError *startError;
            [self.manager.connection startVPNTunnelAndReturnError:&startError];
            
            if (startError)
            {
                NSLog(@"StartVPNTunnel error: %@", startError);
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
