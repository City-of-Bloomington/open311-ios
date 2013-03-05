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

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
@class LocationController;

/**
 * Protocol used to send user input back to ReportController
 */
@protocol LocationChooserDelegate <NSObject>
-(void)didChooseLocation:(CLLocationCoordinate2D)location;
@end

@interface LocationController : UIViewController <CLLocationManagerDelegate>
@property id<LocationChooserDelegate>delegate;
@property (weak, nonatomic) IBOutlet MKMapView *map;
- (IBAction)done:(id)sender;
- (IBAction)centerOnLocation:(id)sender;
- (IBAction)mapTypeChanged:(id)sender;

- (void)zoomToLocation:(CLLocation *)location;
@end
