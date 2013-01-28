//
//  Preferences.h
//  GeoReporter
//
//  Created by Cliff Ingham on 1/28/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Preferences : NSObject
+ (id)sharedInstance;
+ (NSArray *)getAvailableServers;

- (NSArray *)getCustomServers;
- (void)addCustomServer:(NSDictionary *)server;

- (NSDictionary *)getCurrentServer;
- (void)setCurrentServer:(NSDictionary *)server;
@end
