//
//  RGDealCell.h
//  火团
//
//  Created by qianfeng on 15/6/29.
//  Copyright (c) 2015年 ronggang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RGDeal, RGDealCell;

@protocol RGDealCellDelegate <NSObject>

@optional
- (void)dealCellCheckStateChange:(RGDealCell *)cell;

@end

@interface RGDealCell : UICollectionViewCell

@property (nonatomic, strong) RGDeal *deal;
@property (nonatomic, weak) id<RGDealCellDelegate> delegate;

@end
