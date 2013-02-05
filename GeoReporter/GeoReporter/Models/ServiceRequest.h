//
//  ServiceRequest.h
//  GeoReporter
//
//  Created by Cliff Ingham on 2/4/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceRequest : NSObject
@property NSDictionary *server;
@property NSDictionary *service;
@property NSDictionary *serviceDefinition;
@property NSDictionary *serviceRequest;
@property NSMutableDictionary *postData;

- (id)initWithService:(NSDictionary *)service;
@end
