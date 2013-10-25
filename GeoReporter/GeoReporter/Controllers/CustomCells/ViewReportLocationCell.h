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
 * Custom cell used in the ViewRequestController for the cell containing
 * the map. Custom cells are needed so we can change the width for the 
 * iPad version in the Landscape orientation.
 */

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#define VIEW_REPORT_LOCATION_CELL_IPAD_OFFSET 100

@interface ViewReportLocationCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *description;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end
