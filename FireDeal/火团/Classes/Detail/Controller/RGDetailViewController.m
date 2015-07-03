//
//  RGDetailViewController.m
//  火团
//
//  Created by qianfeng on 15/6/30.
//  Copyright (c) 2015年 ronggang. All rights reserved.
//

#import "RGDetailViewController.h"
#import "RGDeal.h"
#import "RGConst.h"
#import "UIImageView+WebCache.h"
#import "RGCenterLineLabel.h"
#import "DPAPI.h"
#import "MBProgressHUD+MJ.h"
#import "MJExtension.h"
#import "RGRestrictions.h"
#import "RGDealTool.h"
//#import "AlixLibService.h"
//#import "AlixPayOrder.h"
//#import "PartnerConfig.h"
//#import "DataSigner.h"
#import "UMSocial.h"

@interface RGDetailViewController ()<UIWebViewDelegate, DPRequestDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
@property (nonatomic, copy) NSString *str;
@property (nonatomic, copy) NSString *ID;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
- (IBAction)buy:(UIButton *)sender;
- (IBAction)collect:(UIButton *)sender;
- (IBAction)share:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet RGCenterLineLabel *listPriceLabel;
- (IBAction)back;
@property (weak, nonatomic) IBOutlet UIButton *refundableAnyTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *refundableExpireButton;
@property (weak, nonatomic) IBOutlet UIButton *deadTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *purchaseCountButton;
@property (weak, nonatomic) IBOutlet UIButton *collectButton;

@end

@implementation RGDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGGlobalBg;
   self.ID = [self.deal.deal_id substringFromIndex:[self.deal.deal_id rangeOfString:@"-"].location + 1];
    self.str = [NSString stringWithFormat:@"http://m.dianping.com/tuan/deal/%@",self.ID];
    
    self.titleLabel.text = self.deal.title;
    self.descLabel.text = self.deal.desc;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:self.deal.image_url] placeholderImage:[UIImage imageNamed:@"placeholder_deal"]];
    
    self.priceLabel.text = [NSString stringWithFormat:@"¥ %@",self.deal.current_price];
    NSUInteger dotLoc = [self.priceLabel.text rangeOfString:@"."].location;
    if (dotLoc != NSNotFound) {
        if (self.priceLabel.text.length - dotLoc > 3) {
            self.priceLabel.text = [self.priceLabel.text substringToIndex:dotLoc+3];
        }
    }
    self.listPriceLabel.text = [NSString stringWithFormat:@"门店价￥ %@",self.deal.list_price];
    
    [self.purchaseCountButton setTitle:[NSString stringWithFormat:@"已售出%d",self.deal.purchase_count] forState:UIControlStateNormal];
    
    //self.deal.purchase_deadline
    
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd";
    NSDate *deadDate = [fmt dateFromString:self.deal.purchase_deadline];
    deadDate = [deadDate dateByAddingTimeInterval:24 * 60 *60];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unit = NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitDay;
    NSDateComponents *comp = [calendar components:unit fromDate:[NSDate date] toDate:deadDate options:0];
    
    if (comp.day > 365) {
        [self.deadTimeButton setTitle:@"一年内不过期" forState:UIControlStateNormal];
    } else {
    
        [self.deadTimeButton setTitle:[NSString stringWithFormat:@"%d天%d小时%d分钟",comp.day,comp.hour,comp.minute] forState:UIControlStateNormal];
    }
    
    [self loadDeals];
    
    self.webView.hidden = YES;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.str]]];
    
    
    self.collectButton.selected = [RGDealTool isCollected:self.deal];
}

#pragma mark - 请求数据
- (void)loadDeals
{
    DPAPI *api = [[DPAPI alloc] init];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    params[@"deal_id"] = self.deal.deal_id;
    
    [api requestWithURL:@"v1/deal/get_single_deal" params:params delegate:self];
}


#pragma mark - DPDelegate
- (void)request:(DPRequest *)request didFinishLoadingWithResult:(id)result
{
    //NSLog(@"%@",result);
    self.deal = [RGDeal objectWithKeyValues:[result[@"deals"] firstObject]];
    
    self.refundableAnyTimeButton.selected = self.deal.restrictions.is_refundable;
    self.refundableExpireButton.selected = self.deal.restrictions.is_refundable;
}

- (void)request:(DPRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"%@",error);

    [MBProgressHUD showError:@"网络繁忙, 请稍候再试" toView:self.view];
   
}

#pragma mark - webView delegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if ([self.str isEqualToString:webView.request.URL.absoluteString]) {
        NSString *urlStr = [NSString stringWithFormat:@"http://m.dianping.com/tuan/deal/moreinfo/%@",self.ID];
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
        
    } else {
        
        //NSString *html = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('html')[0].outerHTML"];
        
        //NSLog(@"%@",html);
        //[html writeToFile:@"/Users/qianfeng/desktop/js.html" atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        NSMutableString *js = [NSMutableString string];
        
        [js appendString:@"var header = document.getElementsByTagName('header')[0];"];
        [js appendString:@"header.parentNode.removeChild(header);"];
        
        [js appendString:@"var box = document.getElementsByClassName('cost-box')[0];"];
        [js appendString:@"box.parentNode.removeChild(box);"];
        
        [js appendString:@"var buyNow = document.getElementsByClassName('buy-now')[0];"];
        [js appendString:@"buyNow.parentNode.removeChild(buyNow);"];
        
        [js appendString:@"var footerBox = document.getElementsByClassName('footer')[0];footerBox.parentNode.removeChild(footerBox);"];
        
        [webView stringByEvaluatingJavaScriptFromString:js];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            self.webView.hidden = NO;
            [self.loadingView stopAnimating];
        });
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

#pragma mark - 集成支付宝
- (IBAction)buy:(UIButton *)sender {
//    // 1.生成订单信息
//    AlixPayOrder *order = [[AlixPayOrder alloc] init];
//    order.productName = self.deal.title;
//    order.productDescription = self.deal.desc;
//    order.amount = [self.deal.current_price description];
//    order.partner = PartnerID;
//    order.seller = SellerID;
//    
//    // 2.签名加密
//    id<DataSigner> singer = CreateRSADataSigner(PartnerPrivKey);
//    // 签名信息 == signedString
//    NSString *signedString = [singer signString:[order description]];
//    
//    // 3.利用订单信息、签名信息、签名类型生成一个订单字符串
//    NSString *orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
//                             [order description], signedString, @"RSA"];
//    
//    // 4.打开客户端,进行支付(商品名称,商品价格,商户信息)
//    [AlixLibService payOrder:orderString AndScheme:@"huotuan" seletor:nil target:nil];
}

- (IBAction)collect:(UIButton *)sender {
    
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    if (sender.selected) {
        [RGDealTool removeCollectDeal:self.deal];
        [MBProgressHUD showSuccess:@"取消收藏成功" toView:self.view];
        info[RGIsCollectedKey] = @(NO);
    } else {
        [RGDealTool addCollectDeal:self.deal];
        [MBProgressHUD showSuccess:@"收藏成功" toView:self.view];
        info[RGIsCollectedKey] = @(YES);
    }
    info[RGCollectDealKey] = self.deal;
    [RGNotificationCenter postNotificationName:RGCollectDidChangeNotification object:nil userInfo:info];
    sender.selected = !sender.selected;
}

- (IBAction)share:(UIButton *)sender {
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:nil
                                      shareText:self.deal.desc
                                     shareImage:[UIImage imageNamed:self.deal.s_image_url]
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToTencent,UMShareToRenren,nil]
                                       delegate:nil];
}
- (IBAction)back {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
