//
//  ChatLocationViewController.h
//  Chat
//
//  Created by 货道网 on 15/5/19.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@protocol ChatLocationDelegate;
@interface ChatLocationViewController : UIViewController
<MKMapViewDelegate, CLLocationManagerDelegate>
{
    MKMapView * _mapView;
    UILabel * locationLabel;
    CLLocationManager * _locationManager;
    
    CLLocationCoordinate2D currentCorrdinate;
}

@property (nonatomic, assign) id <ChatLocationDelegate> delegate;

/**
 *  如果传入message 则视为查看位置 不传入则视为发送位置
 */
@property (nonatomic, weak) Message * message;

@end


@protocol ChatLocationDelegate <NSObject>

- (void)chatLocation:(ChatLocationViewController *)location Name:(NSString *)name Longitude:(CGFloat)longitude Latitude:(CGFloat)latitude;

@end