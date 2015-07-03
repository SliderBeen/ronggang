//
//  RGMetaTool.m
//  火团
//
//  Created by qianfeng on 15/6/28.
//  Copyright (c) 2015年 ronggang. All rights reserved.
//

#import "RGMetaTool.h"
#import "MJExtension.h"
#import "RGCity.h"
#import "RGCategory.h"
#import "RGSort.h"
#import "RGDeal.h"

@implementation RGMetaTool

static NSArray *_cities;

+ (NSArray *)cities
{
    if (!_cities) {
        _cities = [RGCity objectArrayWithFilename:@"cities.plist"];
    }
    return _cities;
}

static NSArray *_categories;

+ (NSArray *)categories
{
    if (!_categories) {
        _categories = [RGCategory objectArrayWithFilename:@"categories.plist"];
    }
    return _categories;
}

+ (RGCategory *)categoryWithDeal:(RGDeal *)deal
{
    NSArray *cs = [self categories];
    NSString *cname = [deal.categories firstObject];
    for (RGCategory *category in cs) {
        if ([category.name isEqualToString:cname]) {
            return category;
        }
        if ([category.subcategories containsObject:cname]) {
            return category;
        }
    }
    return nil;
}

static NSArray *_sorts;

+ (NSArray *)sorts
{
    if (!_sorts) {
        _sorts = [RGSort objectArrayWithFilename:@"sorts.plist"];
    }
    return _sorts;
}

@end
