//
//  UIColor+String.h
//  EdusnsClient
//
//  Created by zhaowei on 14-6-5.
//  Copyright (c) 2014年 csdept. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (String)

+ (instancetype)colorWithHexString:(NSString *)hexString;

- (instancetype)initWithHexString:(NSString *)hexString;

@end
