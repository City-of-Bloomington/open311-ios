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

// Open311 field names that we don't want to mis-type
extern NSString * const kJurisdictionId;
extern NSString * const kApiKey;
extern NSString * const kServiceCode;
extern NSString * const kServiceName;
extern NSString * const kDescription;
extern NSString * const kAttributes;
extern NSString * const kDatatype;
extern NSString * const kSingleValueList;
extern NSString * const kMultiValueList;
extern NSString * const kRequired;
extern NSString * const kLat;
extern NSString * const kLong;
extern NSString * const kAddressString;
extern NSString * const kFirstname;
extern NSString * const kLastname;
extern NSString * const kEmail;
extern NSString * const kPhone;
extern NSString * const kDeviceId;
extern NSString * const kServiceRequestId;
extern NSString * const kToken;
extern NSString * const kAgencyResponsible;
extern NSString * const kRequestedDateTime;


@interface Open311 : NSObject <ASIHTTPRequestDelegate> {
    NSDictionary *currentServer;
    NSString *jurisdiction_id;
    NSString *api_key;
@public
    NSURL *baseURL;
    NSArray *services;
}
@property (nonatomic, retain) NSURL *baseURL;
@property (nonatomic, retain) NSArray *services;

+ (id)sharedOpen311;

- (void)reload:(NSDictionary *)server;
- (void)reset;

- (void)handleServicesSuccess:(ASIHTTPRequest *)request;
- (void)responseFormatInvalid:(ASIHTTPRequest *)request;

- (NSURL *)getServiceListURL;
- (NSURL *)getServiceDefinitionURL:(NSString *)service_code;
- (NSURL *)getPostServiceRequestURL;
- (NSURL *)getRequestIdURL:(NSString *)token;
- (NSURL *)getServiceRequestURL:(NSString *)service_request_id;

@end
