//
//  UICKeyChainStore+PersistentRef.m
//  VPN
//
//  Created by ZhaoWei on 15/6/5.
//  Copyright (c) 2015年 csdept. All rights reserved.
//

#import "UICKeyChainStore+PersistentRef.h"

@implementation UICKeyChainStore (PersistentRef)

- (NSData *)persistentRefDataForKey:(NSString *)key
{
    return [self persistentRefDataForKey:key error:nil];
}

- (NSData *)persistentRefDataForKey:(NSString *)key error:(NSError *__autoreleasing *)error
{
    NSMutableDictionary *query = [self performSelector:@selector(query)];
    query[(__bridge __strong id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
    query[(__bridge __strong id)kSecReturnPersistentRef] = (__bridge id)kCFBooleanTrue;
    
    query[(__bridge __strong id)kSecAttrAccount] = key;
    
    CFTypeRef data = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &data);
    
    if (status == errSecSuccess) {
        NSData *ret = [NSData dataWithData:(__bridge NSData *)data];
        if (data) {
            CFRelease(data);
            return ret;
        } else {
            NSError *e = [self.class persistentRefUnexpectedError:NSLocalizedString(@"Unexpected error has occurred.", nil)];
            if (error) {
                *error = e;
            }
            return nil;
        }
    } else if (status == errSecItemNotFound) {
        return nil;
    }
    
    NSError *e = [self.class persistentRefSecurityError:status];
    if (error) {
        *error = e;
    }
    return nil;
}

+ (NSError *)persistentRefUnexpectedError:(NSString *)message
{
    NSError *error = [NSError errorWithDomain:UICKeyChainStoreErrorDomain code:-99999 userInfo:@{NSLocalizedDescriptionKey: message}];
    NSLog(@"error: [%@] %@", @(error.code), error.localizedDescription);
    return error;
}

+ (NSError *)persistentRefSecurityError:(OSStatus)status
{
    NSString *message = @"Security error has occurred.";
#if !TARGET_OS_IPHONE
    CFStringRef description = SecCopyErrorMessageString(status, NULL);
    if (description) {
        message = (__bridge_transfer NSString *)description;
    }
#endif
    NSError *error = [NSError errorWithDomain:UICKeyChainStoreErrorDomain code:status userInfo:@{NSLocalizedDescriptionKey: message}];
    NSLog(@"OSStatus error: [%@] %@", @(error.code), error.localizedDescription);
    return error;
}

@end
