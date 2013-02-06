//
//  LocationController.h
//  GeoReporter
//
//  Created by Cliff Ingham on 2/5/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
@class LocationController;

@protocol LocationChooserDelegate <NSObject>
-(void)didChooseLocation:(CLLocationCoordinate2D)location;
@end

@interface LocationController : UIViewController <CLLocationManagerDelegate>
@property id<LocationChooserDelegate>delegate;
@property (weak, nonatomic) IBOutlet MKMapView *map;
- (IBAction)done:(id)sender;
- (IBAction)centerOnLocation:(id)sender;

- (void)zoomToLocation:(CLLocation *)location;
@end
