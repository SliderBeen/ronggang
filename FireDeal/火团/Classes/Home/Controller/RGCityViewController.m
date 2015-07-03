//
//  RGCityViewController.m
//  火团
//
//  Created by qianfeng on 15/6/27.
//  Copyright (c) 2015年 ronggang. All rights reserved.
//

#import "RGCityViewController.h"
#import "UIBarButtonItem+Extension.h"
#import "MJExtension.h"
#import "RGCityGroup.h"
#import "RGConst.h"
#import "UIView+AutoLayout.h"
#import "RGCitySearchResultViewController.h"


@interface RGCityViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) NSArray *cityGroups;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *cover;

@property (nonatomic, weak) RGCitySearchResultViewController *citySearchResultVC;

- (IBAction)coverClick:(UIButton *)sender;

@end

@implementation RGCityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"切换城市";
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(close) image:@"btn_navigation_close" highImage:@"btn_navigation_close_hl"];
    self.cityGroups = [RGCityGroup objectArrayWithFilename:@"cityGroups.plist"];
    self.tableView.sectionIndexColor = [UIColor grayColor];
    self.searchBar.tintColor = RGColor(25, 176, 148);
}

- (RGCitySearchResultViewController *)citySearchResultVC
{
    if (!_citySearchResultVC) {
        RGCitySearchResultViewController *citySearchResultVC = [[RGCitySearchResultViewController alloc] init];
        [self addChildViewController:citySearchResultVC];
        self.citySearchResultVC = citySearchResultVC;
        
        [self.view addSubview:citySearchResultVC.view];
        [citySearchResultVC.view autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
        [citySearchResultVC.view autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.searchBar withOffset:15];
    }
    return _citySearchResultVC;
}

- (void)close
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 数据源方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.cityGroups.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    RGCityGroup *group = self.cityGroups[section];
    return group.cities.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    RGCityGroup *group = self.cityGroups[indexPath.section];
    cell.textLabel.text = group.cities[indexPath.row];
    return cell;
}

#pragma mark - 代理方法
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    RGCityGroup *group = self.cityGroups[section];
    return group.title;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [self.cityGroups valueForKeyPath:@"title"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RGCityGroup *group = self.cityGroups[indexPath.section];
    [RGNotificationCenter postNotificationName:RGCityDidChangeNotification object:nil userInfo:@{RGSelectCityName : group.cities[indexPath.row]}];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UISearchBar Delegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.navigationController.navigationBarHidden = YES;
   
    [searchBar setBackgroundImage:[UIImage imageNamed:@"bg_login_textfield_hl"]];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.cover.alpha = 0.5;
    }];
    
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    self.navigationController.navigationBarHidden = NO;
  
    [searchBar setBackgroundImage:[UIImage imageNamed:@"bg_login_textfield"]];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.cover.alpha = 0;
    }];
    
    [searchBar setShowsCancelButton:NO animated:YES];
    
    searchBar.text = nil;
    self.citySearchResultVC.view.hidden = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length) {
        self.citySearchResultVC.view.hidden = NO;
        self.citySearchResultVC.searchText = searchText;
    } else {
        self.citySearchResultVC.view.hidden = YES;
    }
}

- (IBAction)coverClick:(UIButton *)sender {
    [self.searchBar resignFirstResponder];
}
@end
