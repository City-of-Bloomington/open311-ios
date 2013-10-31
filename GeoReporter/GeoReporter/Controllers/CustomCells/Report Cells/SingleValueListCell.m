/**
 * @copyright 2013 City of Bloomington, Indiana. All Rights Reserved
 * @author Marius Constantinescu <constantinescu.marius@gmail.com>
 * @license http://www.gnu.org/licenses/gpl.txt GNU/GPLv3, see LICENSE.txt
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 *
 * Custom cell which shows a single value choice list, for the
 * Single Value List field in the New Report
 */

#import "SingleValueListCell.h"
#import "Strings.h"

@implementation SingleValueListCell

static NSString * const kInnerCellIdentifier = @"inner_cell";

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return SINGLE_VALUE_INNER_CELL_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.attribute[kOpen311_Values] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kInnerCellIdentifier forIndexPath:indexPath];
	
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
									  reuseIdentifier:kInnerCellIdentifier];
	}
	
	cell.textLabel.text = self.attribute[kOpen311_Values][indexPath.row][kOpen311_Name];
	NSObject *key = self.attribute[kOpen311_Values][indexPath.row][kOpen311_Key];
	if ([key isKindOfClass:[NSNumber class]]) {
		key = [(NSNumber *)key stringValue];
	}
	if ([key isEqual:self.selectedOption]) {
		cell.imageView.image = [UIImage imageNamed:@"radio_selected"];
	}
	else {
		cell.imageView.image = [UIImage imageNamed:@"radio_unselected"];
	}
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSObject *key = self.attribute[kOpen311_Values][indexPath.row][kOpen311_Key];
	if ([key isKindOfClass:[NSNumber class]]) {
		key = [(NSNumber *)key stringValue];
	}
	if ([key isEqual:self.selectedOption]) {
		[self.delegate didProvideValue:nil fromField:self.fieldname] ;
	}
	else {
		[self.delegate didProvideValue:(NSString *)key fromField:self.fieldname] ;
	}
	
}

- (void)setAttribute:(NSDictionary *)attribute
{
	_attribute = attribute;
	[self.tableViewInsideCell reloadData];
}

- (void)setSelectedOption:(NSString *)selectedOption
{
	_selectedOption = selectedOption;
	[self.tableViewInsideCell reloadData];
}

@end
