//
//  UIDevice+Version.m
//  123
//
//  Created by zhaowei on 14-9-24.
//  Copyright (c) 2014年 csdept. All rights reserved.
//

#import "UIDevice+Type.h"

//版本比较
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch range:NSMakeRange(0, 1)] != NSOrderedAscending)

@implementation UIDevice (Type)

- (BOOL)isPhone
{
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone;
}

- (BOOL)isPad
{
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}

- (BOOL)isBigPad
{
    if([self isPad])
    {
        if([self deviceType] == DT_iPad || [self deviceType] == DT_iPad_Retina)
        {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)isPadMini
{
    if([self isPad])
    {
        if([self deviceType] == DT_iPad_Mini || [self deviceType] == DT_iPad_Mini_Retina)
        {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)isGEVersion:(NSString *)version
{
    return SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(version);
}

- (DeviceType)deviceType
{
    CGSize size = [[UIScreen mainScreen] currentMode].size;
    if (CGSizeEqualToSize(size, CGSizeMake(640, 960)))
    {
        return DT_iPhone4S;
    }
    
    else if (CGSizeEqualToSize(size, CGSizeMake(640, 1136)))
    {
        return DT_iPhone5;
    }
    
    else if (CGSizeEqualToSize(size, CGSizeMake(750, 1334)))
    {
        return DT_iPhone6;
    }
    
    else if (CGSizeEqualToSize(size, CGSizeMake(1242, 2208)))
    {
        return DT_iPhone6_Plus;
    }
    
    else if (CGSizeEqualToSize(size, CGSizeMake(1024, 768)))
    {
        return DT_iPad;
    }
    
    else if (CGSizeEqualToSize(size, CGSizeMake(768, 1024)))
    {
        return DT_iPad_Mini;
    }
    
    else if (CGSizeEqualToSize(size, CGSizeMake(2048, 1536)))
    {
        return DT_iPad_Retina;
    }
    
    else if (CGSizeEqualToSize(size, CGSizeMake(1536, 2048)))
    {
        return DT_iPad_Mini_Retina;
    }
    
    return DT_UNKNOWN;
}


@end
