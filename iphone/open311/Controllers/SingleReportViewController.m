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

#import "SingleReportViewController.h"
#import "Open311.h"
#import "SBJson.h"

@implementation SingleReportViewController
@synthesize serviceName;
@synthesize submissionDate;
@synthesize status;
@synthesize address;
@synthesize department;
@synthesize imageView;

- (id)initWithServiceRequestId:(NSString *)request_id
{
    self = [super init];
    if (self) {
        service_request_id = request_id;
    }
    return self;
}

- (void)dealloc {
    [service_request_id release];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    NSString *path = [NSString stringWithFormat:@"requests/%@.json",service_request_id];
    NSURL *url = [[NSURL URLWithString:[[[Open311 sharedOpen311] endpoint] objectForKey:@"url"]] URLByAppendingPathComponent:path];
    DLog(@"Loading %@", url);

    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(handleReportInfoSuccess:)];
    [request setDidFailSelector:@selector(handleReportInfoFailure:)];
    [request startAsynchronous];
}

/**
 * Updates the view with information from the report
 */
- (void)handleReportInfoSuccess:(ASIHTTPRequest *)request;
{
    DLog(@"Loaded single report %@", [request responseString]);
    NSArray *data = [[request responseString] JSONValue];
    NSDictionary *service_request = [data objectAtIndex:0];
    if (service_request) {
        NSString *service_name = [service_request objectForKey:@"service_name"];
        if (service_name) {
            [self.navigationItem setTitle:service_name];
            serviceName.text = service_name;
            submissionDate.text = [service_request objectForKey:@"requested_datetime"];
            status.text = [service_request objectForKey:@"status"];
            address.text = [service_request objectForKey:@"address"];
            department.text = [service_request objectForKey:@"agency_responsible"];
            
            NSString *media_url = [service_request objectForKey:@"media_url"];
            if (media_url) {
                ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:media_url]];
                [request setDelegate:self];
                [request setDidFinishSelector:@selector(handleImageDownloadSuccess:)];
                // We're just going to ignore image download errors for now
                [request startAsynchronous];
            }
        }
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
