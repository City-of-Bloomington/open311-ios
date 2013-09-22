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
 * Custom cell which shows a multi value choice list, for the
 * Multi Value List field in the New Report
 */

#import "MultiValueListCell.h"
#import "Strings.h"

@implementation MultiValueListCell

static NSString * const kInnerCellIdentifier = @"inner_cell";

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		// Initialization code
	}
	return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	[super setSelected:selected animated:animated];
	
	// Configure the view for the selected state
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return MULTI_VALUE_INNER_CELL_HEIGHT;
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
	if ([self.selectedOptions containsObject:key]) {
		cell.imageView.image = [UIImage imageNamed:@"checkbox_selected"];
	}
	else {
		cell.imageView.image = [UIImage imageNamed:@"checkbox_unselected"];
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
	
	NSMutableArray* selected = [self.selectedOptions mutableCopy];
	if (selected != nil) {
		if ([selected containsObject:key]) {
			[selected removeObject:key];
		}
		else {
			[selected addObject:key];
		}
	}
	else {
		selected = [[NSMutableArray alloc] init];
		[selected addObject:key];
	}
	
	[self.delegate didProvideValues:selected fromField:self.fieldname];	
}

- (void)setAttribute:(NSDictionary *)attribute
{
	_attribute = attribute;
	[self.tableViewInsideCell reloadData];
}

- (void)setSelectedOptions:(NSArray *)selectedOptions
{
	_selectedOptions = selectedOptions;
	[self.tableViewInsideCell reloadData];
}

@end

