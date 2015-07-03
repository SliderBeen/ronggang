//
//  RGCategory.h
//  火团
//
//  Created by qianfeng on 15/6/27.
//  Copyright (c) 2015年 ronggang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RGCategory : NSObject

@property (nonatomic, copy) NSString *highlighted_icon;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *small_highlighted_icon;
@property (nonatomic, copy) NSString *small_icon;
@property (nonatomic, copy) NSString *map_icon;
@property (nonatomic, strong) NSArray *subcategories;

@end
