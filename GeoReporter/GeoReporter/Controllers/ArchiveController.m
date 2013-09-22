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

#import "ArchiveController.h"
#import "Report.h"
#import "Preferences.h"
#import "Strings.h"
#import "Open311.h"
#import "ViewRequestController.h"

@interface ArchiveController ()
@property NSMutableArray  *archivedReports;
@property NSDateFormatter *dateFormatterDisplay;
@property NSDateFormatter *dateFormatterISO;
@end

@implementation ArchiveController

NSString * const kCellIdentifier = @"archive_cell";

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	//make view controller start below navigation bar; this wrks in iOS 7
	if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
		self.edgesForExtendedLayout = UIRectEdgeNone;
	
	self.navigationItem.title = NSLocalizedString(kUI_Archive, nil);
	
	_dateFormatterDisplay = [[NSDateFormatter alloc] init];
	[_dateFormatterDisplay setDateStyle:NSDateFormatterMediumStyle];
	[_dateFormatterDisplay setTimeStyle:NSDateFormatterShortStyle];
	
	_dateFormatterISO = [[NSDateFormatter alloc] init];
	[_dateFormatterISO setDateFormat:kDate_ISO8601];
	
	//add empty footer so that empty rows will not be shown at the end of the table
	[self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	_archivedReports = [NSMutableArray arrayWithArray:[[Preferences sharedInstance] getArchivedReports]];
	[self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[[Preferences sharedInstance] saveArchivedReports:_archivedReports];
	
	[super viewWillDisappear:animated];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	ViewRequestController *controller = [segue destinationViewController];
	NSInteger reportIndex = [[self.tableView indexPathForSelectedRow] row];
	Report *sr = [[Report alloc] initWithDictionary:[_archivedReports objectAtIndex:reportIndex]];
	
	[controller setReport:sr];
	[controller setReportIndex:reportIndex];
}

#pragma mark - Table handling functions

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [_archivedReports count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
	// Reports from the archive must be hydrated before using
	Report *sr = [[Report alloc] initWithDictionary:_archivedReports[indexPath.row]];
	
	cell.textLabel.text = sr.service[kOpen311_ServiceName];
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@: %@",
								 [_dateFormatterDisplay stringFromDate:[_dateFormatterISO dateFromString:sr.serviceRequest[kOpen311_RequestedDatetime]]],
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
		[_archivedReports removeObjectAtIndex:indexPath.row];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
