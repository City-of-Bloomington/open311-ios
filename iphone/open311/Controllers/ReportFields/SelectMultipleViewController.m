/**
 * @copyright 2011-2012 City of Bloomington, Indiana. All Rights Reserved
 * @author Cliff Ingham <inghamn@bloomington.in.gov>
 * @license http://www.gnu.org/licenses/gpl.txt GNU/GPLv3, see LICENSE.txt
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */

#import "SelectMultipleViewController.h"

@implementation SelectMultipleViewController

- (void)dealloc
{
    [values release];
    [table release];
    [super dealloc];
}

/**
 * Saves all the chosen rows to the reportForm
 *
 * We need to go through all the rows of the table and add
 * each of the selected rows to an array.
 * Then, save that array in the report
 */
- (void)done
{
    NSMutableArray *selections = [NSMutableArray array];
    for (int i=0; i<[table numberOfRowsInSection:0]; i++) {
        if ([[table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]] accessoryType] == UITableViewCellAccessoryCheckmark) {
            [selections addObject:[values objectAtIndex:i]];
        }
    }
    [[self.reportForm objectForKey:@"data"] setObject:selections forKey:self.fieldname];
    [super done];
}


#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    values = [self.entry objectForKey:@"values"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    values = nil;
    [super viewWillDisappear:animated];
}


#pragma mark - Table View Handlers

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

/**
 * Draws what would be the label for this view
 *
 * The Base view will have populated a label, expecting it to be applied to a 
 * label in the view.  We don't have one in this view, but there's no reason
 * to populate another variable
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.entry objectForKey:@"label"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [values count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = [[values objectAtIndex:indexPath.row] objectForKey:@"name"];
    
    NSMutableArray *selections = [[self.reportForm objectForKey:@"data"] objectForKey:self.fieldname];
    for (NSDictionary *value in selections) {
        if ([[[values objectAtIndex:indexPath.row] objectForKey:@"key"] isEqualToString:[value objectForKey:@"key"]]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            break;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = (cell.accessoryType == UITableViewCellAccessoryNone)
        ? UITableViewCellAccessoryCheckmark
        : UITableViewCellAccessoryNone;
}

@end
