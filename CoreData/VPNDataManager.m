//
//  VPNDataManager.m
//  VPN
//
//  Created by ZhaoWei on 15/6/8.
//  Copyright (c) 2015年 csdept. All rights reserved.
//

#import "VPNDataManager.h"
#import "VPN.h"

static NSString * const kAppModelName = @"VPN";
static NSString * const kEntityName = @"VPN";
static NSString * const kAppGroupIdentifier = @"group.com.zte.VPN";

@interface VPNDataManager ()

@property (nonatomic, strong, readwrite) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readwrite) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong, readwrite) NSManagedObjectContext *managedObjectContext;

@end

@implementation VPNDataManager

+ (VPNDataManager *)sharedInstance
{
    static VPNDataManager *sharedInstance = nil;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        sharedInstance = [[VPNDataManager alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - Database Model
- (NSURL *)directoryURL
{
    return [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:kAppGroupIdentifier];
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil)
    {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:kAppModelName withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [self.directoryURL URLByAppendingPathComponent:@"VPN.sqlite"];
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (VPN *)insertVPN
{
    return (VPN *)[[NSManagedObject alloc] initWithEntity:[self VPNEntity] insertIntoManagedObjectContext:self.managedObjectContext];
}

- (void)deleteVPN:(VPN *)vpn
{
    [self.managedObjectContext deleteObject:vpn];
    
    [self saveContext];
}

- (NSEntityDescription *)VPNEntity
{
    return [NSEntityDescription entityForName:kEntityName inManagedObjectContext:self.managedObjectContext];
}

- (void)saveContext
{
    NSError *error = nil;
    if (![self.managedObjectContext save:&error])
    {
        NSLog(@"Save context error = %@", error);
        [self.managedObjectContext rollback];
    }
}

- (NSArray *)fetchAllVPNs
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:kEntityName inManagedObjectContext:self.managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSError *error;
    NSArray *vpns = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if (error)
    {
        NSLog(@"Fetch VPN Error = %@", error);
        return nil;
    }
    
    return vpns;
}


@end
