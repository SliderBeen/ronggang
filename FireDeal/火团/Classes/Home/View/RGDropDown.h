//
//  RGDropDown.h
//  火团
//
//  Created by qianfeng on 15/6/27.
//  Copyright (c) 2015年 ronggang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RGDropDown;

@protocol RGDropDownDataSource <NSObject>

@required
- (NSInteger)numberOfRowsInMainTable:(RGDropDown *)dropDown;

- (NSString *)dropDown:(RGDropDown *)dropDown titleForRowInMainTable:(NSInteger)row;

- (NSArray *)dropDown:(RGDropDown *)dropDown subdataForRowInMainTable:(NSInteger)row;

@optional
- (NSString *)dropDown:(RGDropDown *)dropDown iconForRowInMainTable:(NSInteger)row;

- (NSString *)dropDown:(RGDropDown *)dropDown selectedIconForRowInMainTable:(NSInteger)row;

@end

@protocol RGDropDownDelegate <NSObject>

@optional
- (void)dropDown:(RGDropDown *)dropDown didSelectRowInMainTable:(NSInteger)row;

- (void)dropDown:(RGDropDown *)dropDown didSelectRowInSubTable:(NSInteger)subrow inMainTable:(NSInteger)row;

@end

@interface RGDropDown : UIView


@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, weak) id<RGDropDownDataSource> dataSource;
@property (nonatomic, weak) id<RGDropDownDelegate> delegate;

+ (instancetype)dropDown;

@end
