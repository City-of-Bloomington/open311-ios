//
//  ReportViewController.h
//  open311
//
//  Created by Cliff Ingham on 9/6/11.
//  Copyright 2011 City of Bloomington. All rights reserved.
//

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
