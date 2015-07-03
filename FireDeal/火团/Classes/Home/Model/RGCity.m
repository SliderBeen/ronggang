//
//  RGCity.m
//  火团
//
//  Created by qianfeng on 15/6/27.
//  Copyright (c) 2015年 ronggang. All rights reserved.
//

#import "RGCity.h"
#import "RGRegion.h"
#import "MJExtension.h"

@implementation RGCity

- (NSDictionary *)objectClassInArray
{
    return @{@"regions":[RGRegion class]};
}

@end
