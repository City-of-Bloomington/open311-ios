//
//  ViewReportLocationCell.h
//  GeoReporter
//
//  Created by Marius Constantinescu on 9/12/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#define VIEW_REPORT_LOCATION_CELL_IPAD_OFFSET 100

@interface ViewReportLocationCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *description;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end
