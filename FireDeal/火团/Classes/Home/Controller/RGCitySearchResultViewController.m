//
//  RGCitySearchResultViewController.m
//  火团
//
//  Created by qianfeng on 15/6/27.
//  Copyright (c) 2015年 ronggang. All rights reserved.
//

#import "RGCitySearchResultViewController.h"
#import "MJExtension.h"
#import "RGCity.h"
#import "RGConst.h"
#import "RGMetaTool.h"

@interface RGCitySearchResultViewController ()

@property (nonatomic, strong) NSArray *searchResults;

@end

@implementation RGCitySearchResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

}


- (void)setSearchText:(NSString *)searchText
{
    _searchText = [searchText copy];
    
    searchText = searchText.lowercaseString;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains %@ or pinYin contains %@ or pinYinHead contains %@", searchText, searchText, searchText];
    self.searchResults = [[RGMetaTool cities] filteredArrayUsingPredicate:predicate];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResults.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    RGCity *city = self.searchResults[indexPath.row];
    cell.textLabel.text = city.name;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"共有%d个搜索结果", self.searchResults.count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RGCity *city = self.searchResults[indexPath.row];
    [RGNotificationCenter postNotificationName:RGCityDidChangeNotification object:nil userInfo:@{RGSelectCityName : city.name}];
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
