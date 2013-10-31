//
//  Maps.h
//  GeoReporter
//
//  Created by Cliff Ingham on 10/11/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Maps : NSObject
+ (void)zoomMap:(MKMapView *)map toCoordinate:(CLLocationCoordinate2D)point withMarker:(BOOL)marker;

@end
