//
//  Maps.m
//  GeoReporter
//
//  Created by Cliff Ingham on 10/11/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import "Maps.h"

@implementation Maps
/**
 * Centers and Zooms a map to the provided point
 */
+(void)zoomMap:(MKMapView *)map toCoordinate:(CLLocationCoordinate2D)point withMarker:(BOOL)marker
{
    MKCoordinateRegion region;
    region.center.latitude  = point.latitude;
    region.center.longitude = point.longitude;
    MKCoordinateSpan span;
    span.latitudeDelta  = 0.007;
    span.longitudeDelta = 0.007;
    region.span = span;
    
    if (marker) {
        // Clear out any previous markers
        for (id annotation in map.annotations) {
            [map removeAnnotation:annotation];
        }
        MKPointAnnotation *marker = [[MKPointAnnotation alloc] init];
        marker.coordinate = point;
        [map addAnnotation:marker];
    }
    
    [map setRegion:region animated:YES];
}
@end
