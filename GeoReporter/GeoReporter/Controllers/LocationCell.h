/**
 * @copyright 2013 City of Bloomington, Indiana. All Rights Reserved
 * @author Marius Constantinescu <constantinescu.marius@gmail.com>
 * @license http://www.gnu.org/licenses/gpl.txt GNU/GPLv3, see LICENSE.txt
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 *
 * Custom cell which shows a map, for the Location field in the New Report
 */

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#define LOCATION_CELL_HEIGHT 110
#define LOCATION_CELL_HEIGHT_IPAD 240

@interface LocationCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *header;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end
