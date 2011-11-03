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

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Locator.h"

@interface BaseMapViewController : UIViewController {
    IBOutlet MKMapView *map;
    Locator *locator;
}
@property (nonatomic, retain) IBOutlet MKMapView *map;
@property (nonatomic, retain) Locator *locator;

- (void)zoomToGpsLocation:(BOOL)animated;

@end
