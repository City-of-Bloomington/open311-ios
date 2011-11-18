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

#import "BaseFieldViewController.h"

@implementation BaseFieldViewController
@synthesize fieldname,previousText,reportForm;

- (id)initWithFieldname:(NSString *)field report:(NSMutableDictionary *)report
{
    self = [super init];
    if (self) {
        self.reportForm = report;
        self.fieldname = field;
    }
    return self;
}

- (void)dealloc
{
    [fieldname release];
    [reportForm release];
    [label release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

# pragma mark - Button Handling Functions
/**
 * Sends them back to the report without saving changes to the text
 */
- (void)cancel
{
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 * Child view should save the next text, then call this function to 
 * go back to the report
 */
- (void)done
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Remember the starting text, so we can restore it if they cancel
    self.previousText = [[self.reportForm objectForKey:@"data"] objectForKey:self.fieldname];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
}

- (void)viewDidUnload
{
    [previousText release];
    [label release];
    label = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    label.text = [[self.reportForm objectForKey:@"labels"] objectForKey:self.fieldname];
    [super viewWillAppear:animated];
}

@end
