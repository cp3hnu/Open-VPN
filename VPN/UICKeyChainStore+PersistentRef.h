//
//  UICKeyChainStore+PersistentRef.h
//  VPN
//
//  Created by ZhaoWei on 15/6/5.
//  Copyright (c) 2015年 csdept. All rights reserved.
//

#import "UICKeyChainStore.h"

@interface UICKeyChainStore (PersistentRef)

- (NSData *)persistentRefDataForKey:(NSString *)key;
- (NSData *)persistentRefDataForKey:(NSString *)key error:(NSError *__autoreleasing *)error;

@end
