//
//  Open311.m
//  GeoReporter
//
//  Created by Cliff Ingham on 1/30/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//
// Class for handling all Open311 network operations
//
// To make the user experience better, we request all the
// service metadata information at once.  Once everything is
// loaded, the UI should be snappy.
//
// You must call |loadAllMetadataForServer| before doing any other
// Open311 stuff in the app.

#import "Open311.h"
#import "Strings.h"
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"

NSString * const kNotification_ServiceListReady = @"serviceListReady";

@implementation Open311 {
    AFHTTPClient *httpClient;
    NSDictionary *currentServer;
    NSArray *serviceList;
}
SHARED_SINGLETON(Open311);

// Make sure to call this method before doing any other work
- (void)loadAllMetadataForServer:(NSDictionary *)server
{
    currentServer = server;
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *jurisdictionId = currentServer[kOpen311_Jurisdiction];
    NSString *apiKey         = currentServer[kOpen311_ApiKey];
    if (jurisdictionId != nil) { params[kOpen311_Jurisdiction] = jurisdictionId; }
    if (apiKey         != nil) { params[kOpen311_ApiKey]       = apiKey; }
    _endpointParameters = [NSDictionary dictionaryWithDictionary:params];
    
    if (_groups             == nil) { _groups             = [[NSMutableArray      alloc] init]; } else { [_groups             removeAllObjects]; }
    if (_serviceDefinitions == nil) { _serviceDefinitions = [[NSMutableDictionary alloc] init]; } else { [_serviceDefinitions removeAllObjects]; }
    
    httpClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:[server objectForKey:kOpen311_Url]]];
    [self loadServiceList];
}

- (void)loadFailedWithError:(NSError *)error
{
}

- (void)loadServiceList
{
    [httpClient getPath:@"services.json"
             parameters:_endpointParameters
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSError *error;
                    serviceList = [NSJSONSerialization JSONObjectWithData:responseObject options:nil error:&error];
                    if (!error) {
                        [self loadServiceDefinitions];
                    }
                    else {
                        [self loadFailedWithError:error];
                    }
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    [self loadFailedWithError:error];
                }];
}

// |serviceList| must already be loaded before calling this method.
//
// Loads unique |groups| from the |serviceList|
//
// Kicks off an HTTP Request for any and all |serviceDefinitions| that are needed.
// We do not wait around for them to finish.  Instead, we leave them in
// the background.  We can send the user on to the Group and Service choosing
// screens right away.  Hopefully, by the time the user has chosen a service
// to report, the HTTP request for that particular service will have finished.
// If not, the user will just not see any attributes that would have been defined
// in the service definition.
- (void)loadServiceDefinitions
{
    int count = [serviceList count];
    for (int i=0; i<count; i++) {
        NSDictionary *service = [serviceList objectAtIndex:i];
        
        // Add the current group if it's not already there
        NSString *group = [service objectForKey:kOpen311_Group];
        if (group == nil) { group = kUI_Uncategorized; }
        if (![_groups containsObject:group]) { [_groups addObject:group]; }
        
        // Fire off a service definition request, if needed
        __block NSString *serviceCode = [service objectForKey:kOpen311_ServiceCode];
        if ([[service objectForKey:kOpen311_Metadata] boolValue]) {
            [httpClient getPath:[NSString stringWithFormat:@"services/%@.json", serviceCode]
                     parameters:_endpointParameters
                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                            NSError *error;
                            _serviceDefinitions[serviceCode] = [NSJSONSerialization JSONObjectWithData:responseObject options:nil error:&error];
                            if (error) {
                                [self loadFailedWithError:error];
                            }
                        }
                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            [self loadFailedWithError:error];
                        }];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_ServiceListReady object:self];
}

/**
 * Returns an array of service dictionaries from |serviceList|
 */
- (NSArray *)getServicesForGroup:(NSString *)group
{
    NSMutableArray *services = [[NSMutableArray alloc] init];
    for (NSDictionary *service in serviceList) {
        NSString *sg = service[kOpen311_Group];
        
        if (![group isEqualToString:kUI_Uncategorized]) {
            if ([sg isEqualToString:group]) {
                [services addObject:service];
            }
        }
        else if (sg==nil || [sg isEqualToString:@""]) {
            [services addObject:service];
        }
    }
    return [NSArray arrayWithArray:services];
}

@end
