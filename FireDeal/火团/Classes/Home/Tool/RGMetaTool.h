//
//  RGMetaTool.h
//  火团
//
//  Created by qianfeng on 15/6/28.
//  Copyright (c) 2015年 ronggang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RGCategory, RGDeal;

@interface RGMetaTool : NSObject

+ (NSArray *)cities;

+ (NSArray *)categories;

+ (RGCategory *)categoryWithDeal:(RGDeal *)deal;

+ (NSArray *)sorts;

@end
