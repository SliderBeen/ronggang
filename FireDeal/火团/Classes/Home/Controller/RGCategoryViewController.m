//
//  RGCategoryViewController.m
//  火团
//
//  Created by qianfeng on 15/6/27.
//  Copyright (c) 2015年 ronggang. All rights reserved.
//

#import "RGCategoryViewController.h"
#import "MJExtension.h"
#import "UIView+Extension.h"
#import "RGCategory.h"
#import "RGDropDown.h"
#import "RGMetaTool.h"
#import "RGConst.h"

@interface RGCategoryViewController ()<RGDropDownDataSource, RGDropDownDelegate>

@end

@implementation RGCategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    RGDropDown *dropDown = [RGDropDown dropDown];
    dropDown.dataSource = self;
    dropDown.delegate = self;
    self.preferredContentSize = dropDown.size;
    [self.view addSubview:dropDown];
}

#pragma mark - dropDownDataSource
- (NSInteger)numberOfRowsInMainTable:(RGDropDown *)dropDown
{
    return [RGMetaTool categories].count;
}

- (NSString *)dropDown:(RGDropDown *)dropDown titleForRowInMainTable:(NSInteger)row
{
    RGCategory *category = [RGMetaTool categories][row];
    return category.name;
}

- (NSArray *)dropDown:(RGDropDown *)dropDown subdataForRowInMainTable:(NSInteger)row
{
    RGCategory *category = [RGMetaTool categories][row];
    return category.subcategories;
}

- (NSString *)dropDown:(RGDropDown *)dropDown iconForRowInMainTable:(NSInteger)row
{
    RGCategory *category = [RGMetaTool categories][row];
    return category.small_icon;
}

- (NSString *)dropDown:(RGDropDown *)dropDown selectedIconForRowInMainTable:(NSInteger)row
{
    RGCategory *category = [RGMetaTool categories][row];
    return category.small_highlighted_icon;
}

#pragma mark - dropDownDelegate
- (void)dropDown:(RGDropDown *)dropDown didSelectRowInMainTable:(NSInteger)row
{
    RGCategory *category = [RGMetaTool categories][row];
    if (!category.subcategories.count) {
        [RGNotificationCenter postNotificationName:RGCategoryDidChangeNotification object:nil userInfo:@{RGSelectCategory : category}];
    }
}

- (void)dropDown:(RGDropDown *)dropDown didSelectRowInSubTable:(NSInteger)subrow inMainTable:(NSInteger)row
{
    RGCategory *category = [RGMetaTool categories][row];
    [RGNotificationCenter postNotificationName:RGCategoryDidChangeNotification object:nil userInfo:@{RGSelectCategory : category, RGSelectSubCategoryName : category.subcategories[subrow]}];
}

@end
