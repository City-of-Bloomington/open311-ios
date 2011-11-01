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

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"


@interface Open311 : NSObject <ASIHTTPRequestDelegate> {
    NSDictionary *currentServer;
    NSString *params;
    NSString *jurisdiction_id;
    NSString *api_key;
@public
    NSDictionary *endpoint;
    NSURL *baseURL;
    NSArray *services;
}
@property (nonatomic, retain) NSDictionary *endpoint;
@property (nonatomic, retain) NSURL *baseURL;
@property (nonatomic, retain) NSArray *services;

+ (id)sharedOpen311;

- (void)reload:(NSDictionary *)server;
- (void)reset;

- (void)handleDiscoverySuccess:(ASIHTTPRequest *)request;
- (void)handleServicesSuccess:(ASIHTTPRequest *)request;

- (NSURL *)getServiceDefinitionURL:(NSString *)service_code;
- (NSURL *)getPostServiceRequestURL;
- (NSURL *)getRequestIdURL:(NSString *)token;
- (NSURL *)getServiceRequestURL:(NSString *)service_request_id;

@end
