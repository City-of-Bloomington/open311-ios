//
//  ServiceRequest.m
//  GeoReporter
//
//  Created by Cliff Ingham on 2/4/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import "Report.h"
#import "Preferences.h"
#import "Strings.h"
#import "Open311.h"

@implementation Report

NSString * const kServer            = @"server";
NSString * const kService           = @"service";
NSString * const kServiceDefinition = @"serviceDefinition";
NSString * const kServiceRequest    = @"serviceRequest";
NSString * const kPostData          = @"postData";

// Intialize a new, empty service request
//
// This does not load any user-submitted data and should only
// be used for initial startup.  Subsequent loads should be done
// using the String version
- (id)initWithService:(NSDictionary *)service serviceDefinition:(NSDictionary *)serviceDefinition
{
	self = [super init];
	if (self) {
		_service  = service;
		
		if ([_service[kOpen311_Metadata] boolValue] && serviceDefinition) {
            _serviceDefinition = serviceDefinition;
		}
		
		_postData = [[NSMutableDictionary alloc] init];
		_postData[kOpen311_ServiceCode] = _service[kOpen311_ServiceCode];
		
		NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
		if ([[prefs stringForKey:kOpen311_IsAnonymous] isEqualToString:@"no"]) {
			NSString *firstname = [prefs stringForKey:kOpen311_FirstName];
			NSString *lastname  = [prefs stringForKey:kOpen311_LastName];
			NSString *email     = [prefs stringForKey:kOpen311_Email];
			NSString *phone     = [prefs stringForKey:kOpen311_Phone];
			if (firstname != nil) { _postData[kOpen311_FirstName] = firstname; }
			if (lastname  != nil) { _postData[kOpen311_LastName]  = lastname; }
			if (email     != nil) { _postData[kOpen311_Email]     = email; }
			if (phone     != nil) { _postData[kOpen311_Phone]     = phone; }
		}
	}
	return self;
}

// Initialize a fully populated ServiceRequest from an unserialized dictionary
- (id)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if (self) {
		_server            = dictionary[kServer];
		_service           = dictionary[kService];
		_serviceDefinition = dictionary[kServiceDefinition];
		_serviceRequest    = dictionary[kServiceRequest];
		_postData          = dictionary[kPostData];
	}
	return self;
}

- (void)checkAnonymousReporting
{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSString *firstname = @"";
	NSString *lastname  = @"";
	NSString *email     = @"";
	NSString *phone     = @"";
	if ([[prefs stringForKey:kOpen311_IsAnonymous] isEqualToString:@"no"]) {
		firstname = [prefs stringForKey:kOpen311_FirstName];
		lastname  = [prefs stringForKey:kOpen311_LastName];
		email     = [prefs stringForKey:kOpen311_Email];
		phone     = [prefs stringForKey:kOpen311_Phone];
	}
	if (firstname != nil) { _postData[kOpen311_FirstName] = firstname; }
	if (lastname  != nil) { _postData[kOpen311_LastName]  = lastname; }
	if (email     != nil) { _postData[kOpen311_Email]     = email; }
	if (phone     != nil) { _postData[kOpen311_Phone]     = phone; }
}

- (NSDictionary *)asDictionary
{
	NSMutableDictionary *output = [[NSMutableDictionary alloc] init];
	if (_server)            { output[kServer]            = _server; }
	if (_service)           { output[kService]           = _service; }
	if (_serviceDefinition) { output[kServiceDefinition] = _serviceDefinition; }
	if (_serviceRequest)    { output[kServiceRequest]    = _serviceRequest; }
	if (_postData)          { output[kPostData]          = _postData; }
	return [NSDictionary dictionaryWithDictionary:output];
}

// Looks up the attribute definition at the index and returns the key value
//
// This method only works for SingleValueList and MultiValueList attributes
// since they're the only attributes that have value lists
- (NSString *)attributeValueForKey:(NSString *)key atIndex:(NSInteger)index
{
	NSDictionary *attribute = _serviceDefinition[kOpen311_Attributes][index];
	if (   [attribute[kOpen311_Datatype] isEqualToString:kOpen311_SingleValueList]
		|| [attribute[kOpen311_Datatype] isEqualToString:kOpen311_MultiValueList]) {
		for (NSDictionary *value in attribute[kOpen311_Values]) {
			// Some servers use non-string keys
			// We need to convert them to strings before checking them
			// If they were unique to begin with, they should still be unique
			// after string conversion
			NSObject *valueKey = value[kOpen311_Key];
			if ([valueKey isKindOfClass:[NSNumber class]]) {
				valueKey = [(NSNumber *)valueKey stringValue];
			}
			if ([(NSString *)valueKey isEqualToString:key]) {
				return value[kOpen311_Name];
			}
		}
	}
	return nil;
}

#pragma mark - Refresh Service Request data
- (NSMutableDictionary *)getEndpointParameters
{
	if (!_parameters) {
		_parameters = [[NSMutableDictionary alloc] init];
		NSString *jurisdictionId = _server[kOpen311_Jurisdiction];
		NSString *apiKey         = _server[kOpen311_ApiKey];
		if (jurisdictionId != nil) { _parameters[kOpen311_Jurisdiction] = jurisdictionId; }
		if (apiKey         != nil) { _parameters[kOpen311_ApiKey]       = apiKey; }
	}
	return _parameters;
}

- (void)startLoadingServiceRequest:(NSString *)serviceRequestId delegate:(id<ServiceRequestDelegate>)delegate
{
	Open311 *open311 = [Open311 sharedInstance];
    AFHTTPRequestOperationManager *manager = [open311 getRequestManager];
    
    [manager GET:[NSString stringWithFormat:@"%@/requests/%@.json", _server[kOpen311_Url], serviceRequestId]
      parameters:[self getEndpointParameters]
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSArray *serviceRequests = responseObject;
             [delegate didReceiveServiceRequest:serviceRequests[0]];
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [open311 operationFailed:operation withError:error titleForAlert:kUI_FailureLoadingRequest];
         }
    ];
}

- (void)startLoadingServiceRequestIdFromToken:(NSString *)token delegate:(id<ServiceRequestDelegate>)delegate
{
	Open311 *open311 = [Open311 sharedInstance];
    AFHTTPRequestOperationManager *manager = [open311 getRequestManager];
    [manager GET:[NSString stringWithFormat:@"%@/tokens/%@.json", _server[kOpen311_Url], token]
      parameters:[self getEndpointParameters]
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSArray *serviceRequests = responseObject;
             NSString *serviceRequestId = serviceRequests[0][kOpen311_ServiceRequestId];
             if (serviceRequestId) {
                 [delegate didReceiveServiceRequestId:serviceRequestId];
             }
             // It may take a while before a serviceRequestId is created on a server.
             // In the meantime, they are not responding with an error.
             // We just don't need to call our delegate, since we don't have an id yet.
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             // Check for an Open311 formatted error response.
             // Display the error to the user, if there is one.
             [open311 operationFailed:operation withError:error titleForAlert:kUI_FailureLoadingRequest];
         }
    ];
}

@end
