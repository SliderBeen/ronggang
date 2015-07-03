//
//  RGMapViewController.m
//  火团
//
//  Created by qianfeng on 15/7/1.
//  Copyright (c) 2015年 ronggang. All rights reserved.
//

#import "RGMapViewController.h"
#import <MapKit/MapKit.h>
#import "UIBarButtonItem+Extension.h"
#import "DPAPI.h"
#import <CoreLocation/CoreLocation.h>
#import "MJExtension.h"
#import "RGDeal.h"
#import "RGBusiness.h"
#import "RGDealAnotation.h"
#import "RGMetaTool.h"
#import "RGCategory.h"
#import "RGConst.h"
#import "RGHomeTopItem.h"
#import "RGCategoryViewController.h"

@interface RGMapViewController ()<MKMapViewDelegate, DPRequestDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) CLGeocoder *coder;
@property (nonatomic, strong) CLLocationManager *clManager;
@property (nonatomic, copy) NSString *city;

@property (nonatomic, weak) UIBarButtonItem *categoryItem;
@property (nonatomic, copy) NSString *selectedCategoryName;
@property (nonatomic, strong) UIPopoverController *categoryPopover;

@property (nonatomic, strong) DPRequest *lastRequest;

@end

@implementation RGMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNav];
    
    self.mapView.delegate = self;
    self.clManager = [[CLLocationManager alloc] init];
   
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        
        if (![CLLocationManager locationServicesEnabled] || [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways) {
            [self.clManager requestAlwaysAuthorization];
        }
    }
    
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
    
    [RGNotificationCenter addObserver:self selector:@selector(categoryDidChange:) name:RGCategoryDidChangeNotification object:nil];
}


- (void)dealloc
{
    [RGNotificationCenter removeObserver:self];
}

- (CLGeocoder *)coder
{
    if (!_coder) {
        _coder = [[CLGeocoder alloc] init];
    }
    return _coder;
}

- (void)categoryDidChange:(NSNotification *)notification
{
    RGCategory *category = notification.userInfo[RGSelectCategory];
    NSString *subCategoryName = notification.userInfo[RGSelectSubCategoryName];
    RGHomeTopItem *topItem = (RGHomeTopItem *)self.categoryItem.customView;
    topItem.title = category.name;
    [topItem setIcon:category.icon highIcon:category.highlighted_icon];
    topItem.subTitle = subCategoryName;
    
    if (subCategoryName == nil || [subCategoryName isEqualToString:@"全部"]) {
        self.selectedCategoryName = category.name;
    } else {
        self.selectedCategoryName = subCategoryName;
    }
    
    if ([self.selectedCategoryName isEqualToString:@"全部分类"]) {
        self.selectedCategoryName = nil;
    }
    
    [self.categoryPopover dismissPopoverAnimated:YES];
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    [self mapView:self.mapView regionDidChangeAnimated:YES];
}

#pragma mark - MKMapViewDelegate
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKCoordinateRegion region = MKCoordinateRegionMake(userLocation.location.coordinate, MKCoordinateSpanMake(0.1, 0.1));
    [mapView setRegion:region animated:YES];
    [self.coder reverseGeocodeLocation:userLocation.location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error || placemarks.count == 0) {
            return;
        }
        CLPlacemark *pm = [placemarks firstObject];
        //NSLog(@"%@",pm.addressDictionary);
        
        self.city = pm.locality ? pm.locality : pm.addressDictionary[@"State"];
        //self.city = [self.city substringToIndex:self.city.length - 1];
        [self.city lowercaseString];
        [self mapView:self.mapView didUpdateUserLocation:userLocation];
    }];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (self.city == nil) {
        return;
    }
    
    DPAPI *api = [[DPAPI alloc] init];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"city"] = self.city;
    if (self.selectedCategoryName) {
        params[@"category"] = self.selectedCategoryName;
    }
    params[@"latitude"] = @(mapView.region.center.latitude);
    params[@"longitude"] = @(mapView.region.center.longitude);
    params[@"radius"] = @(5000);
    NSLog(@"%@",params);
    self.lastRequest = [api requestWithURL:@"v1/deal/find_deals" params:params delegate:self];

}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"%@",error);
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(RGDealAnotation *)annotation
{
    if (![annotation isKindOfClass:[RGDealAnotation class]]) {
        return nil;
    }
    
    static NSString *ID = @"deal";
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:ID];
    if (!annotationView) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:ID];
        annotationView.canShowCallout = YES;
    }
    annotationView.annotation = annotation;
    annotationView.image = [UIImage imageNamed:annotation.icon];
    return annotationView;
}

#pragma mark - 请求数据
- (void)request:(DPRequest *)request didFailWithError:(NSError *)error
{
    if (request != self.lastRequest) {
        return;
    }
    NSLog(@"%@",error);
}

- (void)request:(DPRequest *)request didFinishLoadingWithResult:(id)result
{
    if (request != self.lastRequest) {
        return;
    }
    NSLog(@"%@", result);
    NSArray *deals = [RGDeal objectArrayWithKeyValuesArray:result[@"deals"]];
    
    for (RGDeal *deal in deals) {
        RGCategory *category = [RGMetaTool categoryWithDeal:deal];
        for (RGBusiness *business in deal.businesses) {
            RGDealAnotation *anno = [[RGDealAnotation alloc] init];
            
            anno.coordinate = CLLocationCoordinate2DMake(business.latitude, business.longitude);
            anno.title = business.name;
            anno.subtitle = deal.title;
            anno.icon = category.map_icon;
            if ([self.mapView.annotations containsObject:anno]) {
                break;
            }
            
            [self.mapView addAnnotation:anno];
        }
    }
}


#pragma mark - setupNav
- (void)setupNav
{
    self.title = @"地图";
    UIBarButtonItem *backItem = [UIBarButtonItem itemWithTarget:self action:@selector(back) image:@"icon_back" highImage:@"icon_back_highlighted"];
    
    RGHomeTopItem *categoryTopItem = [RGHomeTopItem item];
    UIBarButtonItem *categoryItem = [[UIBarButtonItem alloc] initWithCustomView:categoryTopItem];
    [categoryTopItem addTarget:self action:@selector(categoryClick)];
    self.categoryItem = categoryItem;
    self.navigationItem.leftBarButtonItems = @[backItem, categoryItem];
}

#pragma mark - dropDownButtonClick
- (void)categoryClick
{
    RGCategoryViewController *categoryVC = [[RGCategoryViewController alloc] init];
    self.categoryPopover = [[UIPopoverController alloc] initWithContentViewController:categoryVC];
    [self.categoryPopover presentPopoverFromBarButtonItem:self.categoryItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}
- (IBAction)locationButton {
    [self mapView:self.mapView didUpdateUserLocation:self.mapView.userLocation];
}

#pragma mark - back
- (void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
