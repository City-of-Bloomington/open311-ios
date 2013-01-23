//
//  Strings.m
//  GeoReporter
//
//  Created by Cliff Ingham on 1/22/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import "Strings.h"
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

@implementation Strings


+ (NSString *) getStringForKey:(NSString *)key
{
    return NSLocalizedString(key, nil);
}
@end
