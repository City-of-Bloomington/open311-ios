//
//  LocationCell.h
//  GeoReporter
//
//  Created by Marius Constantinescu on 7/22/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#define LOCATION_CELL_HEIGHT 110

@interface LocationCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *header;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end
