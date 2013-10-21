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

#import <QuartzCore/QuartzCore.h>
#import "LocationController.h"
#import "Strings.h"
#import "Maps.h"

static NSInteger const kMapTypeStandardIndex  = 0;
static NSInteger const kMapTypeSatelliteIndex = 1;
static NSInteger const kMapTypeHybridIndex    = 2;

@implementation LocationController{
	float screenWidth;
}
- (void)viewDidLoad
{
	[super viewDidLoad];

	
	_locationManager = [[CLLocationManager alloc] init];
	_locationManager.delegate = self;
	_locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
	_locationManager.distanceFilter = 50;
	[_locationManager startUpdatingLocation];
	
	screenWidth = [[UIScreen mainScreen] bounds].size.width;
	[self loadToolbarForScreenWidth:screenWidth];
	
	[self willRotateToInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation duration:0];
}

- (void)loadToolbarForScreenWidth:(float)width
{
	NSMutableArray *items = [[NSMutableArray alloc] init];
	float buttonOffset = 11;
	float buttonWidth = 60;
	float segmentedControlWidth = 150;
	
	
	if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
		//iOS 7
		
		//cancel button
		UIButton *cancelButton = [UIButton buttonWithType: UIButtonTypeRoundedRect];
		cancelButton.frame = CGRectMake(0, 0, buttonWidth, 29);
		cancelButton.titleLabel.adjustsFontSizeToFitWidth = YES;
		cancelButton.titleLabel.adjustsLetterSpacingToFitWidth = YES;
		cancelButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
		cancelButton.tintColor = [UIColor orangeColor];
		[cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
		[cancelButton setTitle:NSLocalizedString(kUI_Cancel, nila) forState:UIControlStateNormal];
		[items addObject:[[UIBarButtonItem alloc] initWithCustomView:cancelButton]];
		
		//first space
		UIBarButtonItem *firstSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
		firstSpace.width = (screenWidth - segmentedControlWidth - 2*buttonWidth - 4*buttonOffset)/2;
		[items addObject:firstSpace];
		
		
		//segmented control
		UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems: [NSArray arrayWithObjects:NSLocalizedString(kUI_Standard,  nil),NSLocalizedString(kUI_Satellite, nil),NSLocalizedString(kUI_Hybrid, nil),nil]];
		segmentedControl.frame = CGRectMake(0, 0, segmentedControlWidth, 29);
		NSDictionary* attributes = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:11.0]
															   forKey:UITextAttributeFont];
		[segmentedControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
		segmentedControl.tintColor = [UIColor whiteColor];
		segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
		segmentedControl.selectedSegmentIndex=0;
		[items addObject:[[UIBarButtonItem alloc] initWithCustomView:segmentedControl]];
		
		//second space
		UIBarButtonItem *secondSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
		secondSpace.width = (screenWidth - segmentedControlWidth - 2*buttonWidth - 4*buttonOffset)/2;
		[items addObject:secondSpace];
		
		//save button
		UIButton *saveButton = [UIButton buttonWithType: UIButtonTypeRoundedRect];
		saveButton.frame = CGRectMake(0, 0, buttonWidth, 29);
		saveButton.titleLabel.adjustsFontSizeToFitWidth = YES;
		saveButton.titleLabel.adjustsLetterSpacingToFitWidth = YES;
		saveButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
		saveButton.tintColor = [UIColor orangeColor];
		[saveButton addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
		[saveButton setTitle:NSLocalizedString(kUI_Save, nila) forState:UIControlStateNormal];
		[items addObject:[[UIBarButtonItem alloc] initWithCustomView:saveButton]];
	}
	else {
		//iOS 6
		UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[cancelButton setBackgroundImage:[[UIImage imageNamed:@"toolbar_button"]resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)] forState:UIControlStateNormal];
		cancelButton.titleLabel.adjustsFontSizeToFitWidth = YES;
		cancelButton.titleEdgeInsets = UIEdgeInsetsMake(0, 2, 2, 2);
		cancelButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
		cancelButton.frame = CGRectMake(0, 0, buttonWidth, 29);
		[cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
		[cancelButton setTitle:NSLocalizedString(kUI_Cancel, nil) forState:UIControlStateNormal];
		[items addObject:[[UIBarButtonItem alloc] initWithCustomView:cancelButton]];
		
		//first space
		UIBarButtonItem *firstSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
		firstSpace.width = (screenWidth - segmentedControlWidth - 2*buttonWidth - 4*buttonOffset)/2;
		[items addObject:firstSpace];
		
		
		//segmented control
		UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems: [NSArray arrayWithObjects:NSLocalizedString(kUI_Standard,  nil),NSLocalizedString(kUI_Satellite, nil),NSLocalizedString(kUI_Hybrid, nil),nil]];
		segmentedControl.frame = CGRectMake(0, 0, segmentedControlWidth, 29);
		NSDictionary* attributes = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:11.0]
															   forKey:UITextAttributeFont];
		[segmentedControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
		segmentedControl.tintColor = [UIColor orangeColor];
		segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
		segmentedControl.selectedSegmentIndex=0;
		[segmentedControl addTarget:self action:@selector(mapTypeChanged:) forControlEvents:UIControlEventValueChanged];

		[items addObject:[[UIBarButtonItem alloc] initWithCustomView:segmentedControl]];
		
		//second space
		UIBarButtonItem *secondSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
		secondSpace.width = (screenWidth - segmentedControlWidth - 2*buttonWidth - 4*buttonOffset)/2;
		[items addObject:secondSpace];
		
		//save button
		UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[saveButton setBackgroundImage:[[UIImage imageNamed:@"toolbar_button"]resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)] forState:UIControlStateNormal];
		saveButton.titleLabel.adjustsFontSizeToFitWidth = YES;
		saveButton.titleEdgeInsets = UIEdgeInsetsMake(0, 2, 2, 2);
		saveButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
		saveButton.frame = CGRectMake(0, 0, buttonWidth, 29);
		[saveButton addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
		[saveButton setTitle:NSLocalizedString(kUI_Save, nil) forState:UIControlStateNormal];
		[items addObject:[[UIBarButtonItem alloc] initWithCustomView:saveButton]];

	}
	[self.toolbar setTranslucent:YES];
	[self.toolbar setItems:items];
	self.toolbar.tintColor = [UIColor orangeColor];

}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
			//change from landscape to portrait
			screenWidth = [[UIScreen mainScreen] bounds].size.height;
		}
		else {
			//change from portrait to landscape
			screenWidth = [[UIScreen mainScreen] bounds].size.width;
		}
		[self loadToolbarForScreenWidth:screenWidth];
	}
	else {
		// The device is an iPhone or iPod touch. We use the default frame of the superclass (TableViewCell)
		screenWidth = [[UIScreen mainScreen] bounds].size.width;
	}
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

- (void)done:(id)sender
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

- (void)mapTypeChanged:(id)sender
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

- (void)cancel:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}
@end
