//
//  VPNKeyChainWrapper.m
//  VPN
//
//  Created by ZhaoWei on 15/6/9.
//  Copyright (c) 2015年 csdept. All rights reserved.
//

#import "UICKeyChainStore+PersistentRef.h"
#import "VPNKeyChainWrapper.h"

static NSString * const kKeyChainService = @"com.zte.VPN";

@interface VPNKeyChainWrapper ()

@property (nonatomic, strong) UICKeyChainStore *keyChain;

@end

@implementation VPNKeyChainWrapper

+ (VPNKeyChainWrapper *)sharedInstance
{
    static VPNKeyChainWrapper *sharedInstance = nil;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        sharedInstance = [[VPNKeyChainWrapper alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _keyChain = [[UICKeyChainStore alloc] initWithService:kKeyChainService];
    }
    return self;
}

- (void)setPassword:(NSString *)password forVPNID:(NSString *)vpnID
{
    NSString *key = [[NSURL URLWithString:vpnID] lastPathComponent];
    [self.keyChain setString:password forKey:key];
}

- (void)setSecret:(NSString *)secret forVPNID:(NSString *)vpnID
{
    NSString *key = [[vpnID lastPathComponent] stringByAppendingString:@"_secret"];
    [self.keyChain setString:secret forKey:key];
}

- (NSData *)passwordForVPNID:(NSString *)vpnID
{
    NSString *key = [[NSURL URLWithString:vpnID] lastPathComponent];
    return [self.keyChain persistentRefDataForKey:key];
}

- (NSData *)secretForVPNID:(NSString *)vpnID
{
     NSString *key = [[vpnID lastPathComponent] stringByAppendingString:@"_secret"];
    return [self.keyChain persistentRefDataForKey:key];
}

@end
