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

static NSInteger const kMapTypeStandardIndex  = 0;
static NSInteger const kMapTypeSatelliteIndex = 1;
static NSInteger const kMapTypeHybridIndex = 2;

@implementation LocationController
- (void)viewDidLoad
{
	[super viewDidLoad];
	//make view controller start below navigation bar; this wrks in iOS 7
	if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
		self.navigationController.toolbar.tintColor = [UIColor orangeColor];
		self.segmentedControl.tintColor = [UIColor whiteColor];
		self.cancelButton.tintColor = [UIColor orangeColor];
		self.doneButton.tintColor = [UIColor orangeColor];
	}
	
	_locationManager = [[CLLocationManager alloc] init];
	_locationManager.delegate = self;
	_locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
	_locationManager.distanceFilter = 50;
	[_locationManager startUpdatingLocation];
	
	MKUserTrackingBarButtonItem *button = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.map];
	[self.navigationController.toolbar setItems:@[button]];
	
	[self.segmentedControl setTitle:NSLocalizedString(kUI_Standard,  nil) forSegmentAtIndex:kMapTypeStandardIndex];
	[self.segmentedControl setTitle:NSLocalizedString(kUI_Satellite, nil) forSegmentAtIndex:kMapTypeSatelliteIndex];
	
	[self willRotateToInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation duration:0];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		// The device is an iPad running iOS 3.2 or later		
		if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
			//change from landscape to portrait
			self.leftSpace.width = 351;
			self.rightSpace.width = 351;
			
		}
		else {
			//change from portrait to landscape
			self.leftSpace.width = 223;
			self.rightSpace.width = 223;
		}
	}
	else {
		// The device is an iPhone or iPod touch. We use the default frame of the superclass (TableViewCell)
	}
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
	[self.map setRegion:region animated:NO];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
	CLLocation* location = [locations lastObject];
	NSDate* eventDate = location.timestamp;
	NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
	if (self.selectedLocation == nil) {
		if (abs(howRecent) < 15.0) {
			[self zoomToLocation:location];
		}
	}
	else {
		[self zoomToLocation:self.selectedLocation];
	}
	
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
	[self zoomToLocation:_locationManager.location];
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

- (IBAction)cancel:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewDidUnload {
	[self setSegmentedControl:nil];
	[super viewDidUnload];
}
@end
