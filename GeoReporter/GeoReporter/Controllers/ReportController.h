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

@interface ReportController : UITableViewController <UINavigationControllerDelegate,
                                                     UIActionSheetDelegate,
                                                     UIImagePickerControllerDelegate,
                                                     LocationChooserDelegate>
@property NSDictionary *service;
@property ServiceRequest *serviceRequest;
@end
