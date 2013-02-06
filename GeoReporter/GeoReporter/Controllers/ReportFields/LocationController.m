//
//  LocationController.m
//  GeoReporter
//
//  Created by Cliff Ingham on 2/5/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import "LocationController.h"
#import "ReportController.h"

@interface LocationController ()

@end

@implementation LocationController {
    CLLocationManager *locationManager;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    locationManager.distanceFilter = 50;
    [locationManager startUpdatingLocation];
    
    MKUserTrackingBarButtonItem *button = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.map];
    [self.navigationController.toolbar setItems:@[button]];
}

- (void)zoomToLocation:(CLLocation *)location
{
    MKCoordinateRegion region;
    region.center.latitude  = location.coordinate.latitude;
    region.center.longitude = location.coordinate.longitude;
    MKCoordinateSpan span;
    span.latitudeDelta  = 0.0025; // arbitrary value seems to look OK
    span.longitudeDelta = 0.0025; // arbitrary value seems to look OK
    region.span = span;
    [self.map setRegion:region animated:YES];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0) {
        [self zoomToLocation:location];
    }
}

- (IBAction)done:(id)sender
{
    [self.delegate didChooseLocation:[self.map centerCoordinate]];
}

- (IBAction)centerOnLocation:(id)sender
{
    [self zoomToLocation:locationManager.location];
}
@end
