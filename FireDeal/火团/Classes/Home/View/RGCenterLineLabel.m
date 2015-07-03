//
//  RGCenterLineLabel.m
//  火团
//
//  Created by qianfeng on 15/6/29.
//  Copyright (c) 2015年 ronggang. All rights reserved.
//

#import "RGCenterLineLabel.h"

@implementation RGCenterLineLabel


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    CGContextMoveToPoint(ctx, 0, rect.size.height * 0.5);
//    CGContextAddLineToPoint(ctx, rect.size.width, rect.size.height * 0.5);
//    CGContextStrokePath(ctx);
//    NSLog(@"%@",NSStringFromCGRect(rect));
    UIRectFill(CGRectMake(0, rect.size.height * 0.5, rect.size.width, 0.5));
}


@end
