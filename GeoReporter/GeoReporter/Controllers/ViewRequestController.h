//
//  ViewRequestController.h
//  GeoReporter
//
//  Created by Cliff Ingham on 2/12/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Report.h"

@interface ViewRequestController : UITableViewController <ServiceRequestDelegate>
@property Report *report;
@property NSInteger reportIndex;
- (void)startRefreshingServiceRequest;
@end
