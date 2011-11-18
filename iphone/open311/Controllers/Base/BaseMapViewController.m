/**
 * @copyright 2011 City of Bloomington, Indiana. All Rights Reserved
 * @author Cliff Ingham <inghamn@bloomington.in.gov>
 * @license http://www.gnu.org/licenses/gpl.txt GNU/GPLv3, see LICENSE.txt
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */

#import "BaseMapViewController.h"
#import "Locator.h"

@implementation BaseMapViewController
@synthesize map, locator;

- (void)dealloc
{
    [locator release];
    [map release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.locator startLocationServices];
}

- (void)viewDidUnload
{
    [locator release];
    [map release];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self zoomToGpsLocation:animated];
}

#pragma mark - Location Functions

- (void)zoomToGpsLocation:(BOOL)animated
{
    if (self.locator.locationAvailable) {
        MKCoordinateRegion region;
        region.center.latitude = self.locator.currentLocation.coordinate.latitude;
        region.center.longitude = self.locator.currentLocation.coordinate.longitude;
        MKCoordinateSpan span;
        span.latitudeDelta = 0.0025; // arbitrary value seems to look OK
        span.longitudeDelta = 0.0025; // arbitrary value seems to look OK
        region.span = span;
        [self.map setRegion:region animated:animated];
    }
}

@end
