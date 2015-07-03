//
//  RGDealTool.h
//  火团
//
//  Created by qianfeng on 15/6/30.
//  Copyright (c) 2015年 ronggang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RGDeal;

@interface RGDealTool : NSObject

+ (NSArray *)collectDeals:(int)page;

+ (int)collectDealsCount;

+ (void)addCollectDeal:(RGDeal *)deal;

+ (void)removeCollectDeal:(RGDeal *)deal;

+ (BOOL)isCollected:(RGDeal *)deal;

@end
