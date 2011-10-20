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
#import "SynthesizeSingleton.h"
#import "Settings.h"

@implementation Open311
SYNTHESIZE_SINGLETON_FOR_CLASS(Open311);

@synthesize endpoint=_endpoint;
@synthesize baseURL=_baseURL;
@synthesize services=_services;

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void) dealloc
{
    [_baseURL release];
    [_endpoint release];
    [_services release];
    [super dealloc];
}

/**
 * Clears out all the current data and reloads Open311 data from the provided URL
 */
- (void)reload:(NSURL *)url
{
    self.endpoint = nil;
    self.baseURL = nil;
    self.services = nil;

    // Load the discovery data
    DLog(@"Open311:reload:%@",[url absoluteString]);
    NSURL *discoveryURL = [url URLByAppendingPathComponent:@"discovery.json"];
    DLog(@"Loading URL: %@",discoveryURL);
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:discoveryURL];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(handleDiscoverySuccess:)];
    [request startAsynchronous];
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
    // Load all the service definitions
    if (self.baseURL) {
        NSURL *servicesURL = [self.baseURL URLByAppendingPathComponent:@"services.json"];
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

@end
