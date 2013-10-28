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
// Keys to the Localized String file
extern NSString * const kUI_AddPhoto;
extern NSString * const kUI_ChooseMediaSource;
extern NSString * const kUI_Camera;
extern NSString * const kUI_Gallery;
extern NSString * const kUI_Location;
extern NSString * const kUI_ReportStatus;
extern NSString * const kUI_ReportDescription;
extern NSString * const kUI_ReportDate;
extern NSString * const kUI_Cancel;
extern NSString * const kUI_Pending;
extern NSString * const kUI_Uncategorized;
extern NSString * const kUI_FailureLoadingServices;
extern NSString * const kUI_FailurePostingService;
extern NSString * const kUI_Error403;
extern NSString * const kUI_URLError;
extern NSString * const kUI_ServerNameError;
extern NSString * const kUI_ServerNameErrorMessage;
extern NSString * const kUI_ServerURLError;
extern NSString * const kUI_ServerURLErrorMessage;
extern NSString * const kUI_HudLoadingMessage;
extern NSString * const kUI_ChangePhoto;
extern NSString * const kUI_HudSendingMessage;
extern NSString * const kUI_HudSuccessMessage;


// Open311 Key Strings
// Global required fields
extern NSString * const kOpen311_Jurisdiction;
extern NSString * const kOpen311_ApiKey;
extern NSString * const kOpen311_Format;
extern NSString * const kOpen311_ServiceCode;
extern NSString * const kOpen311_ServiceName;
extern NSString * const kOpen311_Group;
// Global basic fields
extern NSString * const kOpen311_Media;
extern NSString * const kOpen311_MediaUrl;
extern NSString * const kOpen311_Latitude;
extern NSString * const kOpen311_Longitude;
extern NSString * const kOpen311_Address;
extern NSString * const kOpen311_AddressString;
extern NSString * const kOpen311_Description;
extern NSString * const kOpen311_ServiceNotice;
extern NSString * const kOpen311_AccountId;
extern NSString * const kOpen311_Status;
extern NSString * const kOpen311_StatusNotes;
extern NSString * const kOpen311_AgencyResponsible;
extern NSString * const kOpen311_RequestedDatetime;
extern NSString * const kOpen311_UpdatedDatetime;
extern NSString * const kOpen311_ExpectedDatetime;
extern NSString * const kOpen311_ServiceRequestId;
extern NSString * const kOpen311_Token;
// Personal Information fields
extern NSString * const kOpen311_FirstName;
extern NSString * const kOpen311_LastName;
extern NSString * const kOpen311_Email;
extern NSString * const kOpen311_Phone;
extern NSString * const kOpen311_DeviceId;
extern NSString * const kOpen311_IsAnonymous;
// Custom field definition in service_definition
extern NSString * const kOpen311_Metadata;
extern NSString * const kOpen311_Attributes;
extern NSString * const kOpen311_Attribute;
extern NSString * const kOpen311_Variable;
extern NSString * const kOpen311_Code;
extern NSString * const kOpen311_Order;
extern NSString * const kOpen311_Values;
extern NSString * const kOpen311_Value;
extern NSString * const kOpen311_Key;
extern NSString * const kOpen311_Name;
extern NSString * const kOpen311_Required;
extern NSString * const kOpen311_Datatype;
extern NSString * const kOpen311_String;
extern NSString * const kOpen311_Number;
extern NSString * const kOpen311_Datetime;
extern NSString * const kOpen311_Text;
extern NSString * const kOpen311_True;
extern NSString * const kOpen311_SingleValueList;
extern NSString * const kOpen311_MultiValueList;
// Key names from AvailableServers.plist
extern NSString * const kOpen311_Url;
extern NSString * const kOpen311_SupportsMedia;
extern NSString * const kOpen311_SplashImage;
// Key names for formats
extern NSString * const kOpen311_JSON;
extern NSString * const kOpen311_XML;

extern NSString * const kDate_ISO8601;

@interface Strings : NSObject
@end
