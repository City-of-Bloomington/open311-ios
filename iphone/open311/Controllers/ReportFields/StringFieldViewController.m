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

#import "StringFieldViewController.h"

@implementation StringFieldViewController

- (void)dealloc {
    [input release];
    [super dealloc];
}

#pragma mark - Button handling functions
- (void)done
{
    [[self.reportForm objectForKey:@"data"] setObject:input.text forKey:self.fieldname];
    [super done];
}
#pragma mark - View lifecycle

- (void)viewDidUnload
{
    [input release];
    input = nil;
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    input.text = [[self.reportForm objectForKey:@"data"] objectForKey:self.fieldname];
    [super viewWillAppear:animated];
    [input becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self done];
    return FALSE;
}
@end
