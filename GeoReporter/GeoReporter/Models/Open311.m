//
//  Open311.m
//  GeoReporter
//
//  Created by Cliff Ingham on 1/30/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//
// Class for handling all Open311 network operations
//
// To avoid long loading times in the beginning, we first load
// the groups and the services. Then, whenever the user chooses
// a service, we load the metadata for that service.
//
// You must call |loadAllMetadataForServer:WithCompletion:|
// before doing any other Open311 stuff in the app.

#import "Open311.h"
#import "Strings.h"
#import "Preferences.h"
#import <AFNetworking/AFHTTPClient.h>
#import <AFNetworking/AFJSONRequestOperation.h>
#import "Media.h"
#import <MBProgressHUD.h>

NSString * const kNotification_ServiceListReady = @"serviceListReady";
NSString * const kNotification_PostSucceeded    = @"postSucceeded";
NSString * const kNotification_PostFailed       = @"postFailed";

@implementation Open311
SHARED_SINGLETON(Open311);

// Make sure to call this method before doing any other work
- (void)loadAllMetadataForServer:(NSDictionary *)server withCompletion:(void(^)(void)) completion
{
	_currentServer = server;
	
	NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
	NSString *jurisdictionId = _currentServer[kOpen311_Jurisdiction];
	NSString *apiKey         = _currentServer[kOpen311_ApiKey];
	if (jurisdictionId != nil) { params[kOpen311_Jurisdiction] = jurisdictionId; }
	if (apiKey         != nil) { params[kOpen311_ApiKey]       = apiKey; }
	_endpointParameters = [NSDictionary dictionaryWithDictionary:params];
	
	if (_groups             == nil) { _groups             = [[NSMutableArray      alloc] init]; } else { [_groups             removeAllObjects]; }
	if (_serviceDefinitions == nil) { _serviceDefinitions = [[NSMutableDictionary alloc] init]; } else { [_serviceDefinitions removeAllObjects]; }
	
	_httpClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:[server objectForKey:kOpen311_Url]]];
	[self loadServiceListWithCompletion:completion];
}

- (void)loadFailedWithError:(NSError *)error
{
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotification_ServiceListReady object:self];
	NSLog(@"ERROR:\t%@", [error localizedDescription]);
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(kUI_FailureLoadingServices, nil)
													message:NSLocalizedString(kUI_URLError, nil)
												   delegate:self
										  cancelButtonTitle:NSLocalizedString(kUI_Cancel, nil)
										  otherButtonTitles:nil];
	[alert show];
}

- (void)checkServerValidity:(NSString *) serverURL fromSender:(id)sender
{
	_httpClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:serverURL]];
	
	[_httpClient getPath:@"services.json"
			  parameters:_endpointParameters
				 success:^(AFHTTPRequestOperation *operation, id responseObject) {
					 NSError *error;
					 _serviceList = [NSJSONSerialization JSONObjectWithData:responseObject options:nil error:&error];
					 if (!error) {
						 //[self loadServiceDefinitions];
						 [sender performSelector:@selector(didFinishSaving)];
					 }
					 else {
						 [self loadFailedWithError:error];
					 }
				 }
				 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
					 [self loadFailedWithError:error];
				 }];
	
	
	
}

#pragma mark - GET Service List
- (void)loadServiceListWithCompletion:(void(^)(void)) completion
{
	[_httpClient getPath:@"services.json"
			  parameters:_endpointParameters
				 success:^(AFHTTPRequestOperation *operation, id responseObject) {
					 NSError *error;
					 _serviceList = [NSJSONSerialization JSONObjectWithData:responseObject options:nil error:&error];
					 completion();
					 if (!error) {
						 //[self loadServiceDefinitions];
						 [self loadGroups];
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
- (void) loadGroups
{
	int count = [_serviceList count];
	for (int i=0; i<count; i++) {
		NSDictionary *service = [_serviceList objectAtIndex:i];
		
		// Add the current group if it's not already there
		NSString *group = [service objectForKey:kOpen311_Group];
		if (group == nil) { group = kUI_Uncategorized; }
		if (![_groups containsObject:group]) { [_groups addObject:group]; }
	}
}


// Kicks off an HTTP Request for one |serviceDefinition| that is needed.
// This is called when the user selects a service. Then a progress hud
// will be shown while the request is being processed

- (void)getMetadataForService:(NSDictionary*) service WithCompletion:(void(^)(void)) completion
{
	
	
	// Fire off a service definition request, if needed
	__block NSString *serviceCode = [service objectForKey:kOpen311_ServiceCode];
	if ([[service objectForKey:kOpen311_Metadata] boolValue]) {
		[_httpClient getPath:[NSString stringWithFormat:@"services/%@.json", serviceCode]
				  parameters:_endpointParameters
					 success:^(AFHTTPRequestOperation *operation, id responseObject) {
						 NSError *error;
						 _serviceDefinitions[serviceCode] = [NSJSONSerialization JSONObjectWithData:responseObject options:nil error:&error];
						 completion();
						 if (error) {
							 [self loadFailedWithError:error];
						 }
					 }
					 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
						 completion();
						 [self loadFailedWithError:error];
					 }
		 ];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotification_ServiceListReady object:self];
}


/**
 * Returns an array of service dictionaries from |serviceList|
 */
- (NSArray *)getServicesForGroup:(NSString *)group
{
	NSMutableArray *services = [[NSMutableArray alloc] init];
	for (NSDictionary *service in _serviceList) {
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

#pragma mark - POST Service Request
/**
 * Displays an alert to the user and sets notification to any observers
 *
 * If the server supports known Open311 error formatting, we can display
 * the error message reported by the Open311 server.  Otherwise, we can
 * only display a generic message.
 */
- (void)postFailedWithError:(NSError *)error forOperation:(AFHTTPRequestOperation *)operation
{
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotification_PostFailed object:self];
	NSString *title = NSLocalizedString(kUI_FailurePostingService, nil);
	NSString *message = [error localizedDescription];
    
    if (operation) {
        NSData *responseData = [operation responseData];
        if (responseData) {
            NSError *e;
            NSArray *serviceRequests = [NSJSONSerialization JSONObjectWithData:responseData options:nil error:&e];
            NSInteger statusCode = [[operation response] statusCode];
            if (!e) {
                NSDictionary *sr = serviceRequests[0];
                if (sr[kOpen311_Description]) {
                    message = sr[kOpen311_Description];
                }
            }
            
            if (statusCode == 403) {
                title = NSLocalizedString(kUI_Error403, nil);
            }
        }
    }
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
													message:message
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
- (NSMutableURLRequest *)preparePostForReport:(Report *)report withMedia:(UIImage *)media
{
	NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:_endpointParameters];
	[report.postData enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		if (!parameters[key]) {
			parameters[key] = obj;
		}
	}];
	
	NSMutableURLRequest *post;
	if (media) {
		[parameters removeObjectForKey:kOpen311_Media];
		post = [_httpClient multipartFormRequestWithMethod:@"POST"
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
		post = [_httpClient requestWithMethod:@"POST" path:@"requests.json" parameters:parameters];
	}
	return post;
}

/**
 * Kicks off the report posting process
 *
 * Loading media from the asset library is an async call.
 * So we have to set a callback for when the image data is loaded.
 * This starts the process and sets the image-loaded callback
 * to [self postServiceRequest]
 *
 * If there's no media involved, we just call that method right away
 */
- (void)startPostingServiceRequest:(Report *)report
{
	NSURL *mediaUrl = report.postData[kOpen311_Media];
	if (mediaUrl) {
		ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
		[library assetForURL:mediaUrl
				 resultBlock:^(ALAsset *asset) {
					 ALAssetRepresentation *rep = [asset defaultRepresentation];
					 UIImage *original = [UIImage imageWithCGImage:[rep fullScreenImage]];
					 UIImage *media = [Media resizeImage:original toBoundingBox:800];
					 
					 NSMutableURLRequest *post = [self preparePostForReport:report withMedia:media];
					 [self postReport:report withPost:post];
				 }
				failureBlock:^(NSError *error) {
					[self postFailedWithError:error forOperation:nil];
				}];
	}
	else {
		NSMutableURLRequest *post = [self preparePostForReport:report withMedia:nil];
		[self postReport:report withPost:post];
	}
}

/**
 * Sends the report to the Open311 server
 *
 * This is an Async network call.
 * The Open311 object will send out notifications when the call is finished.
 * PostSucceeded or PostFailed
 */
- (void)postReport:(Report *)report withPost:(NSMutableURLRequest *)post
{
	AFHTTPRequestOperation *operation;
	operation = [_httpClient HTTPRequestOperationWithRequest:post
													 success:^(AFHTTPRequestOperation *operation, id responseObject) {
														 NSNotificationCenter *notifications = [NSNotificationCenter defaultCenter];
														 
														 NSError *error;
														 NSArray *serviceRequests = [NSJSONSerialization JSONObjectWithData:responseObject options:nil error:&error];
														 if (!error) {
															 NSMutableDictionary *sr = [NSMutableDictionary dictionaryWithDictionary:serviceRequests[0]];
															 if (sr[kOpen311_ServiceRequestId] || sr[kOpen311_Token]) {
																 if (!sr[kOpen311_RequestedDatetime]) {
																	 NSDateFormatter *df = [[NSDateFormatter alloc] init];
																	 [df setDateFormat:kDate_ISO8601];
																	 sr[kOpen311_RequestedDatetime] = [df stringFromDate:[NSDate date]];
																 }
																 report.server         = _currentServer;
																 report.serviceRequest = sr;
																 [[Preferences sharedInstance] saveReport:report forIndex:-1];
																 [notifications postNotificationName:kNotification_PostSucceeded object:self];
															 }
															 else {
																 // We got a 200 response back in the correct format
																 // However, it did not include a token or a service_request_id
																 [notifications postNotificationName:kNotification_PostFailed object:self];
															 }
														 }
														 else {
															 // We got a 200 response, but it was not valid JSON
															 [notifications postNotificationName:kNotification_PostFailed object:self];
														 }
													 }
													 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
														 [self postFailedWithError:error forOperation:operation];
													 }];
	[operation start];
}

@end
