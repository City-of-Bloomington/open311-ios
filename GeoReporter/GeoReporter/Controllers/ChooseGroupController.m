//
//  ChooseGroupController.m
//  GeoReporter
//
//  Created by Cliff Ingham on 2/1/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import "ChooseGroupController.h"
#import "Strings.h"
#import "Open311.h"
#import "ChooseServiceController.h"

@interface ChooseGroupController ()

@end

@implementation ChooseGroupController {
    Open311 *open311;
}
static NSString * const kCellIdentifier       = @"group_cell";
static NSString * const kSegueToChooseService = @"SegueToChooseService";

- (void)viewDidLoad
{
    [super viewDidLoad];
    open311 = [Open311 sharedInstance];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [open311.groups count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    NSString *group = open311.groups[indexPath.row];
    NSString *serviceList = @"";
    for (NSDictionary *service in [open311 getServicesForGroup:group]) {
        serviceList = [serviceList stringByAppendingFormat:@"%@,", service[kOpen311_ServiceName]];
    }
    
    cell.textLabel      .text = group;
    cell.detailTextLabel.text = serviceList;
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ChooseServiceController *controller = [segue destinationViewController];
    controller.group = [open311.groups objectAtIndex:[[self.tableView indexPathForSelectedRow] row]];
}

@end
