//
//  Open311.h
//  GeoReporter
//
//  Created by Cliff Ingham on 1/30/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "Report.h"

extern NSString * const kNotification_PostSucceeded;
extern NSString * const kNotification_PostFailed;

@interface Open311 : NSObject
@property (readonly) NSDictionary *endpointParameters;
@property (readonly) NSMutableArray *groups;
@property (readonly) NSMutableDictionary *serviceDefinitions;
@property AFHTTPClient *httpClient;
@property NSDictionary *currentServer;
@property NSArray *serviceList;

+ (id)sharedInstance;

- (void)loadServer:(NSDictionary *)server withCompletion:(void(^)(void)) completion;
- (void)loadFailedWithError:(NSError *)error;

- (void)checkServerValidity:(NSString *) serverURL fromSender:(id)sender;

- (void)loadServiceListWithCompletion:(void(^)(void)) completion;
- (void)loadGroups;
- (NSArray *)getServicesForGroup:(NSString *)group;
- (void)getServiceDefinition:(NSDictionary *)service withCompletion:(void(^)(NSDictionary *))completion;

- (void)startPostingServiceRequest:(Report *)report;
- (NSMutableURLRequest *)preparePostForReport:(Report *)report withMedia:(UIImage *)media;
- (void)postReport:(Report *)report withPost:(NSMutableURLRequest *)post;
- (void)postFailedWithError:(NSError *)error forOperation:(AFHTTPRequestOperation *)operation;


@end
