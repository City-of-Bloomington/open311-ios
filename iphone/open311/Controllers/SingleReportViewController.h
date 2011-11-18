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
#import "ASIHTTPRequest.h"

@interface SingleReportViewController : UIViewController <UIAlertViewDelegate,ASIHTTPRequestDelegate> {
    NSMutableDictionary *report;
    NSInteger reportIndex;
    
    UILabel *serviceName;
    UILabel *submissionDate;
    UILabel *status;
    UILabel *address;
    UILabel *department;
    UIImageView *imageView;
}

@property (nonatomic, retain) IBOutlet UILabel *serviceName;
@property (nonatomic, retain) IBOutlet UILabel *submissionDate;
@property (nonatomic, retain) IBOutlet UILabel *status;
@property (nonatomic, retain) IBOutlet UILabel *address;
@property (nonatomic, retain) IBOutlet UILabel *department;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;

- (id)initWithReportAtIndex:(NSMutableDictionary *)myReport index:(NSInteger)index;

- (void)discoveryFinishedLoading:(NSNotification *)notification;

- (void)refreshViewWithReportData;
- (void)queryServerForReportInformation;
- (void)saveReport;

- (void)handleReportInfoSuccess:(ASIHTTPRequest *)request;
- (void)handleReportInfoFailure:(ASIHTTPRequest *)request;
- (void)handleImageDownloadSuccess:(ASIHTTPRequest *)request;

@end
