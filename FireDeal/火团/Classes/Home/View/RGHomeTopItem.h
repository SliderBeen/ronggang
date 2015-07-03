//
//  RGHomeTopItem.h
//  火团
//
//  Created by qianfeng on 15/6/27.
//  Copyright (c) 2015年 ronggang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RGHomeTopItem : UIView

+ (instancetype)item;

- (void)addTarget:(id)target action:(SEL)action;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subTitle;

- (void)setIcon:(NSString *)icon highIcon:(NSString *)highIcon;

@end
