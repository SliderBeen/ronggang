//
//  RGSortViewController.m
//  火团
//
//  Created by qianfeng on 15/6/28.
//  Copyright (c) 2015年 ronggang. All rights reserved.
//

#import "RGSortViewController.h"
#import "RGConst.h"
#import "RGMetaTool.h"
#import "RGSort.h"
#import "UIView+Extension.h"

@interface RGSortButton : UIButton
@property (nonatomic, strong) RGSort *sort;
@end

@implementation RGSortButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [self setBackgroundImage:[UIImage imageNamed:@"btn_filter_normal"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"btn_filter_selected"] forState:UIControlStateHighlighted];

    }
    return self;
}

- (void)setSort:(RGSort *)sort
{
    _sort = sort;
    
    [self setTitle:sort.label forState:UIControlStateNormal];
}

@end

@interface RGSortViewController ()

@end

@implementation RGSortViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSArray *sorts = [RGMetaTool sorts];
    NSUInteger count = sorts.count;
    
    CGFloat btnW = 100;
    CGFloat btnH = 30;
    CGFloat btnX = 15;
    CGFloat btnY = 15;
    
    CGFloat margin = 15;
    CGFloat height = 0;
    
    for (int i = 0; i < count; i++) {
        RGSortButton *btn = [RGSortButton buttonWithType:UIButtonTypeCustom];
        btn.sort = sorts[i];
        btn.width = btnW;
        btn.height = btnH;
        btn.x = btnX;
        btn.y = btnY + (btnH + margin) * i;
        height = CGRectGetMaxY(btn.frame);
        [self.view addSubview:btn];
        
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    self.preferredContentSize = CGSizeMake(btnW + 2*btnX, height+margin);
}

- (void)btnClick:(RGSortButton *)btn
{
    [RGNotificationCenter postNotificationName:RGSortDidChangeNotification object:nil userInfo:@{RGSelectSort : btn.sort}];
}

@end
