//
//  ChooseServiceController.m
//  GeoReporter
//
//  Created by Cliff Ingham on 2/1/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import "ChooseServiceController.h"
#import "Open311.h"
#import "Strings.h"
#import "ReportController.h"

@interface ChooseServiceController ()

@end

@implementation ChooseServiceController {
    Open311 *open311;
    NSArray *services;
}
static NSString * const kCellIdentifier = @"service_cell";
static NSString * const kSegueToReport  = @"SegueToReport";

- (void)viewDidLoad
{
    [super viewDidLoad];
    open311 = [Open311 sharedInstance];
    services = [open311 getServicesForGroup:self.group];
    self.navigationItem.title = self.group;
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
