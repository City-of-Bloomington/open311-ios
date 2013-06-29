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
    self.navigationItem.title = NSLocalizedString(kUI_Report, nil);
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([open311.groups count] == 1) {
        [self performSegueWithIdentifier:kSegueToChooseService sender:self];
    }
    else {
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
        [self.tableView reloadData];
    }
}

- (IBAction)cancel:(id)sender
{
    //[self.tabBarController setSelectedIndex:kTab_Home];
    [self.navigationController popToRootViewControllerAnimated:YES];
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
