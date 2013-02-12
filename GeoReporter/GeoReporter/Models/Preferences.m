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
static NSString * const kArchiveFilename = @"savedServiceRequests.archive";

SHARED_SINGLETON(Preferences);

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


#pragma mark - Archived service requests

+ (NSString *)getArchiveFilePath
{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:kArchiveFilename];
}

- (NSArray *)getArchivedServiceRequests
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:[Preferences getArchiveFilePath]]) {
        return [NSKeyedUnarchiver unarchiveObjectWithFile:[Preferences getArchiveFilePath]];
    }
    else {
        return @[];
    }
}

/**
 * Inserts or Updates a serviceRequest in the archive
 *
 * If an index is not provided, the new service request is inserted
 * at the top of the archive.  The archive is immediately written out
 * to a file.
 */
 - (void)saveServiceRequest:(ServiceRequest *)serviceRequest forIndex:(NSInteger)index
{
    if (!index) { index = 0; }
    
    NSMutableArray *archive = [NSMutableArray arrayWithArray:[self getArchivedServiceRequests]];
    NSDictionary *sr = [serviceRequest asDictionary];
    [archive setObject:sr atIndexedSubscript:index];
    
    BOOL success = [NSKeyedArchiver archiveRootObject:archive toFile:[Preferences getArchiveFilePath]];
    if (!success) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"failed to save archive file"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(kUI_Cancel, nil)
                                              otherButtonTitles:nil];
        [alert show];
    }
}
@end
