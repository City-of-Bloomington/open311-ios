/**
 * Class for handling all Open311 network operations
 *
 * To avoid long loading times in the beginning, we first load
 * the groups and the services. Then, whenever the user chooses
 * a service, we load the metadata for that service.
 *
 * You must call |loadAllMetadataForServer:WithCompletion:|
 * before doing any other Open311 stuff in the app.
 *
 * @copyright 2013 City of Bloomington, Indiana. All Rights Reserved
 * @author Cliff Ingham <inghamn@bloomington.in.gov>
 * @license http://www.gnu.org/licenses/gpl.txt GNU/GPLv3, see LICENSE.txt
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */
#import "Open311.h"
#import "Strings.h"
#import "Preferences.h"
#import "Media.h"
#import "MBProgressHUD.h"

NSString * const kNotification_PostSucceeded    = @"postSucceeded";
NSString * const kNotification_PostFailed       = @"postFailed";

@implementation Open311
SHARED_SINGLETON(Open311);

- (AFHTTPRequestOperationManager *)getReqestManager
{
    if (!_manager) {
        _manager = [AFHTTPRequestOperationManager manager];
        _manager.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    return _manager;
}

/**
 * Loads the service list from the given server
 *
 * Only loads the service list.  We're going to wait to load service
 * definitions until we really need them.
 * This server becomes the CurrentServer, which caches all metadata
 * from this server, so we don't have to request it again.
 */
- (void)loadServer:(NSDictionary *)server withCompletion:(void(^)(void))completion
{
	_currentServer = server;
	
	NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
	NSString *jurisdictionId = _currentServer[kOpen311_Jurisdiction];
	NSString *apiKey         = _currentServer[kOpen311_ApiKey];
	if (jurisdictionId != nil) { params[kOpen311_Jurisdiction] = jurisdictionId; }
	if (apiKey         != nil) { params[kOpen311_ApiKey]       = apiKey; }
	_endpointParameters = [NSDictionary dictionaryWithDictionary:params];
	
	// Clear out any previously cached metadata
    if (_groups             == nil) { _groups             = [[NSMutableArray      alloc] init]; } else { [_groups             removeAllObjects]; }
	if (_serviceDefinitions == nil) { _serviceDefinitions = [[NSMutableDictionary alloc] init]; } else { [_serviceDefinitions removeAllObjects]; }
	
	[self loadServiceListWithCompletion:completion];
}

/**
 * Generalized request error handling
 *
 * Checks the response for any Open311 formatted error, and displays
 * that error as an alert.
 */
- (void)operationFailed:(AFHTTPRequestOperation *)operation withError:(NSError *)error titleForAlert:(NSString *)title
{
	NSString *alertMessage = [error localizedDescription];
    
    if (operation) {
        NSData *responseData = [operation responseData];
        
        // Try and read an Open311 error message from the response
        if (responseData) {
            NSError *e;
            NSArray *messages = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&e];
            NSInteger statusCode = [[operation response] statusCode];
            if (!e) {
                NSDictionary *m = messages[0];
                if (m[kOpen311_Description]) {
                    alertMessage = m[kOpen311_Description];
                }
            }
            
            if (statusCode == 403) {
                title = NSLocalizedString(kUI_Error403, nil);
            }
        }
    }
    
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
													message:alertMessage
												   delegate:self
										  cancelButtonTitle:NSLocalizedString(kUI_Cancel, nil)
										  otherButtonTitles:nil];
	[alert show];
}

#pragma mark - GET Service List
- (void)loadServiceListWithCompletion:(void(^)(void))completion
{
    AFHTTPRequestOperationManager *manager = [self getReqestManager];
    
    [manager GET:[NSString stringWithFormat:@"%@/services.json", _currentServer[kOpen311_Url]]
       parameters:_endpointParameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              _serviceList = responseObject;
              [self loadGroups];
              completion();
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              [self operationFailed:operation withError:error titleForAlert:NSLocalizedString(kUI_FailureLoadingServices, nil)];
              completion();
          }
    ];
}

// |serviceList| must already be loaded before calling this method.
//
// Loads unique |groups| from the |serviceList|
- (void)loadGroups
{
	unsigned int count = (unsigned int)[_serviceList count];
	for (int i=0; i<count; i++) {
		NSDictionary *service = [_serviceList objectAtIndex:i];
		
		// Add the current group if it's not already there
		NSString *group = [service objectForKey:kOpen311_Group];
		if (group == nil) { group = kUI_Uncategorized; }
		if (![_groups containsObject:group]) { [_groups addObject:group]; }
	}
}


/**
 * Lazy-load a service defintion from the server
 * 
 * If we've already loaded a definition, it will be in |_serviceDefinitions|
 */
- (void)getServiceDefinition:(NSDictionary *)service withCompletion:(void (^)(NSDictionary *))completion
{
	__block NSString *serviceCode = [service objectForKey:kOpen311_ServiceCode];
    
    if (![_serviceDefinitions objectForKey:serviceCode] && [[service objectForKey:kOpen311_Metadata] boolValue]) {
        AFHTTPRequestOperationManager *manager = [self getReqestManager];
        [manager GET:[NSString stringWithFormat:@"%@/services/%@.json", _currentServer[kOpen311_Url], serviceCode]
          parameters:_endpointParameters
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 _serviceDefinitions[serviceCode] = responseObject;
                 completion(_serviceDefinitions[serviceCode]);
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 [self operationFailed:operation withError:error titleForAlert:NSLocalizedString(kUI_FailureLoadingServices, nil)];
             }
        ];
    }
    else {
        // There is no definition for this service.
        // We can return immediately
        completion(_serviceDefinitions[serviceCode]);
    }
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
 */
- (void)postFailedWithError:(NSError *)error forOperation:(AFHTTPRequestOperation *)operation
{
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotification_PostFailed object:self];
	NSString *title = NSLocalizedString(kUI_FailurePostingService, nil);
    
    [self operationFailed:operation withError:error titleForAlert:title];
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
					 
					 [self postReport:report withMedia:media];
				 }
				failureBlock:^(NSError *error) {
					[self postFailedWithError:error forOperation:nil];
				}];
	}
	else {
		[self postReport:report withMedia:nil];
	}
}

/**
 * Sends the report to the Open311 server
 *
 * This is an Async network call.
 * The Open311 object will send out notifications when the call is finished.
 * PostSucceeded or PostFailed
 */
- (void)postReport:(Report *)report withMedia:(UIImage *)media
{
    /**
     * Success block called when the request completes
     */
    void (^success)(AFHTTPRequestOperation*, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSNotificationCenter *notifications = [NSNotificationCenter defaultCenter];
        
        NSArray *serviceRequests = responseObject;
        NSMutableDictionary *sr = [NSMutableDictionary dictionaryWithDictionary:serviceRequests[0]];
        if (sr[kOpen311_ServiceRequestId] || sr[kOpen311_Token]) {
            // Set a status of pending. This will be updated later,
            // when we load fresh data from the server
            sr[kOpen311_Status] = kUI_Pending;
            
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
    };
    
    /**
     * Failure block called when the request completes
     */
    void (^failure)(AFHTTPRequestOperation*, NSError*) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        [self postFailedWithError:error forOperation:operation];
    };
    
    
    // Read all the report fields into a Dictionary for posting
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:_endpointParameters];
    [report.postData enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (!parameters[key]) { parameters[key] = obj; }
    }];
    
    AFHTTPRequestOperationManager *manager = [self getReqestManager];
    NSString *url = [NSString stringWithFormat:@"%@/requests.json", _currentServer[kOpen311_Url]];
    if (media) {
        [manager POST:url
            parameters:parameters
            constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                NSData *raw = UIImagePNGRepresentation(media);
                [formData appendPartWithFileData:raw name:kOpen311_Media fileName:@"media.png" mimeType:@"image/png"];
            }
            success:success
            failure:failure
        ];
    }
    else {
        [manager POST:url parameters:parameters success:success failure:failure];
    }
}

@end
