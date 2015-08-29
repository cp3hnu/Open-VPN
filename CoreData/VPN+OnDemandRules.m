//
//  VPN+OnDemandRules.m
//  VPN
//
//  Created by ZhaoWei on 15/6/12.
//  Copyright (c) 2015年 csdept. All rights reserved.
//

#import "VPN+OnDemandRules.h"

@implementation VPN (OnDemandRules)

+ (NSCharacterSet *)separatorCharacterSet
{
    NSMutableCharacterSet *characterSet = [NSMutableCharacterSet newlineCharacterSet];
    [characterSet addCharactersInString:@","];
    
    return characterSet;
}

- (NSArray *)onDemandRules
{
    if (!self.rule || [self.rule isEqualToString:@""])
    {
        return [NSArray array];
    }
    
    NSCharacterSet *set = [[self class] separatorCharacterSet];
    
    NSString *string = [self.rule stringByTrimmingCharactersInSet:set];
    if ([string isEqualToString:@""])
    {
        return [NSArray array];
    }
    
    NSArray *array = [string componentsSeparatedByCharactersInSet:set];
    NSMutableArray *mArray = [NSMutableArray array];
    
    for (NSString *str in array)
    {
        NSString *newStr = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (![newStr isEqualToString:@""])
            [mArray addObject:newStr];
    }
    
    return mArray;
}

@end
