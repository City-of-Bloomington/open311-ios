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

#import "ChooseServiceController.h"
#import "Preferences.h"
#import "Open311.h"
#import "Strings.h"
#import "ReportController.h"

@interface ChooseServiceController ()

@end

@implementation ChooseServiceController {
    Open311 *open311;
    NSString *currentServerName;
    NSArray *services;
}
static NSString * const kCellIdentifier = @"service_cell";
static NSString * const kSegueToReport  = @"SegueToReport";

- (void)viewDidLoad
{
    [super viewDidLoad];
    open311 = [Open311 sharedInstance];
    
    currentServerName = [[Preferences sharedInstance] getCurrentServer][kOpen311_Name];
    
    services = [open311 getServicesForGroup:self.group];
    self.navigationItem.title = self.group;
}

- (void)viewWillAppear:(BOOL)animated
{
    if (![currentServerName isEqualToString:[[Preferences sharedInstance] getCurrentServer][kOpen311_Name]]) {
        currentServerName = nil;
        [self.navigationController popViewControllerAnimated:NO];
    }
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [services count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    NSDictionary *service = services[indexPath.row];
    
    cell.textLabel      .text = service[kOpen311_ServiceName];
    cell.detailTextLabel.text = service[kOpen311_Description];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ReportController *report = [segue destinationViewController];
    report.service = services[[[self.tableView indexPathForSelectedRow] row]];
}

@end
