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

#import "TextFieldViewController.h"


@implementation TextFieldViewController

- (void)dealloc
{
    [textarea release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidUnload
{
    [textarea release];
    textarea = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    textarea.text = [[self.reportForm objectForKey:@"data"] objectForKey:self.fieldname];
    [super viewWillAppear:animated];
    [textarea becomeFirstResponder];
}


#pragma mark - Button handling functions
/**
 * Saves changes to the text and send them back to the report
 */
- (void)done
{
    [[self.reportForm objectForKey:@"data"] setObject:textarea.text forKey:self.fieldname];
    [super done];
}

@end
