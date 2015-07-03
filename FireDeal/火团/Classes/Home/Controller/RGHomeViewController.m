//
//  RGHomeViewController.m
//  火团
//
//  Created by qianfeng on 15/6/26.
//  Copyright (c) 2015年 ronggang. All rights reserved.
//

#import "RGHomeViewController.h"
#import "RGConst.h"
#import "UIView+Extension.h"
#import "UIBarButtonItem+Extension.h"
#import "RGHomeTopItem.h"
#import "RGCategoryViewController.h"
#import "RGDistrictViewController.h"
#import "RGMetaTool.h"
#import "RGCity.h"
#import "RGSortViewController.h"
#import "RGSort.h"
#import "RGCategory.h"
#import "RGRegion.h"
#import "DPAPI.h"
#import "RGDeal.h"
#import "RGDealCell.h"
#import "MJExtension.h"
#import "MJRefresh.h"
#import "MBProgressHUD+MJ.h"
#import "UIView+AutoLayout.h"
#import "RGSearchViewController.h"
#import "RGNavigationController.h"
#import "AwesomeMenu.h"
#import "RGCollectViewController.h"
#import "RGRecentViewController.h"
#import "RGMapViewController.h"

@interface RGHomeViewController ()<AwesomeMenuDelegate>

@property (nonatomic, weak) UIBarButtonItem *categoryItem;
@property (nonatomic, weak) UIBarButtonItem *districtItem;
@property (nonatomic, weak) UIBarButtonItem *sortItem;
@property (nonatomic, copy) NSString *selectedCityName;
@property (nonatomic, copy) NSString *selectedCategoryName;
@property (nonatomic, strong) RGSort *selectedSort;
@property (nonatomic, copy) NSString *selectedRegionName;

@property (nonatomic, strong) UIPopoverController *categoryPopover;
@property (nonatomic, strong) UIPopoverController *districtPopover;
@property (nonatomic, strong) UIPopoverController *sortPopover;


@end

@implementation RGHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.selectedCityName = @"武汉";
    [self setupLeftNav];
    [self setupRightNav];
    
    [self setupAwesomeMenu];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [RGNotificationCenter addObserver:self selector:@selector(cityNameDidChange:) name:RGCityDidChangeNotification object:nil];
    
    [RGNotificationCenter addObserver:self selector:@selector(sortDidChange:) name:RGSortDidChangeNotification object:nil];
    
    [RGNotificationCenter addObserver:self selector:@selector(categoryDidChange:) name:RGCategoryDidChangeNotification object:nil];
    
    [RGNotificationCenter addObserver:self selector:@selector(regionDidChange:) name:RGRegionDidChangeNotification object:nil];
}

- (void)setupParams:(NSMutableDictionary *)params
{
    params[@"city"] = self.selectedCityName;
    if (self.selectedRegionName) {
        params[@"region"] = self.selectedRegionName;
    }
    if (self.selectedSort) {
        params[@"sort"] = @(self.selectedSort.value);
    }
    if (self.selectedCategoryName) {
        params[@"category"] = self.selectedCategoryName;
    }

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [RGNotificationCenter removeObserver:self];
}


#pragma mark - 监听通知
- (void)cityNameDidChange:(NSNotification *)notification
{
    NSString *cityName = notification.userInfo[RGSelectCityName];
    RGHomeTopItem *topItem = (RGHomeTopItem *)self.districtItem.customView;
    topItem.title = [NSString stringWithFormat:@"%@ - 全部", cityName];
    topItem.subTitle = nil;
    self.selectedCityName = cityName;
    
    [self.collectionView headerBeginRefreshing];
}

- (void)sortDidChange:(NSNotification *)notification
{
    self.selectedSort = notification.userInfo[RGSelectSort];
    RGHomeTopItem *topItem = (RGHomeTopItem *)self.sortItem.customView;
    topItem.subTitle = self.selectedSort.label;
    
    [self.sortPopover dismissPopoverAnimated:YES];
    
    [self.collectionView headerBeginRefreshing];
}

- (void)categoryDidChange:(NSNotification *)notification
{
    RGCategory *category = notification.userInfo[RGSelectCategory];
    NSString *subCategoryName = notification.userInfo[RGSelectSubCategoryName];
    RGHomeTopItem *topItem = (RGHomeTopItem *)self.categoryItem.customView;
    topItem.title = category.name;
    [topItem setIcon:category.icon highIcon:category.highlighted_icon];
    topItem.subTitle = subCategoryName;
    
    if (subCategoryName == nil || [subCategoryName isEqualToString:@"全部"]) {
        self.selectedCategoryName = category.name;
    } else {
        self.selectedCategoryName = subCategoryName;
    }
    
    if ([self.selectedCategoryName isEqualToString:@"全部分类"]) {
        self.selectedCategoryName = nil;
    }
    
    [self.categoryPopover dismissPopoverAnimated:YES];
    
    [self.collectionView headerBeginRefreshing];

}

- (void)regionDidChange:(NSNotification *)notification
{
    RGRegion *region = notification.userInfo[RGSelectRegion];
    NSString *subRegionName = notification.userInfo[RGSelectSubRegionName];
    RGHomeTopItem *topItem = (RGHomeTopItem *)self.districtItem.customView;
    topItem.title = [NSString stringWithFormat:@"%@ - %@", self.selectedCityName,region.name];
    topItem.subTitle = subRegionName;
    
    if (subRegionName == nil || [subRegionName isEqualToString:@"全部"]) {
        self.selectedRegionName = region.name;
    } else {
        self.selectedRegionName = subRegionName;
    }
    
    if ([self.selectedRegionName isEqualToString:@"全部"]) {
        self.selectedRegionName = nil;
    }
    
    [self.districtPopover dismissPopoverAnimated:YES];
    
    [self.collectionView headerBeginRefreshing];
    
}

- (void)setupLeftNav
{
    UIBarButtonItem *mapItem = [UIBarButtonItem itemWithTarget:self action:@selector(mapClick) image:@"icon_map" highImage:@"icon_map_highlighted"];
    mapItem.customView.width = 60;
    
    UIBarButtonItem *searchItem = [UIBarButtonItem itemWithTarget:self action:@selector(searchClick) image:@"icon_search" highImage:@"icon_search_highlighted"];
    searchItem.customView.width = 60;
    
    self.navigationItem.rightBarButtonItems = @[mapItem,searchItem];
}

#pragma mark - mapClick
- (void)mapClick
{
    RGMapViewController *mapVC = [[RGMapViewController alloc] init];
    RGNavigationController *nav = [[RGNavigationController alloc] initWithRootViewController:mapVC];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - searchClick
- (void)searchClick
{
    if (self.selectedCityName) {
        RGSearchViewController *search = [[RGSearchViewController alloc] init];
        search.selectedCityName = self.selectedCityName;
        RGNavigationController *nav = [[RGNavigationController alloc] initWithRootViewController:search];
        
        [self presentViewController:nav animated:YES completion:nil];
    } else {
        [MBProgressHUD showError:@"请输入城市后再搜索" toView:self.view];
    }
   
}

- (void)setupRightNav
{
    UIBarButtonItem *logoItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_meituan_logo"] style:UIBarButtonItemStyleDone target:nil action:nil];
    logoItem.enabled = NO;
    
    RGHomeTopItem *categoryTopItem = [RGHomeTopItem item];
    UIBarButtonItem *categoryItem = [[UIBarButtonItem alloc] initWithCustomView:categoryTopItem];
    [categoryTopItem addTarget:self action:@selector(categoryClick)];
    self.categoryItem = categoryItem;
    
    RGHomeTopItem *districtTopItem = [RGHomeTopItem item];
    UIBarButtonItem *districtItem = [[UIBarButtonItem alloc] initWithCustomView:districtTopItem];
    [districtTopItem addTarget:self action:@selector(districtClick)];
    self.districtItem = districtItem;
    
    RGHomeTopItem *sortTopItem = [RGHomeTopItem item];
    UIBarButtonItem *sortItem = [[UIBarButtonItem alloc] initWithCustomView:sortTopItem];
    sortTopItem.title = @"排序";
    [sortTopItem setIcon:@"icon_sort" highIcon:@"icon_sort_highlighted"];
    [sortTopItem addTarget:self action:@selector(sortClick)];
    self.sortItem = sortItem;
    
    self.navigationItem.leftBarButtonItems = @[logoItem,categoryItem,districtItem,sortItem];
}


#pragma mark - dropDownButtonClick
- (void)categoryClick
{
    RGCategoryViewController *categoryVC = [[RGCategoryViewController alloc] init];
     self.categoryPopover = [[UIPopoverController alloc] initWithContentViewController:categoryVC];
    [self.categoryPopover presentPopoverFromBarButtonItem:self.categoryItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)districtClick
{
    RGDistrictViewController *districtVC = [[RGDistrictViewController alloc] init];
    if (self.selectedCityName) {
        RGCity *city = [[[RGMetaTool cities] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name = %@", self.selectedCityName]] firstObject];
        districtVC.regions = city.regions;
    }
    self.districtPopover = [[UIPopoverController alloc] initWithContentViewController:districtVC];
    districtVC.popover = self.districtPopover;
    [self.districtPopover presentPopoverFromBarButtonItem:self.districtItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)sortClick
{
    RGSortViewController *sortVC = [[RGSortViewController alloc] init];
    
    self.sortPopover = [[UIPopoverController alloc] initWithContentViewController:sortVC];
    [self.sortPopover presentPopoverFromBarButtonItem:self.sortItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)setupAwesomeMenu
{
    AwesomeMenuItem *startItem = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"icon_pathMenu_background_highlighted"] highlightedImage:nil ContentImage:[UIImage imageNamed:@"icon_pathMenu_mainMine_normal"] highlightedContentImage:nil];
    
    AwesomeMenuItem *item0 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"bg_pathMenu_black_normal"] highlightedImage:nil ContentImage:[UIImage imageNamed:@"icon_pathMenu_mine_normal"] highlightedContentImage:[UIImage imageNamed:@"icon_pathMenu_mine_highlighted"]];
    
    AwesomeMenuItem *item1 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"bg_pathMenu_black_normal"] highlightedImage:nil ContentImage:[UIImage imageNamed:@"icon_pathMenu_collect_normal"] highlightedContentImage:[UIImage imageNamed:@"icon_pathMenu_collect_highlighted"]];
    
    AwesomeMenuItem *item2 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"bg_pathMenu_black_normal"] highlightedImage:nil ContentImage:[UIImage imageNamed:@"icon_pathMenu_scan_normal"] highlightedContentImage:[UIImage imageNamed:@"icon_pathMenu_scan_highlighted"]];
    
    AwesomeMenuItem *item3 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"bg_pathMenu_black_normal"] highlightedImage:nil ContentImage:[UIImage imageNamed:@"icon_pathMenu_more_normal"] highlightedContentImage:[UIImage imageNamed:@"icon_pathMenu_more_highlighted"]];
    
    NSArray *items = @[item0, item1, item2, item3];
    
    AwesomeMenu *menu = [[AwesomeMenu alloc] initWithFrame:CGRectZero startItem:startItem optionMenus:items];
    [self.view addSubview:menu];
    menu.startPoint = CGPointMake(50, 150);
    menu.menuWholeAngle = M_PI_2;
    menu.rotateAddButton = NO;
    menu.alpha = 0.5;
    menu.delegate = self;
    [menu autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [menu autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    [menu autoSetDimensionsToSize:CGSizeMake(200, 200)];
}

#pragma mark - AwesomemenuDelegate
- (void)awesomeMenuWillAnimateOpen:(AwesomeMenu *)menu
{
    menu.contentImage = [UIImage imageNamed:@"icon_pathMenu_cross_normal"];
    menu.alpha = 1.0;
}

- (void)awesomeMenuWillAnimateClose:(AwesomeMenu *)menu
{
    menu.contentImage = [UIImage imageNamed:@"icon_pathMenu_mainMine_normal"];
    menu.alpha = 0.5;
}

- (void)awesomeMenu:(AwesomeMenu *)menu didSelectIndex:(NSInteger)idx
{
    if (idx == 0) {
        
    } else if (idx == 1) {
        RGNavigationController *nav = [[RGNavigationController alloc] initWithRootViewController:[[RGCollectViewController alloc] init]];
        
        [self presentViewController:nav animated:YES completion:nil];
    } else if (idx == 2) {
        RGNavigationController *nav = [[RGNavigationController alloc] initWithRootViewController:[[RGRecentViewController alloc] init]];
        
        [self presentViewController:nav animated:YES completion:nil];
    } else {
    
    }
    menu.contentImage = [UIImage imageNamed:@"icon_pathMenu_mainMine_normal"];
    menu.alpha = 0.5;
}

@end
