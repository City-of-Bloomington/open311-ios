/**
 * Takes a saved report and looks up the latest information
 *
 * After posting a report, we only save minimal information.
 * Every time the user views a report, we want to query for the latest
 * information and update out saved copy of the report.
 *
 * @copyright 2011 City of Bloomington, Indiana. All Rights Reserved
 * @author Cliff Ingham <inghamn@bloomington.in.gov>
 * @license http://www.gnu.org/licenses/gpl.txt GNU/GPLv3, see LICENSE.txt
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */

#import "SingleReportViewController.h"
#import "Open311.h"
#import "SBJson.h"
#import "Settings.h"

@implementation SingleReportViewController
@synthesize serviceName;
@synthesize submissionDate;
@synthesize status;
@synthesize address;
@synthesize department;
@synthesize imageView;

- (id)initWithReportAtIndex:(NSMutableDictionary *)myReport index:(NSInteger)index
{
    self = [super init];
    if (self) {
        report = myReport;
        reportIndex = index;
    }
    return self;
}

- (void)dealloc {
    [report release];
    [serviceName release];
    [submissionDate release];
    [status release];
    [address release];
    [department release];
    [imageView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/**
 * Check if the report is for the current server
 * 
 * If this report is for the current server, go ahead and look up
 * the report information. Otherwise, we need to switch to 
 * the server for this report
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self refreshViewWithReportData];

    NSString *currentServerURL = [[[Settings sharedSettings] currentServer] objectForKey:@"URL"];
    NSString *reportURL = [[report objectForKey:@"server"] objectForKey:@"URL"];
    
    if ([reportURL isEqualToString:currentServerURL]) {
        [self queryServerForReportInformation];
    }
    else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(discoveryFinishedLoading:) name:@"discoveryFinishedLoading" object:nil];
        [[Open311 sharedOpen311] reload:[report objectForKey:@"server"]];
    }
}

- (void)discoveryFinishedLoading:(NSNotification *)notification
{
    [[Settings sharedSettings] setCurrentServer:[report objectForKey:@"server"]];
    [self queryServerForReportInformation];
}

/**
 * Queries the Open311 server for either the request info
 *
 * If we only have a token, ask for the request_id.
 * If we have a request_id, ask for the full report information.
 */
- (void)queryServerForReportInformation
{
    Open311 *open311 = [Open311 sharedOpen311];
    NSURL *url = [NSURL alloc];
    
    if ([[report objectForKey:@"service_request_id"] length] != 0) {
        url = [open311 getServiceRequestURL:[report objectForKey:@"service_request_id"]];
    }
    else {
        url = [open311 getRequestIdURL:[report objectForKey:@"token"]];
    }
    
    DLog(@"Loading %@", url);
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(handleReportInfoSuccess:)];
    [request setDidFailSelector:@selector(handleReportInfoFailure:)];
    [request startAsynchronous];
}

/**
 * Refreshes the view with whatever information we have saved about the report
 */
- (void)refreshViewWithReportData
{
    NSString *service_name = [[report objectForKey:@"service"] objectForKey:@"service_name"];
    [self.navigationItem setTitle:service_name];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:kCFDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    submissionDate.text = [dateFormatter stringFromDate:[report objectForKey:@"date"]];
    [dateFormatter release];

    serviceName.text = service_name;
    status.text = [report objectForKey:@"status"] ? [report objectForKey:@"status"] : @"";
    address.text = [report objectForKey:@"address"] ? [report objectForKey:@"address"] : @"";
    department.text = [report objectForKey:@"agency_responsible"] ? [report objectForKey:@"agency_responsible"] : @"";
    
    if ([status.text isEqualToString:@"closed"]) {
        status.textColor = [UIColor greenColor];
    }
    else {
        status.textColor = [UIColor redColor];
    }

    // Download the image, if we haven't already
    if (!imageView.image && [[report objectForKey:@"media_url"] length]!=0) {
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[report objectForKey:@"media_url"]]];
        [request setDelegate:self];
        [request setDidFinishSelector:@selector(handleImageDownloadSuccess:)];
        // We're just going to ignore image download errors for now
        [request startAsynchronous];
    }
}

/**
 * Updates the report with information from the server, then refreshes the view
 */
- (void)handleReportInfoSuccess:(ASIHTTPRequest *)request;
{
    DLog(@"Handling response string %@", [request responseString]);
    NSArray *data = [[request responseString] JSONValue];
    NSDictionary *service_request = [data objectAtIndex:0];
    if (service_request) {
        NSString *service_name = [service_request objectForKey:@"service_name"];
        // Handle a response that has full report data
        if (service_name) {
            [report setObject:service_name forKey:@"service_name"];
            
            if ([service_request objectForKey:@"requested_datetime"] != [NSNull null]) {
                [report setObject:[service_request objectForKey:@"requested_datetime"] forKey:@"requested_datetime"];
            }
            if ([service_request objectForKey:@"status"] != [NSNull null]) {
                [report setObject:[service_request objectForKey:@"status"] forKey:@"status"];
            }
            if ([service_request objectForKey:@"address"] != [NSNull null]) {
                [report setObject:[service_request objectForKey:@"address"] forKey:@"address"];
            }
            if ([service_request objectForKey:@"agency_responsible"] != [NSNull null]) {
                [report setObject:[service_request objectForKey:@"agency_responsible"] forKey:@"agency_responsible"];
            }
            if ([service_request objectForKey:@"media_url"] != [NSNull null]) {
                [report setObject:[service_request objectForKey:@"media_url"] forKey:@"media_url"];
            }
            
            [self saveReport];
            [self refreshViewWithReportData];
        }
        // If we only had a token, the response will only include a request_id
        // Update the request_id in the report, and send another query for the full information
        else if ([service_request objectForKey:@"service_request_id"]) {
            [report setObject:[service_request objectForKey:@"service_request_id"] forKey:@"service_request_id"];
            [self saveReport];
            [self queryServerForReportInformation];
        }
        // We got a response back, but it doesn't match what we're expecting
        else {
            [self handleReportInfoFailure:request];
        }
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Report was garbled" message:[[request url] absoluteString] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

/**
 * Updates the report in Settings, so the data gets saved
 */
- (void)saveReport
{
    [[[Settings sharedSettings] myRequests] replaceObjectAtIndex:reportIndex withObject:report];
}

/**
 * Tries to display any Open311 error that might be in the response
 */
- (void)handleReportInfoFailure:(ASIHTTPRequest *)request
{
    NSString *message = [[request url] absoluteString];
    if ([request responseString]) {
        DLog(@"%@",[request responseString]);
        NSArray *errors = [[request responseString] JSONValue];
        NSString *description = [[errors objectAtIndex:0] objectForKey:@"description"];
        if (description) {
            message = description;
        }
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not load report" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

/**
 * Updates the view with the downloaded image
 */
- (void)handleImageDownloadSuccess:(ASIHTTPRequest *)request
{
    UIImage *image = [UIImage imageWithData:[request responseData]];
    if (image) {
        imageView.image = image;
    }
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [self setServiceName:nil];
    [self setSubmissionDate:nil];
    [self setStatus:nil];
    [self setAddress:nil];
    [self setDepartment:nil];
    [self setImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
