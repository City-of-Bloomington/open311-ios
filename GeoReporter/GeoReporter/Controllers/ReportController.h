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

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreLocation/CoreLocation.h>
#import "Report.h"
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
@property Report *report;
- (IBAction)done:(id)sender;
- (void)postSucceeded;
- (void)postFailed;

- (void)popViewAndReloadTable;
- (void)refreshMediaThumbnail;
@end
