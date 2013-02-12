//
//  ServiceRequest.m
//  GeoReporter
//
//  Created by Cliff Ingham on 2/4/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import "ServiceRequest.h"
#import "Preferences.h"
#import "Strings.h"
#import "Open311.h"

@implementation ServiceRequest
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
- (id)initWithService:(NSDictionary *)service
{
    self = [super init];
    if (self) {
        _service  = service;
        
        if ([_service[kOpen311_Metadata] boolValue]) {
            Open311 *open311 = [Open311 sharedInstance];
            _serviceDefinition = open311.serviceDefinitions[_service[kOpen311_ServiceCode]];
        }
        
        _postData = [[NSMutableDictionary alloc] init];
        _postData[kOpen311_ServiceCode] = _service[kOpen311_ServiceCode];
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *firstname = [prefs stringForKey:kOpen311_FirstName];
        NSString *lastname  = [prefs stringForKey:kOpen311_LastName];
        NSString *email     = [prefs stringForKey:kOpen311_Email];
        NSString *phone     = [prefs stringForKey:kOpen311_Phone];
        if (firstname != nil) { _postData[kOpen311_FirstName] = firstname; }
        if (lastname  != nil) { _postData[kOpen311_LastName]  = lastname; }
        if (email     != nil) { _postData[kOpen311_Email]     = email; }
        if (phone     != nil) { _postData[kOpen311_Phone]     = phone; }
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
            if ([value[kOpen311_Key] isEqualToString:key]) {
                return value[kOpen311_Name];
            }
        }
    }
    return nil;
}

@end
