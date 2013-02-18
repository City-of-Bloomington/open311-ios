//
//  ViewRequestController.m
//  GeoReporter
//
//  Created by Cliff Ingham on 2/12/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import "ViewRequestController.h"
#import "Strings.h"
#import "Preferences.h"

@interface ViewRequestController ()

@end

@implementation ViewRequestController {
    NSDateFormatter *dateFormatterDisplay;
    NSDateFormatter *dateFormatterISO;
}
static NSString * const kCellIdentifier = @"request_cell";

- (void)viewDidLoad
{
    dateFormatterDisplay = [[NSDateFormatter alloc] init];
    [dateFormatterDisplay setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatterDisplay setTimeStyle:NSDateFormatterShortStyle];
    
    dateFormatterISO = [[NSDateFormatter alloc] init];
    [dateFormatterISO setDateFormat:kDate_ISO8601];
    
    [self startRefreshingServiceRequest];
}

#pragma Service Request Refreshing
- (void)startRefreshingServiceRequest
{
    NSDictionary *sr = _report.serviceRequest;
    NSString *serviceRequestId = sr[kOpen311_ServiceRequestId];
    if (serviceRequestId) {
        [_report startLoadingServiceRequest:serviceRequestId delegate:self];
    }
    else {
        NSString *token = sr[kOpen311_Token];
        [_report startLoadingServiceRequestIdFromToken:token delegate:self];
    }
}

- (void)didReceiveServiceRequest:(NSDictionary *)serviceRequest
{
    for (NSString *key in [serviceRequest allKeys]) {
        _report.serviceRequest[key] = serviceRequest[key];
    }
    [[Preferences sharedInstance] saveReport:_report forIndex:_reportIndex];
    [self.tableView reloadData];
}

- (void)didReceiveServiceRequestId:(NSString *)serviceRequestId
{
    _report.serviceRequest[kOpen311_ServiceRequestId] = serviceRequestId;
    [[Preferences sharedInstance] saveReport:_report forIndex:_reportIndex];
    [_report startLoadingServiceRequest:serviceRequestId delegate:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (section == 0) ? 1 : 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    NSDictionary *sr   = _report.serviceRequest;
    NSDictionary *post = _report.postData;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(kUI_Location, nil);
            cell.detailTextLabel.text = (sr && sr[kOpen311_Address]) ? sr[kOpen311_Address] : post[kOpen311_AddressString];
        }
    }
    else {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = NSLocalizedString(kUI_ReportDate, nil);
                cell.detailTextLabel.text = [dateFormatterDisplay stringFromDate:[dateFormatterISO dateFromString:sr[kOpen311_RequestedDatetime]]];
                break;
                
            case 1:
                cell.textLabel.text = kOpen311_Status;
                cell.detailTextLabel.text = (sr && sr[kOpen311_Status]) ? sr[kOpen311_Status] : kUI_Pending;
                break;
                
            case 2:
                cell.textLabel.text = kOpen311_AgencyResponsible;
                cell.detailTextLabel.text = (sr && sr[kOpen311_AgencyResponsible]) ? sr[kOpen311_AgencyResponsible] : @"";
                break;
                
            default:
                break;
        }
    }
    return cell;
}

@end
