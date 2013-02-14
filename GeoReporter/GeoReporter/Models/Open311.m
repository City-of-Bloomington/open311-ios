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
#import "Preferences.h"
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "Media.h"

NSString * const kNotification_ServiceListReady = @"serviceListReady";
NSString * const kNotification_PostSucceeded    = @"postSucceeded";
NSString * const kNotification_PostFailed       = @"postFailed";

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
    DLog(@"%@", error);
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
                }
            ];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_ServiceListReady object:self];
}

/**
 * Displays an alert to the user and sets notification to any observers
 */
- (void)postFailedWithError:(NSError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_PostFailed object:self];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(kUI_FailurePostingService, nil)
                                                    message:[error localizedDescription]
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(kUI_Cancel, nil)
                                          otherButtonTitles:nil];
    [alert show];
}

/**
 * Creates a POST request
 *
 * The POST will be either a regular POST or multipart/form-data,
 * depending on whether the service request has media or not.
 */
- (NSMutableURLRequest *)preparePostForServiceRequest:(ServiceRequest *)serviceRequest withMedia:(UIImage *)media
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:_endpointParameters];
    [serviceRequest.postData enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (!parameters[key]) {
            parameters[key] = obj;
        }
    }];
    
    NSMutableURLRequest *post;
    if (media) {
        [parameters removeObjectForKey:kOpen311_Media];
        post = [httpClient multipartFormRequestWithMethod:@"POST"
                                                     path:@"requests.json"
                                               parameters:parameters
                                constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                    [formData appendPartWithFileData:UIImagePNGRepresentation(media)
                                                                name:kOpen311_Media
                                                            fileName:@"media.png"
                                                            mimeType:@"image/png"];
                                }];
    }
    else {
        post = [httpClient requestWithMethod:@"POST" path:@"requests.json" parameters:parameters];
    }
    return post;
}

/**
 * Kicks off the service request posting process
 *
 * Loading media from the asset library is an async call.
 * So we have to set a callback for when the image data is loaded.
 * This starts the process and sets the image-loaded callback
 * to [self postServiceRequest]
 *
 * If there's no media involved, we just call that method right away
 */
- (void)startPostingServiceRequest:(ServiceRequest *)serviceRequest
{
    NSURL *mediaUrl = serviceRequest.postData[kOpen311_Media];
    if (mediaUrl) {
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:mediaUrl
                 resultBlock:^(ALAsset *asset) {
                     ALAssetRepresentation *rep = [asset defaultRepresentation];
                     UIImage *original = [UIImage imageWithCGImage:[rep CGImageWithOptions:nil]];
                     UIImage *media = [Media resizeImage:original toBoundingBox:800];
                     
                     NSMutableURLRequest *post = [self preparePostForServiceRequest:serviceRequest withMedia:media];
                     [self postServiceRequest:serviceRequest withPost:post];
                 }
                failureBlock:^(NSError *error) {
                    [self postFailedWithError:error];
                }];
    }
    else {
        NSMutableURLRequest *post = [self preparePostForServiceRequest:serviceRequest withMedia:nil];
        [self postServiceRequest:serviceRequest withPost:post];
    }
}

/**
 * Sends the service request to the Open311 server
 *
 * This is an Async network call.
 * The Open311 object will send out notifications when the call is finished.
 * PostSucceeded or PostFailed
 */
- (void)postServiceRequest:(ServiceRequest *)serviceRequest withPost:(NSMutableURLRequest *)post
{
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:post
           success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
               NSNotificationCenter *notifications = [NSNotificationCenter defaultCenter];
               
               if ([NSJSONSerialization isValidJSONObject:JSON]) {
                   NSMutableDictionary *sr = [NSMutableDictionary dictionaryWithDictionary:JSON[0]];
                   if (sr[kOpen311_ServiceRequestId] || sr[kOpen311_Token]) {
                       if (!sr[kOpen311_RequestedDatetime]) {
                           NSDateFormatter *df = [[NSDateFormatter alloc] init];
                           [df setDateFormat:kDate_ISO8601];
                           sr[kOpen311_RequestedDatetime] = [df stringFromDate:[NSDate date]];
                       }
                       serviceRequest.server         = currentServer;
                       serviceRequest.serviceRequest = sr;
                       [[Preferences sharedInstance] saveServiceRequest:serviceRequest forIndex:nil];
                       [notifications postNotificationName:kNotification_PostSucceeded object:self];
                   }
                   else {
                       [notifications postNotificationName:kNotification_PostFailed object:self];
                   }
               }
               else {
                   [notifications postNotificationName:kNotification_PostFailed object:self];
               }
           }
           failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
               [self postFailedWithError:error];
           }
    ];
    [operation start];
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
