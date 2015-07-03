//
//  RGDeal.m
//  火团
//
//  Created by qianfeng on 15/6/28.
//  Copyright (c) 2015年 ronggang. All rights reserved.
//

#import "RGDeal.h"
#import "MJExtension.h"
#import "RGBusiness.h"

@implementation RGDeal

- (NSDictionary *)replacedKeyFromPropertyName
{
    return @{@"desc" : @"description"};
}

- (NSDictionary *)objectClassInArray
{
    return @{@"businesses" : [RGBusiness class]};
}

MJCodingImplementation

- (BOOL)isEqual:(RGDeal *)other
{
    return [self.deal_id isEqual:other.deal_id];
}

@end
