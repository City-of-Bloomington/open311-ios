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

#import "MultiValueListController.h"
#import "Strings.h"

@interface MultiValueListController ()

@end

@implementation MultiValueListController {
    NSMutableArray *selectedValues; // The array of keys the user has previously chosen
}
static NSString * const kCellIdentifier = @"valueChoice_cell";

- (void)viewDidLoad
{
    self.label.text = self.attribute[kOpen311_Description];
}

- (void)viewWillAppear:(BOOL)animated
{
    selectedValues = [NSMutableArray arrayWithArray:self.currentValue];
}

- (IBAction)done:(id)sender
{
    // Build a new array of selections by reading from the tableView
    NSMutableArray *selections = [NSMutableArray array];
    int count = [self.tableView numberOfRowsInSection:0];
    for (int i=0; i<count; i++) {
        if ([[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]] accessoryType] == UITableViewCellAccessoryCheckmark) {
            [selections addObject:self.attribute[kOpen311_Values][i][kOpen311_Key]];
        }
    }
    [self.delegate didProvideValues:[NSArray arrayWithArray:selections]];
}

#pragma mark - Table View Handlers
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.attribute[kOpen311_Description];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.attribute[kOpen311_Values] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    NSString *key = self.attribute[kOpen311_Values][indexPath.row][kOpen311_Key];
    cell.textLabel.text = key;
    if ([selectedValues containsObject:key]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = (cell.accessoryType == UITableViewCellAccessoryNone)
        ? UITableViewCellAccessoryCheckmark
        : UITableViewCellAccessoryNone;
}

@end
