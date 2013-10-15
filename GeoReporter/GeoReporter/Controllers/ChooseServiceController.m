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

#import "ChooseServiceController.h"
#import "Preferences.h"
#import "Strings.h"
#import "NewReportController.h"

@implementation ChooseServiceController

static NSString * const kCellIdentifier   = @"service_cell";
static NSString * const kSegueToNewReport = @"SegueToNewReport";

Report *report;

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	//make view controller start below navigation bar; this works in iOS 7
	if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
		self.edgesForExtendedLayout = UIRectEdgeNone;
	}
	
	
	_open311 = [Open311 sharedInstance];
	_currentServerName = [[Preferences sharedInstance] getCurrentServer][kOpen311_Name];
	_services = [_open311 getServicesForGroup:self.group];
	self.navigationItem.title = self.group;
	
	//add empty footer so that empty rows will not be shown at the end of the table
	[self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
}

- (void)viewWillAppear:(BOOL)animated
{
	if (![_currentServerName isEqualToString:[[Preferences sharedInstance] getCurrentServer][kOpen311_Name]]) {
		_currentServerName = nil;
		[self.navigationController popViewControllerAnimated:NO];
	}
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [_services count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
	NSDictionary *service = _services[indexPath.row];
	
	cell.textLabel      .text = service[kOpen311_ServiceName];
	cell.detailTextLabel.text = service[kOpen311_Description];
	
	return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		// The device is an iPad running iOS 3.2 or later.
		[self.delegate didSelectService:_services[tableView.indexPathForSelectedRow.row]];
	}
	else {
		// The device is an iPhone or iPod touch.
		NSDictionary* service =_services[[[self.tableView indexPathForSelectedRow] row]];
		if ([[service objectForKey:kOpen311_Metadata] boolValue]) {
			HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
			[self.navigationController.view addSubview:HUD];
			HUD.delegate = self;
			HUD.labelText = @"Loading";
			[HUD show:YES];
            
            [_open311 getServiceDefinition:service withCompletion:^(NSDictionary * serviceDefinition) {
                report = [[Report alloc] initWithService:service serviceDefinition:serviceDefinition];
				[MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
				[self performSegueWithIdentifier:kSegueToNewReport sender:self];
            }];
		}
		else {
            report = [[Report alloc] initWithService:service serviceDefinition:nil];
			[self performSegueWithIdentifier:kSegueToNewReport sender:self];
		}
		
	}
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

# pragma mark Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		// The device is an iPad running iOS 3.2 or later.
	}
	else {
		// The device is an iPhone or iPod touch.
		NewReportController *controller = [segue destinationViewController];
        controller.report = report;
	}
}

- (void)setGroup:(NSString *)group
{
	_group = group;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		// The device is an iPad running iOS 3.2 or later.
		_open311 = [Open311 sharedInstance];
		
		_currentServerName = [[Preferences sharedInstance] getCurrentServer][kOpen311_Name];
		
		_services = [_open311 getServicesForGroup:self.group];
		//self.navigationItem.title = self.group;
		[self.tableView reloadData];
	}
	else {
		//The device is an iPhone or iPod
	}
	
}

#pragma mark MBProgressHUDDelegate methods
- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[HUD removeFromSuperview];
	HUD.labelText = nil;
	HUD = nil;
}
@end
