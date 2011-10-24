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

#import "Locator.h"

@implementation Locator

static id _sharedLocator = nil;

@synthesize locationManager;
@synthesize locationAvailable;
@synthesize currentLocation;

+ (void)initialize
{
    if (self == [Locator class]) {
        _sharedLocator = [[self alloc] init];
    }
}

+ (id)sharedLocator
{
    return _sharedLocator;
}

- (id) init
{
    self = [super init];
    if (self) {
        self.locationAvailable = NO;
        self.currentLocation = [[CLLocation alloc] init];
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        [self startLocationServices];
    }
    return self;
}

- (void)dealloc
{
    [currentLocation release];
    [locationManager release];
    [super dealloc];
}

- (void)startLocationServices
{
    [self.locationManager startUpdatingLocation];
}

- (void)stopLocationServices
{
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	if ( abs([newLocation.timestamp timeIntervalSinceDate: [NSDate date]]) < 120) {             
        self.currentLocation = newLocation;
        self.locationAvailable = YES;
        
        if (newLocation.horizontalAccuracy <= locationManager.desiredAccuracy) {
            [self stopLocationServices];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    self.currentLocation = nil;
    self.locationAvailable = NO;
}

@end
