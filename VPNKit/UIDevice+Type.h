//
//  UIDevice+Version.h
//  123
//
//  Created by zhaowei on 14-9-24.
//  Copyright (c) 2014年 csdept. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DeviceType)
{
    DT_UNKNOWN = 0,
    DT_iPhone4S,         //iPhone4S、iPhone4
    DT_iPhone5,          //iPhone5、iPhone5C和iPhone5S
    DT_iPhone6,          //iPhone6
    DT_iPhone6_Plus,     //iPhone6 Plus
    DT_iPad,             //iPad1、iPad2
    DT_iPad_Mini,        //iPad mini1
    DT_iPad_Retina,      //New iPad、iPad4和iPad Air
    DT_iPad_Mini_Retina  //iPad mini2
};

@interface UIDevice (Type)

/**
 * 判断当前设备是不是iPhone
 **/
- (BOOL)isPhone;

/**
 * 判断当前设备是不是iPad，包括普通iPad和iPad mini
 **/
- (BOOL)isPad;

/**
 * 判断当前设备是不是普通iPad，不包括iPad mini
 **/
- (BOOL)isBigPad;

/**
 * 判断当前设备是不是iPad mini
 **/
- (BOOL)isPadMini;

/**
 * 判断当前系统版本是否大于等于version
 * @code
 if([self isGEVersion:@"8"])
 {
    //iOS8及以上
 }
 else if ([self isGEVersion:@"7"])
 {
    //iOS7及以上
 }
 else
 {
    //iOS7以下
 }
 **/
- (BOOL)isGEVersion:(NSString *)version;

/**
 * 根据分辨率返回当前设备类型
 * @return DeviceType
 **/
- (DeviceType)deviceType;

@end
