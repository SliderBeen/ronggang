//
//  RGDropDown.m
//  火团
//
//  Created by qianfeng on 15/6/27.
//  Copyright (c) 2015年 ronggang. All rights reserved.
//

#import "RGDropDown.h"

@interface RGDropDown ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (weak, nonatomic) IBOutlet UITableView *subTableView;
@property (nonatomic, assign) NSInteger selectedRow;

@end

@implementation RGDropDown

+ (instancetype)dropDown
{
    return [[[NSBundle mainBundle] loadNibNamed:@"RGDropDown" owner:nil options:nil] lastObject];
}

- (void)awakeFromNib
{
    self.autoresizingMask = UIViewAutoresizingNone;
}


#pragma mark - tableView dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.mainTableView) {
        
        return [self.dataSource numberOfRowsInMainTable:self];
    } else {
        return [self.dataSource dropDown:self subdataForRowInMainTable:self.selectedRow].count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (tableView == self.mainTableView) {
        static NSString *ID = @"main";
        cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_dropdown_leftpart"]];
            cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_dropdown_left_selected"]];
        }
        cell.textLabel.text = [self.dataSource dropDown:self titleForRowInMainTable:indexPath.row];
        if ([self.dataSource respondsToSelector:@selector(dropDown:iconForRowInMainTable:)] && [self.dataSource respondsToSelector:@selector(dropDown:selectedIconForRowInMainTable:)]) {
            cell.imageView.image = [UIImage imageNamed:[self.dataSource dropDown:self iconForRowInMainTable:indexPath.row]];
            cell.imageView.highlightedImage = [UIImage imageNamed:[self.dataSource dropDown:self selectedIconForRowInMainTable:indexPath.row]];
        }
        NSArray *subdata = [self.dataSource dropDown:self subdataForRowInMainTable:indexPath.row];
        if (subdata.count) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }

    } else {
        static NSString *ID = @"sub";
        cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_dropdown_rightpart"]];
            cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_dropdown_right_selected"]];
        }
        NSArray *subdata = [self.dataSource dropDown:self subdataForRowInMainTable:self.selectedRow];
        cell.textLabel.text = subdata[indexPath.row];
    }
        return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.mainTableView) {
        self.selectedRow = indexPath.row;
        [self.subTableView reloadData];
        
        if ([self.delegate respondsToSelector:@selector(dropDown:didSelectRowInMainTable:)]) {
            [self.delegate dropDown:self didSelectRowInMainTable:indexPath.row];
        }
        
    } else {
        if ([self.delegate respondsToSelector:@selector(dropDown:didSelectRowInSubTable:inMainTable:)]) {
            [self.delegate dropDown:self didSelectRowInSubTable:indexPath.row inMainTable:self.selectedRow];
        }
    }
}

@end
