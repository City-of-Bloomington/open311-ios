//
//  ArchiveController.m
//  GeoReporter
//
//  Created by Cliff Ingham on 1/25/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import "ArchiveController.h"
#import "Report.h"
#import "Preferences.h"
#import "Strings.h"
#import "Open311.h"
#import "ViewRequestController.h"

@interface ArchiveController ()

@end

@implementation ArchiveController {
    NSMutableArray  *archivedReports;
    NSDateFormatter *dateFormatterDisplay;
    NSDateFormatter *dateFormatterISO;
}
NSString * const kCellIdentifier = @"archive_cell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(kUI_Archive, nil);
    
    dateFormatterDisplay = [[NSDateFormatter alloc] init];
    [dateFormatterDisplay setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatterDisplay setTimeStyle:NSDateFormatterShortStyle];
    
    dateFormatterISO = [[NSDateFormatter alloc] init];
    [dateFormatterISO setDateFormat:kDate_ISO8601];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    archivedReports = [NSMutableArray arrayWithArray:[[Preferences sharedInstance] getArchivedReports]];
    DLog(@"Displaying %d archived reports", [archivedReports count]);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[Preferences sharedInstance] saveArchivedReports:archivedReports];

    [super viewWillDisappear:animated];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ViewRequestController *controller = [segue destinationViewController];
    NSInteger reportIndex = [[self.tableView indexPathForSelectedRow] row];
    Report *sr = [[Report alloc] initWithDictionary:[archivedReports objectAtIndex:reportIndex]];
    
    [controller setReport:sr];
    [controller setReportIndex:reportIndex];
}

#pragma mark - Table handling functions

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [archivedReports count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    // Reports from the archive must be hydrated before using
    Report *sr = [[Report alloc] initWithDictionary:archivedReports[indexPath.row]];
    
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
        [archivedReports removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
