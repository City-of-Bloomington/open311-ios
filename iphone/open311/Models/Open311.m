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

@implementation Open311

static id _sharedOpen311 = nil;

@synthesize endpoint=_endpoint;
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
    [_endpoint release];
    [_services release];
    [super dealloc];
}

/**
 * Clears out all the current data and reloads Open311 data from the provided URL
 */
- (void)reload:(NSDictionary *)server
{
    [self reset];
    currentServer = server;
    baseURL = [NSURL URLWithString:[currentServer objectForKey:@"URL"]];
    jurisdiction_id = [currentServer objectForKey:@"jurisdiction_id"];
    api_key = [currentServer objectForKey:@"api_key"];
    
    // Load the discovery data
    DLog(@"Open311:reload:%@",[baseURL absoluteString]);
    NSURL *discoveryURL = [baseURL URLByAppendingPathComponent:@"discovery.json"];
    DLog(@"Loading URL: %@",discoveryURL);
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:discoveryURL];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(handleDiscoverySuccess:)];
    [request startAsynchronous];
}

- (void)reset
{
    currentServer = nil;
    self.endpoint = nil;
    self.baseURL = nil;
    self.services = nil;
}

#pragma mark - ASIHTTPRequest Handlers
- (void)handleDiscoverySuccess:(ASIHTTPRequest *)request
{
    NSDictionary *discovery = [[request responseString] JSONValue];
    for (NSDictionary *ep in [discovery objectForKey:@"endpoints"]) {
        if ([[ep objectForKey:@"specification"] isEqualToString:@"http://wiki.open311.org/GeoReport_v2"]) {
            self.endpoint = ep; 
            self.baseURL = [NSURL URLWithString:[ep objectForKey:@"url"]];
        }
    }
    
    self.params = @"";
    if (jurisdiction_id || api_key) {
        self.params = @"?";
        if (jurisdiction_id) {
            self.params = [self.params stringByAppendingFormat:@"jurisdiction_id=%@&",jurisdiction_id];
        }
        if (api_key) {
            self.params = [self.params stringByAppendingFormat:@"api_key=%@&",api_key];
        }
    }
    
    // Load all the service definitions
    if (self.baseURL) {
        NSURL *servicesURL = [self.baseURL URLByAppendingPathComponent:[NSString stringWithFormat:@"services.json"]];
        if ([self.params length] != 0) {
            servicesURL = [NSURL URLWithString:[[servicesURL absoluteString] stringByAppendingString:self.params]];
        }
        DLog(@"Loading URL: %@", servicesURL);
        request = [ASIHTTPRequest requestWithURL:servicesURL];
        [request setDelegate:self];
        [request setDidFinishSelector:@selector(handleServicesSuccess:)];
        [request startAsynchronous];
    }
}

- (void)handleServicesSuccess:(ASIHTTPRequest *)request
{
    self.services = [[request responseString] JSONValue];
    DLog(@"Loaded %u services",[self.services count]);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"discoveryFinishedLoading" object:self];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not load url" message:[[request url] absoluteString] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

#pragma mark - API URL Getters
/**
 * Returns the URL to request a service definition from the current Open311 server
 */
- (NSURL *)getServiceDefinitionURL:(NSString *)service_code
{
    NSURL *url = [self.baseURL URLByAppendingPathComponent:[NSString stringWithFormat:@"services/%@.json",service_code]];
    if ([self.params length] != 0) {
        url = [NSURL URLWithString:[[url absoluteString] stringByAppendingString:[NSString stringWithFormat:@"%@service_code=%@",self.params,service_code]]];
    }
    else {
        url = [NSURL URLWithString:[[url absoluteString] stringByAppendingString:[NSString stringWithFormat:@"?service_code=%@",service_code]]];
    }
    return url;
}

/**
 * Returns the URL for POST-ing a new request to the current Open311 server
 */
- (NSURL *)getPostServiceRequestURL
{
    NSURL *url = [self.baseURL URLByAppendingPathComponent:[NSString stringWithFormat:@"requests.json"]];
    if ([self.params length] != 0) {
        url = [NSURL URLWithString:[[url absoluteString] stringByAppendingString:self.params]];
    }
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
