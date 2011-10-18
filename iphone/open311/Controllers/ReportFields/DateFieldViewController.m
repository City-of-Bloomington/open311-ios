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

#import "DateFieldViewController.h"

@implementation DateFieldViewController

- (void)dealloc {
    [datePicker release];
    [super dealloc];
}

- (void)done
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:kCFDateFormatterMediumStyle];
    [[self.reportForm objectForKey:@"data"] setObject:[dateFormatter stringFromDate:datePicker.date] forKey:self.fieldname];
    [dateFormatter release];
    [super done];
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    NSString *date = [[self.reportForm objectForKey:@"data"] objectForKey:self.fieldname];
    if (date) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:kCFDateFormatterMediumStyle];
        datePicker.date = [dateFormatter dateFromString:date];
        [dateFormatter release];
    }
    [super viewWillAppear:animated];
}

- (void)viewDidUnload
{
    [datePicker release];
    datePicker = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


@end
