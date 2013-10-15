/**
 * @copyright 2013 City of Bloomington, Indiana. All Rights Reserved
 * @author Marius Constantinescu <constantinescu.marius@gmail.com>
 * @license http://www.gnu.org/licenses/gpl.txt GNU/GPLv3, see LICENSE.txt
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */

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
                                                        CLLocationManagerDelegate,
                                                        UIActionSheetDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic)   IBOutlet UIView      *headerView;
@property (weak, nonatomic)   IBOutlet UILabel     *headerViewLabel;
@property IBOutlet UITextView *currentTextEntry;
@property Report *report;

- (void)prepareFieldsForReport;
- (IBAction)send:(id)sender;
- (void)zoomMap:(MKMapView *)map toCoordinate:(CLLocationCoordinate2D)point;
@end
