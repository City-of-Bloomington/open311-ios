//
//  Preferences.m
//  GeoReporter
//
//  Created by Cliff Ingham on 1/28/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import "Preferences.h"
#import "Strings.h"

@implementation Preferences {
    NSDictionary *availableServers;
    NSDictionary *currentServer;
}
static NSString * const kCustomServers = @"custom_servers";

+ (id)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedPreferences = nil;
    dispatch_once(&pred, ^{
        _sharedPreferences = [[self alloc] init];
    });
    return _sharedPreferences;
}

/**
 * Returns the Servers array from inside the AvailableServers.plist
 */
+ (NSArray *)getAvailableServers
{
    NSDictionary *plist = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AvailableServers" ofType:@"plist"]];
    return [plist objectForKey:@"Servers"];
}

- (NSArray *)getCustomServers
{
    NSString *json = [[NSUserDefaults standardUserDefaults] objectForKey:kCustomServers];
    if (json != nil) {
        return [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    }
    return nil;
}

- (void)addCustomServer:(NSDictionary *)server
{
    NSMutableArray *customServers = [NSMutableArray arrayWithArray:[self getCustomServers]];
    [customServers addObject:server];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:customServers options:0 error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [[NSUserDefaults standardUserDefaults] setValue:jsonString forKey:kCustomServers];
}

/**
 * Lazy load the current server information
 *
 * We only store the name of the current server on the phone.
 * Since the defintions for the servers can change, we must always 
 * load the fresh definition for the server from AvailableServers.
 */
- (NSDictionary *)getCurrentServer
{
    if (currentServer == nil) {
        NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:kOpen311_Name];
        if (![name isEqualToString:@""]) {
            NSArray *servers = [Preferences getAvailableServers];
            int count = [servers count];
            for (int i=0; i<count; i++) {
                if ([servers[i][kOpen311_Name] isEqualToString:name]) {
                    currentServer = servers[i];
                }
            }
        }
    }
    return currentServer;
}

- (void)setCurrentServer:(NSDictionary *)server
{
    currentServer = server;
    [[NSUserDefaults standardUserDefaults] setObject:server[kOpen311_Name] forKey:kOpen311_Name];
}

@end
