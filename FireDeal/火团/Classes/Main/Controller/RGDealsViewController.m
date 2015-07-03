//
//  RGDealsViewController.m
//  火团
//
//  Created by qianfeng on 15/6/29.
//  Copyright (c) 2015年 ronggang. All rights reserved.
//

#import "RGDealsViewController.h"
#import "RGConst.h"
#import "DPAPI.h"
#import "RGDeal.h"
#import "RGDealCell.h"
#import "MJExtension.h"
#import "MJRefresh.h"
#import "MBProgressHUD+MJ.h"
#import "UIView+AutoLayout.h"
#import "UIView+Extension.h"
#import "RGDetailViewController.h"

@interface RGDealsViewController ()<DPRequestDelegate>

@property (nonatomic, strong) NSMutableArray *deals;
@property (nonatomic, assign) int currentPage;
@property (nonatomic, strong) DPRequest *lastRequest;
@property (nonatomic, assign) int totalCount;
@property (nonatomic, strong) UIImageView *noDataView;

@end

@implementation RGDealsViewController


static NSString * const reuseIdentifier = @"deal";

- (instancetype)init
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(305, 305);
    return [self initWithCollectionViewLayout:layout];
}

- (NSMutableArray *)deals
{
    if (!_deals) {
        _deals = [NSMutableArray array];
    }
    return _deals;
}

- (UIImageView *)noDataView
{
    if (!_noDataView) {
        _noDataView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_deals_empty"]];
        [self.view addSubview:_noDataView];
        [_noDataView autoCenterInSuperview];
    }
    return _noDataView;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    int cols = (size.width == 1024) ? 3 : 2;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    CGFloat inset = (size.width - cols * layout.itemSize.width)/(cols+1);
    layout.sectionInset = UIEdgeInsetsMake(inset, inset, inset, inset);
    layout.minimumLineSpacing = inset;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.backgroundColor = RGGlobalBg;
    
    // Register cell classes
    [self.collectionView registerNib:[UINib nibWithNibName:@"RGDealCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    
    self.collectionView.alwaysBounceVertical = YES;
    
    [self.collectionView addHeaderWithTarget:self action:@selector(loadNewDeals)];
    [self.collectionView addFooterWithTarget:self action:@selector(loadMoreDeals)];
}


#pragma mark - 请求数据
- (void)loadDeals
{
    DPAPI *api = [[DPAPI alloc] init];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [self setupParams:params];
    params[@"page"] = @(self.currentPage);
    self.lastRequest = [api requestWithURL:@"v1/deal/find_deals" params:params delegate:self];
}

- (void)loadMoreDeals
{
    self.currentPage++;
    [self loadDeals];
}

- (void)loadNewDeals
{
    self.currentPage = 1;
    [self loadDeals];
}

#pragma mark - DPDelegate
- (void)request:(DPRequest *)request didFinishLoadingWithResult:(id)result
{
    if (self.lastRequest != request) {
        return;
    }
    self.totalCount = [result[@"total_count"] intValue];
    if (self.currentPage == 1) {
        [self.deals removeAllObjects];
    }
    NSArray *newDeals = [RGDeal objectArrayWithKeyValuesArray:result[@"deals"]];
    [self.deals addObjectsFromArray:newDeals];
    [self.collectionView reloadData];
    [self.collectionView headerEndRefreshing];
    [self.collectionView footerEndRefreshing];
    
    //NSLog(@"%@",result);
}

- (void)request:(DPRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"%@",error);
    if (self.lastRequest != request) {
        return;
    }
    if (self.currentPage > 1) {
        self.currentPage--;
    }
    [MBProgressHUD showError:@"网络繁忙, 请稍候再试" toView:self.view];
    [self.collectionView headerEndRefreshing];
    [self.collectionView footerEndRefreshing];
}



#pragma mark <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    self.collectionView.footerHidden = (self.totalCount == self.deals.count);
    self.noDataView.hidden = self.deals.count != 0;
    [self viewWillTransitionToSize:CGSizeMake(collectionView.width, 0) withTransitionCoordinator:nil];
    return self.deals.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RGDealCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.deal = self.deals[indexPath.item];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    RGDetailViewController *detailVC = [[RGDetailViewController alloc] init];
    detailVC.deal = self.deals[indexPath.item];
    [self presentViewController:detailVC animated:YES completion:nil];
}

@end
