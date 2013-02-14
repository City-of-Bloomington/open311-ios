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
    NSMutableArray  *archivedServiceRequests;
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
    archivedServiceRequests = [NSMutableArray arrayWithArray:[[Preferences sharedInstance] getArchivedServiceRequests]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[Preferences sharedInstance] saveArchivedServiceRequests:archivedServiceRequests];
}

#pragma mark - Table handling functions

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

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [archivedServiceRequests removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}
@end
