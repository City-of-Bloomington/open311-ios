//
//  ReportController.h
//  GeoReporter
//
//  Created by Cliff Ingham on 1/25/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreLocation/CoreLocation.h>
#import "ServiceRequest.h"
#import "LocationController.h"
#import "TextEntryDelegate.h"
#import "MultiValueDelegate.h"

@interface ReportController : UITableViewController <UINavigationControllerDelegate,
                                                     UIActionSheetDelegate,
                                                     UIImagePickerControllerDelegate,
                                                     LocationChooserDelegate,
                                                     TextEntryDelegate,
                                                     MultiValueDelegate>
@property NSDictionary *service;
@property ServiceRequest *serviceRequest;
- (IBAction)done:(id)sender;
- (void)postSucceeded;
- (void)postFailed;

- (void)popViewAndReloadTable;
- (void)refreshMediaThumbnail;
@end
