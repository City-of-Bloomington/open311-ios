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

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

@interface Locator : NSObject <CLLocationManagerDelegate> {
@public
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    bool locationAvailable;
}
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *currentLocation;
@property (nonatomic) bool locationAvailable;

+ (id)sharedLocator;

- (void)startLocationServices;
- (void)stopLocationServices;
@end
