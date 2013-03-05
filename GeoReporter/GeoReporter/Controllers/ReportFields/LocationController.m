/**
 * @copyright 2013 City of Bloomington, Indiana. All Rights Reserved
 * @author Cliff Ingham <inghamn@bloomington.in.gov>
 * @license http://www.gnu.org/licenses/gpl.txt GNU/GPLv3, see LICENSE.txt
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */

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

- (IBAction)mapTypeChanged:(id)sender
{
    switch (((UISegmentedControl *)sender).selectedSegmentIndex) {
        case 0:
            [self.map setMapType:MKMapTypeStandard];
            break;
            
        case 1:
            [self.map setMapType:MKMapTypeSatellite];
            break;
    }
}
@end
