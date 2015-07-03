//
//  RGSearchViewController.m
//  火团
//
//  Created by qianfeng on 15/6/29.
//  Copyright (c) 2015年 ronggang. All rights reserved.
//

#import "RGSearchViewController.h"
#import "UIBarButtonItem+Extension.h"
#import "UIView+Extension.h"
#import "UIView+AutoLayout.h"
#import "RGConst.h"
#import "MJRefresh.h"

@interface RGSearchViewController ()<UISearchBarDelegate>

@property (nonatomic, weak) UISearchBar *searchBar;




@end

@implementation RGSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNav];
    
}

- (void)setupParams:(NSMutableDictionary *)params
{
    params[@"city"] = self.selectedCityName;
    params[@"keyword"] = self.searchBar.text;
}

#pragma mark - setupNav
- (void)setupNav
{
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(back) image:@"icon_back" highImage:@"icon_back_highlighted"];
    
    UIView *titleView = [[UIView alloc] init];
    titleView.width = 300;
    titleView.height = 35;
    self.navigationItem.titleView = titleView;
    
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    [titleView addSubview:searchBar];
    searchBar.backgroundImage = [UIImage imageNamed:@"bg_login_textfield"];
    searchBar.placeholder = @"请输入关键词";
    [searchBar autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    searchBar.delegate = self;
    self.searchBar = searchBar;
}

#pragma mark - back
- (void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - searchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.collectionView headerBeginRefreshing];
    [searchBar resignFirstResponder];
}


@end
