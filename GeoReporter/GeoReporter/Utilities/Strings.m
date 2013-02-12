//
//  Strings.m
//  GeoReporter
//
//  Created by Cliff Ingham on 1/22/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import "Strings.h"
// Keys to the Localized String file
NSString * const kUI_Settings               = @"menu_settings";
NSString * const kUI_Report                 = @"menu_report";
NSString * const kUI_Archive                = @"menu_archive";
NSString * const kUI_About                  = @"menu_about";
NSString * const kUI_TitleHome              = @"title_home";
NSString * const kUI_PersonalInfo           = @"personal_info";
NSString * const kUI_Servers                = @"servers";
NSString * const kUI_ButtonAddServer        = @"button_add_server";
NSString * const kUI_ButtonAcceptError      = @"button_accept_error";
NSString * const kUI_FirstName              = @"first_name";
NSString * const kUI_LastName               = @"last_name";
NSString * const kUI_Email                  = @"email";
NSString * const kUI_Phone                  = @"phone";
NSString * const kUI_Name                   = @"name";
NSString * const kUI_Url                    = @"url";
NSString * const kUI_JurisdictionId         = @"jurisdiction_id";
NSString * const kUI_ApiKey                 = @"api_key";
NSString * const kUI_Format                 = @"format";
NSString * const kUI_SupportsMedia          = @"supports_media";
NSString * const kUI_DialogLoadingServices  = @"dialog_loading_services";
NSString * const kUI_DialogPostingService   = @"dialog_posting_service";
NSString * const kUI_AddPhoto               = @"add_photo";
NSString * const kUI_ChooseMediaSource      = @"choose_media_source";
NSString * const kUI_Camera                 = @"camera";
NSString * const kUI_Gallery                = @"gallery";
NSString * const kUI_Location               = @"location";
NSString * const kUI_ReportStatus           = @"report_status";
NSString * const kUI_ReportAttributes       = @"report_attributes";
NSString * const kUI_ReportDescription      = @"report_description";
NSString * const kUI_ReportDate             = @"report_date";
NSString * const kUI_Submit                 = @"submit";
NSString * const kUI_Cancel                 = @"cancel";
NSString * const kUI_Save                   = @"save";
NSString * const kUI_Pending                = @"pending";
NSString * const kUI_Yes                    = @"yes";
NSString * const kUI_No                     = @"no";
NSString * const kUI_Uncategorized          = @"uncategorized";
NSString * const kUI_FailureLoadingServices = @"failure_loading_services";
NSString * const kUI_FailurePostingService  = @"failure_posting_service";
NSString * const kUI_Error403               = @"error_403";

// Open311 Key Strings
// Global required fields
NSString * const kOpen311_Jurisdiction = @"jurisdiction_id";
NSString * const kOpen311_ApiKey       = @"api_key";
NSString * const kOpen311_Format       = @"format";
NSString * const kOpen311_ServiceCode  = @"service_code";
NSString * const kOpen311_ServiceName  = @"service_name";
NSString * const kOpen311_Group        = @"group";
// Global basic fields
NSString * const kOpen311_Media              = @"media";
NSString * const kOpen311_MediaUrl           = @"media_url";
NSString * const kOpen311_Latitude           = @"lat";
NSString * const kOpen311_Longitude          = @"long";
NSString * const kOpen311_Address            = @"address";
NSString * const kOpen311_AddressString      = @"address_string";
NSString * const kOpen311_Description        = @"description";
NSString * const kOpen311_ServiceNotice      = @"service_notice";
NSString * const kOpen311_AccountId 	     = @"account_id";
NSString * const kOpen311_Status 		     = @"status";
NSString * const kOpen311_StatusNotes        = @"status_notes";
NSString * const kOpen311_AgencyResponsible  = @"agency_responsible";
NSString * const kOpen311_RequestedDatetime  = @"requested_datetime";
NSString * const kOpen311_UpdatedDatetime    = @"updated_datetime";
NSString * const kOpen311_ExpectedDatetime   = @"expected_datetime";
NSString * const kOpen311_ServiceRequestId   = @"service_request_id";
NSString * const kOpen311_Token              = @"token";
// Personal Information fields
NSString * const kOpen311_FirstName = @"first_name";
NSString * const kOpen311_LastName  = @"last_name";
NSString * const kOpen311_Email     = @"email";
NSString * const kOpen311_Phone     = @"phone";
NSString * const kOpen311_DeviceId  = @"device_id";
// Custom field definition in service_definition
NSString * const kOpen311_Metadata     = @"metadata";
NSString * const kOpen311_Attributes   = @"attributes";
NSString * const kOpen311_Attribute    = @"attribute";
NSString * const kOpen311_Variable     = @"variable";
NSString * const kOpen311_Code         = @"code";
NSString * const kOpen311_Order        = @"order";
NSString * const kOpen311_Values       = @"values";
NSString * const kOpen311_Value        = @"value";
NSString * const kOpen311_Key          = @"key";
NSString * const kOpen311_Name         = @"name";
NSString * const kOpen311_Required     = @"required";
NSString * const kOpen311_Datatype     = @"datatype";
NSString * const kOpen311_String       = @"string";
NSString * const kOpen311_Number       = @"number";
NSString * const kOpen311_Datetime     = @"datetime";
NSString * const kOpen311_Text         = @"text";
NSString * const kOpen311_True         = @"true";
NSString * const kOpen311_SingleValueList = @"singlevaluelist";
NSString * const kOpen311_MultiValueList  = @"multivaluelist";
// Key names from /res/raw/available_servers.json
NSString * const kOpen311_Url           = @"url";
NSString * const kOpen311_SupportsMedia = @"supports_media";
// Key names for formats
NSString * const kOpen311_JSON = @"json";
NSString * const kOpen311_XML  = @"xml";

NSString * const kDate_ISO8601 = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";

@implementation Strings

@end
