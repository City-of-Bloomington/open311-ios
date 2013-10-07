//
//  ServiceRequest.h
//  GeoReporter
//
//  Created by Cliff Ingham on 2/4/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFHTTPClient.h>

@protocol ServiceRequestDelegate <NSObject>
@required
- (void)didReceiveServiceRequest:(NSDictionary *)serviceRequest;
- (void)didReceiveServiceRequestId:(NSString *)serviceRequestId;
@end

@interface Report : NSObject
@property NSDictionary *server;
@property NSDictionary *service;
@property NSDictionary *serviceDefinition;
@property NSMutableDictionary *serviceRequest;
@property NSMutableDictionary *postData;
@property AFHTTPClient *httpClient;
@property NSMutableDictionary *parameters;

- (id)initWithService:(NSDictionary *)service;
- (id)initWithDictionary:(NSDictionary *)dictionary;
- (void) checkAnonymousReporting;
- (NSString *)attributeValueForKey:(NSString *)key atIndex:(NSInteger)index;
- (NSDictionary *)asDictionary;

- (AFHTTPClient *)getHttpClient;
- (NSMutableDictionary *)getEndpointParameters;
- (void)startLoadingServiceRequest:(NSString *)serviceRequestId  delegate:(id<ServiceRequestDelegate>)delegate;
- (void)startLoadingServiceRequestIdFromToken:(NSString *)token  delegate:(id<ServiceRequestDelegate>)delegate;
@end
