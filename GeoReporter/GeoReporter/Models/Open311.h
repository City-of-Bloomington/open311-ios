/**
 * @copyright 2013 City of Bloomington, Indiana. All Rights Reserved
 * @author Cliff Ingham <inghamn@bloomington.in.gov>
 * @license http://www.gnu.org/licenses/gpl.txt GNU/GPLv3, see LICENSE.txt
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "AFHTTPRequestOperationManager.h"
#import "Report.h"

extern NSString * const kNotification_PostSucceeded;
extern NSString * const kNotification_PostFailed;

@interface Open311 : NSObject
@property (readonly) NSDictionary *endpointParameters;
@property (readonly) NSMutableArray *groups;
@property (readonly) NSMutableDictionary *serviceDefinitions;
@property AFHTTPRequestOperationManager *manager;
@property NSDictionary *currentServer;
@property NSArray *serviceList;

+ (id)sharedInstance;

- (AFHTTPRequestOperationManager *)getRequestManager;

- (void)loadServer:(NSDictionary *)server withCompletion:(void(^)(void)) completion;
- (void)operationFailed:(AFHTTPRequestOperation *)operation withError:(NSError *)error titleForAlert:(NSString *)title;

- (void)loadServiceListWithCompletion:(void(^)(void)) completion;
- (void)loadGroups;
- (NSArray *)getServicesForGroup:(NSString *)group;
- (void)getServiceDefinition:(NSDictionary *)service withCompletion:(void(^)(NSDictionary *))completion;

- (void)startPostingServiceRequest:(Report *)report;
- (void)postReport:(Report *)report withMedia:(UIImage *)media;
- (void)postFailedWithError:(NSError *)error forOperation:(AFHTTPRequestOperation *)operation;

@end
