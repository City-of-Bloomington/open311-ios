/**
 * @copyright 2013 City of Bloomington, Indiana. All Rights Reserved
 * @author Marius Constantinescu <constantinescu.marius@gmail.com>
 * @license http://www.gnu.org/licenses/gpl.txt GNU/GPLv3, see LICENSE.txt
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */

#import "ChooseGroupController.h"
#import "Strings.h"
#import "ChooseServiceController.h"

@implementation ChooseGroupController

static NSString * const kCellIdentifier       = @"group_cell";
static NSString * const kSegueToChooseService = @"SegueToChooseService";

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	_open311 = [Open311 sharedInstance];
	
	//add empty footer so that empty rows will not be shown at the end of the table
	[self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
}

- (IBAction)cancel:(id)sender
{
	[self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [_open311.groups count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
	
	NSString *group = _open311.groups[indexPath.row];
	NSString *serviceList = @"";
	for (NSDictionary *service in [_open311 getServicesForGroup:group]) {
		serviceList = [serviceList stringByAppendingFormat:@"%@,", service[kOpen311_ServiceName]];
	}
	
	cell.textLabel      .text = group;
	cell.detailTextLabel.text = serviceList;
	
	return cell;
}

#pragma mark - Table view delegate

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ChooseServiceController *controller = [segue destinationViewController];
    controller.group = [_open311.groups objectAtIndex:[[self.tableView indexPathForSelectedRow] row]];
}

@end
