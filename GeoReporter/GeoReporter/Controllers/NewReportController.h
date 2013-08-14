//
//  NewReportController.h
//  GeoReporter
//
//  Created by Marius Constantinescu on 7/20/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Report.h"
#import "TextEntryDelegate.h"
#import "MultiValueDelegate.h"
#import "LocationController.h"

@interface NewReportController : UITableViewController <TextEntryDelegate,
                                                        MultiValueDelegate,
                                                        LocationChooserDelegate,
                                                        UINavigationControllerDelegate,
                                                        UIImagePickerControllerDelegate,
                                                        UIActionSheetDelegate>
@property NSDictionary *service;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *headerViewLabel;
@property Report *report;
- (IBAction)send:(id)sender;
@end
