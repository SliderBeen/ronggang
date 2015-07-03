//
//  RGDeal.h
//  火团
//
//  Created by qianfeng on 15/6/28.
//  Copyright (c) 2015年 ronggang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RGRestrictions;

@interface RGDeal : NSObject

@property (nonatomic, copy) NSString *deal_id;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, strong) NSNumber *list_price;
@property (nonatomic, strong) NSNumber *current_price;
@property (nonatomic, assign) int purchase_count;
@property (nonatomic, copy) NSString *image_url;
@property (nonatomic, copy) NSString *s_image_url;
@property (nonatomic, copy) NSString *publish_date;
@property (nonatomic, copy) NSString *deal_h5_url;
@property (nonatomic, copy) NSString *deal_url;
@property (nonatomic, strong) RGRestrictions *restrictions;
@property (nonatomic, copy) NSString *purchase_deadline;

@property (nonatomic, assign, getter = isEditing) BOOL editing;
@property (nonatomic, assign, getter = isChecked) BOOL checked;

@property (nonatomic, strong) NSArray *businesses;
@property (nonatomic, strong) NSArray *categories;

@end
