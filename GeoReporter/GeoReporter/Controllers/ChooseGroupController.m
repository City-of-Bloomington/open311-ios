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
#import "Open311.h"
#import "ChooseServiceController.h"

@interface ChooseGroupController ()
@property Open311 *open311;
@end

@implementation ChooseGroupController

static NSString * const kCellIdentifier       = @"group_cell";
static NSString * const kSegueToChooseService = @"SegueToChooseService";

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	//make view controller start below navigation bar; this wrks in iOS 7
	if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
		self.edgesForExtendedLayout = UIRectEdgeNone;
	}
	
	_open311 = [Open311 sharedInstance];
	self.navigationItem.title = NSLocalizedString(kUI_Report, nil);
	
	
	//add empty footer so that empty rows will not be shown at the end of the table
	[self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
}

- (void)viewWillAppear:(BOOL)animated
{
	if ([_open311.groups count] == 1) {
		[self performSegueWithIdentifier:kSegueToChooseService sender:self];
	}
	else {
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			// The device is an iPad running iOS 3.2 or later.
			//we don't deselect the row, because we want it to still be shown when we go back form new report
		}
		else {
			// The device is an iPhone or iPod touch.
			[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
			//TODO: why reload data every time?
			//[self.tableView reloadData];
		}
	}
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		// The device is an iPad running iOS 3.2 or later.
		self.chosenGroup = _open311.groups[indexPath.row];
		[self.delegate didSelectGroup:self.chosenGroup];
	}
	else {
		// The device is an iPhone or iPod touch.
		[self performSegueWithIdentifier:kSegueToChooseService sender:self];
	}
}

# pragma mark Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		// The device is an iPad running iOS 3.2 or later.
		
	}
	else {
		// The device is an iPhone or iPod touch.
		ChooseServiceController *controller = [segue destinationViewController];
		controller.group = [_open311.groups objectAtIndex:[[self.tableView indexPathForSelectedRow] row]];
	}
	
}

@end
