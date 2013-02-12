//
//  ArchiveController.m
//  GeoReporter
//
//  Created by Cliff Ingham on 1/25/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import "ArchiveController.h"
#import "ServiceRequest.h"
#import "Preferences.h"
#import "Strings.h"
#import "Open311.h"

@interface ArchiveController ()

@end

@implementation ArchiveController {
    NSArray *archivedServiceRequests;
    NSDateFormatter *dateFormatterDisplay;
    NSDateFormatter *dateFormatterISO;
}
NSString * const kCellIdentifier = @"archive_cell";

- (void)viewDidLoad
{
    dateFormatterDisplay = [[NSDateFormatter alloc] init];
    [dateFormatterDisplay setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatterDisplay setTimeStyle:NSDateFormatterShortStyle];
    
    dateFormatterISO = [[NSDateFormatter alloc] init];
    [dateFormatterISO setDateFormat:kDate_ISO8601];
}

- (void)viewWillAppear:(BOOL)animated
{
    archivedServiceRequests = [[Preferences sharedInstance] getArchivedServiceRequests];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [archivedServiceRequests count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    ServiceRequest *sr = [[ServiceRequest alloc] initWithDictionary:archivedServiceRequests[indexPath.row]];
    
    cell.textLabel.text = sr.service[kOpen311_ServiceName];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@: %@",
                                     [dateFormatterDisplay stringFromDate:[dateFormatterISO dateFromString:sr.serviceRequest[kOpen311_RequestedDatetime]]],
                                     sr.server[kOpen311_Name]];
    return cell;
}

@end
