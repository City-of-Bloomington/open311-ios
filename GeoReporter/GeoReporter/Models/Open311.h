//
//  Open311.h
//  GeoReporter
//
//  Created by Cliff Ingham on 1/30/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import <Foundation/Foundation.h>
extern NSString * const kNotification_ServiceListReady;

@interface Open311 : NSObject
@property (readonly) NSDictionary *endpointParameters;
@property (readonly) NSMutableArray *groups;
@property (readonly) NSMutableDictionary *serviceDefinitions;

+ (id)sharedInstance;

- (void)loadAllMetadataForServer:(NSDictionary *)server;
- (void)loadFailedWithError:(NSError *)error;

- (void)loadServiceList;
- (void)loadServiceDefinitions;

- (NSArray *)getServicesForGroup:(NSString *)group;
@end
