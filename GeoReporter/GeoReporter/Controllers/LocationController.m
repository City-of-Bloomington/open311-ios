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
#import "Strings.h"
#import "Maps.h"

static NSInteger const kMapTypeStandardIndex  = 0;
static NSInteger const kMapTypeSatelliteIndex = 1;
static NSInteger const kMapTypeHybridIndex    = 2;

@implementation LocationController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	_locationManager = [[CLLocationManager alloc] init];
	_locationManager.delegate = self;
	_locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
	_locationManager.distanceFilter = 50;
	[_locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
	CLLocation* location = [locations lastObject];
	NSDate* eventDate = location.timestamp;
	NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
	if (self.selectedLocation == nil) {
		if (abs(howRecent) < 15.0) {
            [Maps zoomMap:_map toCoordinate:location.coordinate withMarker:NO];
		}
	}
	else {
        [Maps zoomMap:_map toCoordinate:_selectedLocation.coordinate withMarker:NO];
	}
	
}

- (IBAction)cancel:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender
{
	CLLocation * location = [[CLLocation alloc] initWithLatitude:[self.map centerCoordinate].latitude longitude:[self.map centerCoordinate].longitude];
	self.selectedLocation = location;
	[self.delegate didChooseLocation:[self.map centerCoordinate]];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)centerOnLocation:(id)sender
{
    [Maps zoomMap:_map toCoordinate:_locationManager.location.coordinate withMarker:NO];
}

- (IBAction)mapTypeChanged:(id)sender
{
	switch (((UISegmentedControl *)sender).selectedSegmentIndex) {
		case kMapTypeStandardIndex:
			[self.map setMapType:MKMapTypeStandard];
			break;
			
		case kMapTypeSatelliteIndex:
			[self.map setMapType:MKMapTypeSatellite];
			break;
            
		case kMapTypeHybridIndex:
			[self.map setMapType:MKMapTypeHybrid];
			break;
	}
}

@end
