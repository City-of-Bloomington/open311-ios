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

#import "ViewRequestController.h"
#import "Strings.h"
#import "Preferences.h"
#import "Media.h"

@interface ViewRequestController ()

@end

@implementation ViewRequestController {
    NSDateFormatter *dateFormatterDisplay;
    NSDateFormatter *dateFormatterISO;
    NSURL *mediaUrl;
    UIImage *media;
}
static NSString * const kCellIdentifier  = @"request_cell";
static NSString * const kMediaCell       = @"media_cell";
static NSInteger  const kImageViewTag    = 100;
static CGFloat    const kMediaCellHeight = 122;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = self.report.service[kOpen311_ServiceName];
    
    dateFormatterDisplay = [[NSDateFormatter alloc] init];
    [dateFormatterDisplay setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatterDisplay setTimeStyle:NSDateFormatterShortStyle];
    
    dateFormatterISO = [[NSDateFormatter alloc] init];
    [dateFormatterISO setDateFormat:kDate_ISO8601];
    
    [self startRefreshingServiceRequest];
    
    mediaUrl = _report.postData[kOpen311_Media];
    if (mediaUrl) {
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:mediaUrl
                 resultBlock:^(ALAsset *asset) {
                     ALAssetRepresentation *rep = [asset defaultRepresentation];
                     UIImage *original = [UIImage imageWithCGImage:[rep fullScreenImage]];
                     media = [Media resizeImage:original toBoundingBox:100];
                 }
                failureBlock:^(NSError *error) {
                    DLog(@"Failed to load media from library");
                }];
    }
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
    if (section == 0) {
        if (mediaUrl) {
            return 2;
        }
        return 1;
    }
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        NSDictionary *sr = _report.serviceRequest;
        NSDictionary *post = _report.postData;
        return (sr && sr[kOpen311_Description]) ? sr[kOpen311_Description] : post[kOpen311_Description];
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    NSDictionary *sr   = _report.serviceRequest;
    NSDictionary *post = _report.postData;
    if (indexPath.section == 0) {
        if (mediaUrl && indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:kMediaCell forIndexPath:indexPath];
            UIImageView *imageView = (UIImageView *)[cell viewWithTag:kImageViewTag];
            [imageView setImage:media];
        }
        else {
            cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
            cell.textLabel.text = NSLocalizedString(kUI_Location, nil);
            cell.detailTextLabel.text = (sr && sr[kOpen311_Address]) ? sr[kOpen311_Address] : post[kOpen311_AddressString];
        }
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = NSLocalizedString(kUI_ReportDate, nil);
                cell.detailTextLabel.text = [dateFormatterDisplay stringFromDate:[dateFormatterISO dateFromString:sr[kOpen311_RequestedDatetime]]];
                break;
                
            case 1:
                cell.textLabel.text = NSLocalizedString(kUI_ReportStatus, nil);
                cell.detailTextLabel.text = (sr && sr[kOpen311_Status]) ? sr[kOpen311_Status] : kUI_Pending;
                break;
                
            case 2:
                cell.textLabel.text = NSLocalizedString(kOpen311_AgencyResponsible, nil);
                cell.detailTextLabel.text = (sr && sr[kOpen311_AgencyResponsible]) ? sr[kOpen311_AgencyResponsible] : @"";
                break;
                
            default:
                break;
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (mediaUrl && indexPath.section==0 && indexPath.row==0) {
        return 122;
    }
    return UITableViewAutomaticDimension;
}

@end
