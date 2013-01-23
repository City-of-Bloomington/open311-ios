//
//  Strings.h
//  GeoReporter
//
//  Created by Cliff Ingham on 1/22/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import <Foundation/Foundation.h>
extern NSString * const kUI_Settings;
extern NSString * const kUI_Report;
extern NSString * const kUI_Archive;
extern NSString * const kUI_About;
extern NSString * const kUI_TitleHome;
extern NSString * const kUI_PersonalInfo;
extern NSString * const kUI_Servers;
extern NSString * const kUI_ButtonAddServer;
extern NSString * const kUI_ButtonAcceptError;
extern NSString * const kUI_FirstName;
extern NSString * const kUI_LastName;
extern NSString * const kUI_Email;
extern NSString * const kUI_Phone;
extern NSString * const kUI_Name;
extern NSString * const kUI_Url;
extern NSString * const kUI_JurisdictionId;
extern NSString * const kUI_ApiKey;
extern NSString * const kUI_Format;
extern NSString * const kUI_SupportsMedia;
extern NSString * const kUI_DialogLoadingServices;
extern NSString * const kUI_DialogPostingService;
extern NSString * const kUI_ChooseMediaSource;
extern NSString * const kUI_Camera;
extern NSString * const kUI_Gallery;
extern NSString * const kUI_Location;
extern NSString * const kUI_ReportStatus;
extern NSString * const kUI_ReportAttributes;
extern NSString * const kUI_ReportDescription;
extern NSString * const kUI_ReportDate;
extern NSString * const kUI_Submit;
extern NSString * const kUI_Cancel;
extern NSString * const kUI_Save;
extern NSString * const kUI_Pending;
extern NSString * const kUI_Yes;
extern NSString * const kUI_No;
extern NSString * const kUI_Uncategorized;
extern NSString * const kUI_FailureLoadingServices;
extern NSString * const kUI_FailurePostingService;
extern NSString * const kUI_Error403;

@interface Strings : NSObject
+ (NSString *) getStringForKey:(NSString *)key;
@end
