//
//  RGCollectViewController.m
//  火团
//
//  Created by qianfeng on 15/6/30.
//  Copyright (c) 2015年 ronggang. All rights reserved.
//

#import "RGCollectViewController.h"
#import "UIBarButtonItem+Extension.h"
#import "RGDealTool.h"
#import "RGDeal.h"
#import "UIView+AutoLayout.h"
#import "RGConst.h"
#import "MJExtension.h"
#import "UIView+Extension.h"
#import "RGDealCell.h"
#import "RGDetailViewController.h"
#import "MJRefresh.h"

NSString *const RGDone = @"完成";
NSString *const RGEdit = @"编辑";

#define RGString(str) [NSString stringWithFormat:@"  %@  ", str]

@interface RGCollectViewController ()<RGDealCellDelegate>

@property (nonatomic, strong) NSMutableArray *deals;
@property (nonatomic, strong) UIImageView *noDataView;
@property (nonatomic, assign) int currentPage;

@property (nonatomic, strong) UIBarButtonItem *backItem;
@property (nonatomic, strong) UIBarButtonItem *editItem;
@property (nonatomic, strong) UIBarButtonItem *selectAllItem;
@property (nonatomic, strong) UIBarButtonItem *unselectAllItem;
@property (nonatomic, strong) UIBarButtonItem *removeItem;

@end

@implementation RGCollectViewController

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
        _noDataView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_collects_empty"]];
        [self.view addSubview:_noDataView];
        [_noDataView autoCenterInSuperview];
    }
    return _noDataView;
}

- (UIBarButtonItem *)backItem
{
    if (!_backItem) {
        _backItem = [UIBarButtonItem itemWithTarget:self action:@selector(back) image:@"icon_back" highImage:@"icon_back_highlighted"];
    }
    return _backItem;
}

- (UIBarButtonItem *)editItem
{
    if (!_editItem) {
        _editItem = [[UIBarButtonItem alloc] initWithTitle:RGEdit style:UIBarButtonItemStyleDone target:self action:@selector(edit:)];
        _editItem.enabled = ([RGDealTool collectDealsCount] != 0);
    }
    return _editItem;
}

- (UIBarButtonItem *)selectAllItem
{
    if (!_selectAllItem) {
        _selectAllItem = [[UIBarButtonItem alloc] initWithTitle:RGString(@"全选") style:UIBarButtonItemStyleDone target:self action:@selector(selectAll)];
    }
    return _selectAllItem;
}

- (UIBarButtonItem *)unselectAllItem
{
    if (!_unselectAllItem) {
        _unselectAllItem = [[UIBarButtonItem alloc] initWithTitle:RGString(@"全不选") style:UIBarButtonItemStyleDone target:self action:@selector(unselectAll)];
    }
    return _unselectAllItem;
}

- (UIBarButtonItem *)removeItem
{
    if (!_removeItem) {
        _removeItem = [[UIBarButtonItem alloc] initWithTitle:RGString(@"删除") style:UIBarButtonItemStyleDone target:self action:@selector(remove)];
        _removeItem.enabled = NO;
    }
    return _removeItem;
}

- (void)selectAll
{
    for (RGDeal *deal in self.deals) {
        deal.checked = YES;
    }
    self.removeItem.enabled = YES;
    self.removeItem.title = [NSString stringWithFormat:@"删除(%d)",self.deals.count];
    [self.collectionView reloadData];
}

- (void)unselectAll
{
    for (RGDeal *deal in self.deals) {
        deal.checked = NO;
    }
    self.removeItem.enabled = NO;
    self.removeItem.title = @"删除";
    [self.collectionView reloadData];
}

- (void)remove
{
    NSMutableArray *tempArr = [NSMutableArray array];
    for (RGDeal *deal in self.deals) {
        if (deal.checked) {
            [tempArr addObject:deal];
            [RGDealTool removeCollectDeal:deal];
        }
    }
    self.removeItem.enabled = NO;
    [self.deals removeObjectsInArray:tempArr];
    self.removeItem.title = @"删除";
    [self.collectionView reloadData];
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
    
    self.title = @"我的收藏";
    
    [self setupNav];
    
    self.collectionView.backgroundColor = RGGlobalBg;
    
    // Register cell classes
    [self.collectionView registerNib:[UINib nibWithNibName:@"RGDealCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    
    self.collectionView.alwaysBounceVertical = YES;
    
    [self loadMoreDeals];
    
    [RGNotificationCenter addObserver:self selector:@selector(collectDidChange:) name:RGCollectDidChangeNotification object:nil];
    
    [self.collectionView addFooterWithTarget:self action:@selector(loadMoreDeals)];
}

#pragma mark - loadMoreDeals
- (void)loadMoreDeals
{
    self.currentPage++;
    [self.deals addObjectsFromArray:[RGDealTool collectDeals:self.currentPage]];
    [self.collectionView reloadData];
    [self.collectionView footerEndRefreshing];
}

- (void)dealloc
{
    [RGNotificationCenter removeObserver:self];
}

#pragma mark - collectDidChange
- (void)collectDidChange:(NSNotification *)notification
{
//    RGDeal *deal = notification.userInfo[RGCollectDealKey];
//    if ([notification.userInfo[RGIsCollectedKey] boolValue]) {
//        [self.deals insertObject:deal atIndex:0];
//    } else {
//        [self.deals removeObject:deal];
//    }
//    [self.collectionView reloadData];
    self.currentPage = 0;
    [self.deals removeAllObjects];
    [self loadMoreDeals];
}

#pragma mark - setupNav
- (void)setupNav
{
    self.navigationItem.leftBarButtonItems = @[self.backItem];
    
    self.navigationItem.rightBarButtonItem = self.editItem;
}

#pragma mark - edit
- (void)edit:(UIBarButtonItem *)item
{
    if ([item.title isEqualToString:RGEdit]) {
        item.title = RGDone;
        self.navigationItem.leftBarButtonItems = @[self.backItem, self.selectAllItem, self.unselectAllItem, self.removeItem];
        
        for (RGDeal *deal in self.deals) {
            deal.editing = YES;
        }
        
    } else {
        item.title = RGEdit;
        self.navigationItem.leftBarButtonItems = @[self.backItem];
        
        for (RGDeal *deal in self.deals) {
            deal.editing = NO;
            deal.checked = NO;
        }
        self.removeItem.enabled = NO;
        self.editItem.enabled = ([RGDealTool collectDealsCount] != 0);
    }
    [self.collectionView reloadData];
}

#pragma mark - back
- (void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    self.collectionView.footerHidden = ([RGDealTool collectDealsCount] == self.deals.count);
    self.noDataView.hidden = self.deals.count != 0;
    [self viewWillTransitionToSize:CGSizeMake(collectionView.width, 0) withTransitionCoordinator:nil];
    return self.deals.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RGDealCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.deal = self.deals[indexPath.item];
    cell.delegate = self;
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    RGDetailViewController *detailVC = [[RGDetailViewController alloc] init];
    detailVC.deal = self.deals[indexPath.item];
    [self presentViewController:detailVC animated:YES completion:nil];
}

#pragma mark - RGDealCellDelegate
- (void)dealCellCheckStateChange:(RGDealCell *)cell
{
    BOOL isChecked = NO;
    int num = 0;
    for (RGDeal *deal in self.deals) {
        if (deal.checked) {
            isChecked = YES;
            num++;
        }
    }
    if (num) {
        self.removeItem.title = [NSString stringWithFormat:@"删除(%d)",num];
    } else {
        self.removeItem.title = @"删除";
    }
    self.removeItem.enabled = isChecked;
}

@end
