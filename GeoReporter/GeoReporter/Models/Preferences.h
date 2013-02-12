//
//  Preferences.h
//  GeoReporter
//
//  Created by Cliff Ingham on 1/28/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServiceRequest.h"

@interface Preferences : NSObject
+ (id)sharedInstance;

+ (NSArray *)getAvailableServers;

- (NSArray *)getCustomServers;
- (void)addCustomServer:(NSDictionary *)server;

- (NSDictionary *)getCurrentServer;
- (void)setCurrentServer:(NSDictionary *)server;

+ (NSString *)getArchiveFilePath;
- (NSArray *)getArchivedServiceRequests;
- (void)saveServiceRequest:(ServiceRequest *)serviceRequest forIndex:(NSInteger)index;
@end
