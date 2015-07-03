//
//  RGDistrictViewController.m
//  火团
//
//  Created by qianfeng on 15/6/27.
//  Copyright (c) 2015年 ronggang. All rights reserved.
//

#import "RGDistrictViewController.h"
#import "RGDropDown.h"
#import "UIView+Extension.h"
#import "MJExtension.h"
#import "RGNavigationController.h"
#import "RGCityViewController.h"
#import "RGMetaTool.h"
#import "RGRegion.h"
#import "RGConst.h"

@interface RGDistrictViewController ()<RGDropDownDataSource, RGDropDownDelegate>
- (IBAction)changeCity;

@end

@implementation RGDistrictViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *title = [self.view.subviews firstObject];
    
    RGDropDown *drowDown = [RGDropDown dropDown];
    drowDown.y = title.height;
    drowDown.dataSource = self;
    drowDown.delegate = self;
    [self.view addSubview:drowDown];
    self.preferredContentSize = CGSizeMake(drowDown.width, CGRectGetMaxY(drowDown.frame));
}

#pragma mark - dropDownDataSource
- (NSInteger)numberOfRowsInMainTable:(RGDropDown *)dropDown
{
    return self.regions.count;
}

- (NSString *)dropDown:(RGDropDown *)dropDown titleForRowInMainTable:(NSInteger)row
{
    RGRegion *region = [self regions][row];
    return region.name;
}

- (NSArray *)dropDown:(RGDropDown *)dropDown subdataForRowInMainTable:(NSInteger)row
{
    RGRegion *region = [self regions][row];
    return region.subregions;
}

#pragma mark - dropDownDelegate
- (void)dropDown:(RGDropDown *)dropDown didSelectRowInMainTable:(NSInteger)row
{
    RGRegion *region = self.regions[row];
    if (!region.subregions.count) {
        [RGNotificationCenter postNotificationName:RGRegionDidChangeNotification object:nil userInfo:@{RGSelectRegion : region}];
    }
}

- (void)dropDown:(RGDropDown *)dropDown didSelectRowInSubTable:(NSInteger)subrow inMainTable:(NSInteger)row
{
    RGRegion *region = self.regions[row];
    [RGNotificationCenter postNotificationName:RGRegionDidChangeNotification object:nil userInfo:@{RGSelectRegion : region, RGSelectSubRegionName : region.subregions[subrow]}];
}

- (IBAction)changeCity {
    [self.popover dismissPopoverAnimated:YES];
    RGCityViewController *city = [[RGCityViewController alloc] init];
    RGNavigationController *nav = [[RGNavigationController alloc] initWithRootViewController:city];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:nav animated:YES completion:nil];
}
@end
