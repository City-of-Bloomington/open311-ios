/**
 * @copyright 2011 City of Bloomington, Indiana. All Rights Reserved
 * @author Cliff Ingham <inghamn@bloomington.in.gov>
 * @license http://www.gnu.org/licenses/gpl.txt GNU/GPLv3, see LICENSE.txt
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */

#import "Open311.h"
#import "SBJson.h"
#import "Settings.h"

NSString * const kJurisdictionId = @"jurisdiction_id";
NSString * const kApiKey = @"api_key";
NSString * const kServiceCode = @"service_code";

@implementation Open311

static id _sharedOpen311 = nil;

@synthesize baseURL=_baseURL;
@synthesize services=_services;

@synthesize params;

+ (void)initialize
{
    if (self == [Open311 class]) {
        _sharedOpen311 = [[self alloc] init];
    }
}

+ (id)sharedOpen311
{
    return _sharedOpen311;
}

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void) dealloc
{
    [params release];
    [jurisdiction_id release];
    [api_key release];
    [currentServer release];
    [_baseURL release];
    [_services release];
    [super dealloc];
}

- (void)reset
{
    currentServer = nil;
    self.baseURL = nil;
    self.services = nil;
}


/**
 * Clears out all the current data and reloads Open311 data from the provided URL
 */
- (void)reload:(NSDictionary *)server
{
    [self reset];
    currentServer = server;
    self.baseURL = [NSURL URLWithString:[currentServer objectForKey:@"URL"]];
    
    // Create the parameter string for jurisdiction and api_key, if needed
    jurisdiction_id = [currentServer objectForKey:kJurisdictionId];
    api_key = [currentServer objectForKey:kApiKey];
    if (jurisdiction_id || api_key) {
        self.params = @"?";
        if (jurisdiction_id) {
            self.params = [self.params stringByAppendingFormat:@"%@=%@&", kJurisdictionId, jurisdiction_id];
        }
        if (api_key) {
            self.params = [self.params stringByAppendingFormat:@"%@=%@&", kApiKey, api_key];
        }
    }
    
    // Load the service list
    NSURL *servicesURL = [self getServiceListURL];
    DLog(@"Loading URL: %@", [servicesURL absoluteString]);
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:servicesURL];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(handleServicesSuccess:)];
    [request startAsynchronous];
}

#pragma mark - ASIHTTPRequest Handlers

- (void)handleServicesSuccess:(ASIHTTPRequest *)request
{
    self.services = [[request responseString] JSONValue];
    if (!self.services) {
        [self responseFormatInvalid:request];
        return;
    }
    DLog(@"Loaded %u services",[self.services count]);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"discoveryFinishedLoading" object:self];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"discoveryFinishedLoading" object:self];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not load url" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

/**
 * Called when we got a 200 response with text that we can't parse
 *
 * This is usually because the server thinks it is providing Open311 json,
 * when, in fact, it is not.
 */
- (void)responseFormatInvalid:(ASIHTTPRequest *)request
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"discoveryFinishedLoading" object:self];
    
    DLog(@"%@", [request responseString]);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Server gave invalid response" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

#pragma mark - API URL Getters
/**
 * Returns the URL for the list of services
 */
- (NSURL *)getServiceListURL
{
    NSURL *url = [self.baseURL URLByAppendingPathComponent:[NSString stringWithFormat:@"services.json"]];
    if ([self.params length] != 0) {
        url = [NSURL URLWithString:[[url absoluteString] stringByAppendingString:self.params]];
    }
    return url;
}

/**
 * Returns the URL to request a service definition from the current Open311 server
 */
- (NSURL *)getServiceDefinitionURL:(NSString *)service_code
{
    NSURL *url = [self.baseURL URLByAppendingPathComponent:[NSString stringWithFormat:@"services/%@.json", service_code]];
    if ([self.params length] != 0) {
        url = [NSURL URLWithString:[[url absoluteString] stringByAppendingString:[NSString stringWithFormat:@"%@%@=%@", self.params, kServiceCode, service_code]]];
    }
    else {
        url = [NSURL URLWithString:[[url absoluteString] stringByAppendingString:[NSString stringWithFormat:@"?%@=%@", kServiceCode,service_code]]];
    }
    return url;
}

/**
 * Returns the URL for POST-ing a new request to the current Open311 server
 *
 * This URL should not include jurisdiction_id nor api_key.
 * Those should be added to the POST form data, not the URL
 */
- (NSURL *)getPostServiceRequestURL
{
    NSURL *url = [self.baseURL URLByAppendingPathComponent:[NSString stringWithFormat:@"requests.json"]];
    return url;
}

/**
 * Returns the URL for getting a request_id from a token
 */
- (NSURL *)getRequestIdURL:(NSString *)token
{
    NSURL *url = [self.baseURL URLByAppendingPathComponent:[NSString stringWithFormat:@"tokens/%@.json",token]];
    if ([self.params length] != 0) {
        url = [NSURL URLWithString:[[url absoluteString] stringByAppendingString:self.params]];
    }
    return url;
}

/**
 * Returns the URL for looking up a single request from the current Open311 server
 */
- (NSURL *)getServiceRequestURL:(NSString *)service_request_id
{
    NSURL *url = [self.baseURL URLByAppendingPathComponent:[NSString stringWithFormat:@"requests/%@.json",service_request_id]];
    if ([self.params length] != 0) {
        url = [NSURL URLWithString:[[url absoluteString] stringByAppendingString:self.params]];
    }
    return url;
}

@end
