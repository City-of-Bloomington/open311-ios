/**
 * @copyright 2011 City of Bloomington, Indiana. All Rights Reserved
 * @author Cliff Ingham <inghamn@bloomington.in.gov>
 * @license http://www.gnu.org/licenses/gpl.txt GNU/GPLv3, see LICENSE.txt
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "BusyViewController.h"

@interface ReportViewController : UIViewController <UINavigationControllerDelegate,
                                                    UITableViewDelegate,
                                                    UITableViewDataSource,
                                                    UIImagePickerControllerDelegate,
                                                    MKReverseGeocoderDelegate> {
    
    IBOutlet UITableView *reportTableView;
    IBOutlet UILabel *serviceDescriptionLabel;
    BusyViewController *busyController;
}
@property (nonatomic, retain) NSString *previousServerURL;
@property (nonatomic, retain) NSDictionary *currentService;
@property (nonatomic, retain) NSDictionary *service_definition;
@property (nonatomic, retain) NSMutableDictionary *reportForm;

- (void)chooseService;
- (void)initReportForm;
- (void)didSelectService:(NSNumber *)selectedIndex:(id)element;

- (void)loadServiceDefinition:(NSString *)service_code;
- (void)handleServiceDefinitionSuccess:(ASIHTTPRequest *)request;
- (void)handleServiceDefinitionFailure:(ASIHTTPRequest *)request;
- (void)handlePostReportSuccess:(ASIFormDataRequest *)post;
- (void)handlePostReportFailure:(ASIFormDataRequest *)post;

@end
