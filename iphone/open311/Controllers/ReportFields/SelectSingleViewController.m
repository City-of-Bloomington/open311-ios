/**
 * @copyright 2011 City of Bloomington, Indiana. All Rights Reserved
 * @author Cliff Ingham <inghamn@bloomington.in.gov>
 * @license http://www.gnu.org/licenses/gpl.txt GNU/GPLv3, see LICENSE.txt
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */

#import "SelectSingleViewController.h"

@implementation SelectSingleViewController

- (void)dealloc
{
    [values release];
    [picker release];
    [super dealloc];
}

- (void)done
{
    [[self.reportForm objectForKey:@"data"] setObject:[values objectAtIndex:[picker selectedRowInComponent:0]] forKey:self.fieldname];
    [super done];
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    DLog(@"Loading values for %@",self.fieldname);
    values = [[self.reportForm objectForKey:@"values"] objectForKey:self.fieldname];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    values = nil;
    [super viewWillDisappear:animated];
}

#pragma mark - Picker handling functions

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [values count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[values objectAtIndex:row] objectForKey:@"name"];
}

@end
