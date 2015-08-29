//
//  UIColor+String.m
//  EdusnsClient
//
//  Created by zhaowei on 14-6-5.
//  Copyright (c) 2014年 csdept. All rights reserved.
//

#import "UIColor+String.h"

@implementation UIColor (String)

+ (instancetype)colorWithHexString:(NSString *)hexString
{
    return [[self alloc] initWithHexString:hexString];
}

- (instancetype)initWithHexString:(NSString *)hexString
{
    if(hexString.length != 6)
    {
        NSLog(@"The string length isn't equal to 6.");
        return [[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:1.0f];
    }
    
    NSString *regExStr = @"^[0-9a-fA-F]{6}$";
    NSRegularExpression *regEx = [NSRegularExpression regularExpressionWithPattern:regExStr options:0 error:NULL];
    NSTextCheckingResult *firstMatch = [regEx firstMatchInString:hexString options:0 range:NSMakeRange(0, [hexString length])];
    if(!firstMatch)
    {
        NSLog(@"The isn't hex string.");
        return [[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:1.0f];
    }
    
    unsigned int red, green, blue;
    NSRange range;
    range.length = 2;
    range.location = 0;
    [[NSScanner scannerWithString:[hexString substringWithRange:range]] scanHexInt:&red];
    range.location = 2;
    [[NSScanner scannerWithString:[hexString substringWithRange:range]] scanHexInt:&green];
    range.location = 4;
    [[NSScanner scannerWithString:[hexString substringWithRange:range]] scanHexInt:&blue];
    
    return [[UIColor alloc] initWithRed:red/255.0 green:green/255.0f blue:blue/255.0f alpha:1.0f];
}

@end
