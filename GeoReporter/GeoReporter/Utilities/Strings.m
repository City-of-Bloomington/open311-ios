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

#import "Strings.h"
// Keys to the Localized String file
NSString * const kUI_AddPhoto               = @"add_photo";
NSString * const kUI_ChooseMediaSource      = @"choose_media_source";
NSString * const kUI_Camera                 = @"camera";
NSString * const kUI_Gallery                = @"gallery";
NSString * const kUI_Location               = @"location";
NSString * const kUI_ReportStatus           = @"report_status";
NSString * const kUI_ReportDescription      = @"report_description";
NSString * const kUI_ReportDate             = @"report_date";
NSString * const kUI_Okay                   = @"okay";
NSString * const kUI_Cancel                 = @"cancel";
NSString * const kUI_Pending                = @"pending";
NSString * const kUI_Uncategorized          = @"uncategorized";
NSString * const kUI_FailureLoadingServices = @"failure_loading_services";
NSString * const kUI_FailurePostingService  = @"failure_posting_service";
NSString * const kUI_FailureLoadingRequest  = @"failure_loading_request";
NSString * const kUI_Error403               = @"error_403";
NSString * const kUI_URLError               = @"wrong_url";
NSString * const kUI_ServerNameError        = @"servername_error_title";
NSString * const kUI_ServerNameErrorMessage = @"servername_error_message";
NSString * const kUI_ServerURLError         = @"serverURL_error_title";
NSString * const kUI_ServerURLErrorMessage  = @"serverURL_error_message";
NSString * const kUI_HudLoadingMessage		= @"loading_message";
NSString * const kUI_ChangePhoto			= @"change_photo";
NSString * const kUI_HudSendingMessage		= @"sending";
NSString * const kUI_HudSuccessMessage		= @"send_success";
NSString * const kUI_PermissionDenied       = @"permission_denied";
NSString * const kUI_ChangePrivacySettings  = @"change_privacy_settings";

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
NSString * const kOpen311_IsAnonymous=@"isAnonymous";
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
// Key names from AvailableServers.plist
NSString * const kOpen311_Url           = @"url";
NSString * const kOpen311_SupportsMedia = @"supports_media";
NSString * const kOpen311_SplashImage   = @"splash_image";
// Key names for formats
NSString * const kOpen311_JSON = @"json";
NSString * const kOpen311_XML  = @"xml";

NSString * const kDate_ISO8601 = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";

@implementation Strings

@end
