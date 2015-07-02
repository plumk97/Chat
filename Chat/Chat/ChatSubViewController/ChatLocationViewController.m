//
//  ChatLocationViewController.m
//  Chat
//
//  Created by 货道网 on 15/5/19.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import "ChatLocationViewController.h"
#import "ChatViewController.h"

@interface MyAnnotation : NSObject
<MKAnnotation>

@property (nonatomic,retain)NSString *title2;
@property (nonatomic,retain)NSString *subtitle2;
@property (nonatomic,assign)CLLocationCoordinate2D coordinate;

- (id)initWithTitle:(NSString*)title SubTitle:(NSString*)subtitle Coordinate:(CLLocationCoordinate2D)coordinate;

@end
@implementation MyAnnotation

- (id)initWithTitle:(NSString*)title SubTitle:(NSString*)subtitle Coordinate:(CLLocationCoordinate2D)coordinate
{
    if (self = [super init]) {
        self.title2 = title;
        self.subtitle2 = subtitle;
        self.coordinate = coordinate;
    }
    return self;
}

- (NSString *)title
{
    return _title2;
}
- (NSString *)subtitle
{
    return _subtitle2;
}
- (CLLocationCoordinate2D)coordinate
{
    return _coordinate;
}

@end

@implementation ChatLocationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    
    _mapView.showsBuildings = YES;
    
    [self.view addSubview:_mapView];
    
    
    locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 20)];
    locationLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    locationLabel.font = [UIFont systemFontOfSize:13];
    locationLabel.textColor = [UIColor whiteColor];
    locationLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:locationLabel];
    
    
    if (!_message) {
        _mapView.delegate = self;
        _mapView.showsUserLocation = YES;
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    } else {
        
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [_message.latitude floatValue];
        coordinate.longitude = [_message.longitude floatValue];
        [_mapView setRegion:MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(0.005, 0.005)) animated:YES];
        locationLabel.text = _message.locationName;
        MyAnnotation * annotation = [[MyAnnotation alloc] initWithTitle:@"" SubTitle:@"" Coordinate:coordinate];
        [_mapView removeAnnotations:_mapView.annotations];
        [_mapView addAnnotation:annotation];
        [_mapView selectAnnotation:annotation animated:YES];
    }
    
    
    self.title = @"定位";
}

- (void)dealloc
{
    NSArray * views = [self.view subviews];
    for (UIView * v in views) {
        [v removeFromSuperview];
    }
}

- (void)sendLocation:(UIBarButtonItem *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatLocation:Name:Longitude:Latitude:)]) {
        [self.delegate chatLocation:self Name:locationLabel.text Longitude:currentCorrdinate.longitude Latitude:currentCorrdinate.latitude];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

// MARK: - MKMapView Delegate
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocatio
{
    
    mapView.showsUserLocation = NO;
    [mapView setRegion:MKCoordinateRegionMake(userLocatio.location.coordinate, MKCoordinateSpanMake(0.005, 0.005)) animated:YES];
    currentCorrdinate = userLocatio.location.coordinate;
    // 获取当前所在的城市名
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    //根据经纬度反向地理编译出地址信息
    [geocoder reverseGeocodeLocation:userLocatio.location completionHandler:^(NSArray *array, NSError *error)
     {
         
         if (array.count > 0)
         {
             CLPlacemark *placemark = [array objectAtIndex:0];
             
             NSMutableString * mStr = [[NSMutableString alloc] initWithString:placemark.name];
             NSRange range = [mStr rangeOfString:placemark.country];
             if (range.length > 0)
             {
                 [mStr deleteCharactersInRange:range];
             }
             locationLabel.text = mStr;
             MyAnnotation * annotation = [[MyAnnotation alloc] initWithTitle:@"" SubTitle:@"" Coordinate:userLocatio.location.coordinate];
             [mapView removeAnnotations:mapView.annotations];
             [mapView addAnnotation:annotation];
             [mapView selectAnnotation:annotation animated:YES];
             self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(sendLocation:)];
         }
         
     }];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
//    [mapView removeFromSuperview];
//    [self.view addSubview:mapView];
    if (animated || mapView.showsUserLocation) {
        return;
        
    }
    CGPoint point = CGPointMake(self.view.center.x, self.view.center.y);
    CLLocationCoordinate2D coordinate = [mapView convertPoint:point toCoordinateFromView:mapView];
    
    currentCorrdinate = coordinate;
    CLLocation * location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];

    // 获取当前所在的城市名
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    //根据经纬度反向地理编译出地址信息
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *array, NSError *error)
     {

         if (array.count > 0)
         {
             CLPlacemark *placemark = [array objectAtIndex:0];
             
             NSMutableString * mStr = [[NSMutableString alloc] initWithString:placemark.name];
             NSRange range = [mStr rangeOfString:placemark.country];
             if (range.length > 0)
             {
                 [mStr deleteCharactersInRange:range];
             }
             locationLabel.text = mStr;
             MyAnnotation * annotation = [[MyAnnotation alloc] initWithTitle:@"" SubTitle:@"" Coordinate:coordinate];
             [mapView removeAnnotations:mapView.annotations];
             [mapView addAnnotation:annotation];
             [mapView selectAnnotation:annotation animated:YES];
  
         }

     }];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    
    MKPinAnnotationView * annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"ann"];
    if (!annotationView) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"ann"];
        
    }
    annotationView.annotation = annotation;

    return annotationView;
}

// MARK: - LocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status < 3) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            [_locationManager requestAlwaysAuthorization];
        }
        
    }
}

@end
