//
//  RGDealCell.m
//  火团
//
//  Created by qianfeng on 15/6/29.
//  Copyright (c) 2015年 ronggang. All rights reserved.
//

#import "RGDealCell.h"
#import "RGDeal.h"
#import "UIImageView+WebCache.h"

@interface RGDealCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *listPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *purchaseCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *dealNewView;
- (IBAction)cover:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIImageView *checkView;
@property (weak, nonatomic) IBOutlet UIButton *coverButton;

@end

@implementation RGDealCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setDeal:(RGDeal *)deal
{
    _deal = deal;
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:deal.image_url] placeholderImage:[UIImage imageNamed:@"placeholder_deal"]];
    
    self.titleLabel.text = deal.title;
    self.descLabel.text = deal.desc;
    
    self.purchaseCountLabel.text = [NSString stringWithFormat:@"已售%d",deal.purchase_count];
    self.currentPriceLabel.text = [NSString stringWithFormat:@"¥ %@",deal.current_price];
    NSUInteger dotLoc = [self.currentPriceLabel.text rangeOfString:@"."].location;
    if (dotLoc != NSNotFound) {
        if (self.currentPriceLabel.text.length - dotLoc > 3) {
            self.currentPriceLabel.text = [self.currentPriceLabel.text substringToIndex:dotLoc+3];
        }
    }
    
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd";
    self.dealNewView.hidden = ([deal.publish_date compare:[fmt stringFromDate:[NSDate date]]] == NSOrderedAscending);
    
    self.listPriceLabel.text = [NSString stringWithFormat:@"¥ %@", deal.list_price];
    
    self.coverButton.hidden = !deal.isEditing;
    self.checkView.hidden = !deal.isChecked;
}

- (void)drawRect:(CGRect)rect
{
    [[UIImage imageNamed:@"bg_dealcell"] drawInRect:rect];
}

- (IBAction)cover:(UIButton *)sender {
    self.checkView.hidden = !self.checkView.hidden;
    self.deal.checked = !self.deal.isChecked;
    if ([self.delegate respondsToSelector:@selector(dealCellCheckStateChange:)]) {
        [self.delegate dealCellCheckStateChange:self];
    }
}
@end
