//
//  VPNDataManager.h
//  VPN
//
//  Created by ZhaoWei on 15/6/8.
//  Copyright (c) 2015年 csdept. All rights reserved.
//

@import CoreData;
@class VPN;
#import <Foundation/Foundation.h>

@interface VPNDataManager : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;

+ (VPNDataManager *)sharedInstance;
- (VPN *)insertVPN;
- (void)deleteVPN:(VPN *)vpn;
- (void)saveContext;
- (NSArray *)fetchAllVPNs;

@end
