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

#import "CustomServerViewController.h"
#import "Open311.h"

@implementation CustomServerViewController
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    [name release];
    [url release];
    [jurisdiction release];
    [api_key release];
    [mediaSwitch release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [name release];
    name = nil;
    [url release];
    url = nil;
    [jurisdiction release];
    jurisdiction = nil;
    [api_key release];
    api_key = nil;
    [mediaSwitch release];
    mediaSwitch = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == name) {
        [url becomeFirstResponder];
    }
    if (textField == url) {
        [jurisdiction becomeFirstResponder];
    }
    if (textField == jurisdiction) {
        [api_key becomeFirstResponder];
    }
    if (textField == api_key) {
        [textField resignFirstResponder];
        return FALSE;
    }
    return TRUE;
}

- (IBAction)cancel:(id)sender {
    [delegate didAddServer:nil];
}

- (IBAction)save:(id)sender {
    NSMutableDictionary *temp = [[NSMutableDictionary alloc] init];

    if ([name.text length]!=0 && [url.text length]!=0) {
        [temp setObject:name.text forKey:@"Name"];
        [temp setObject:url.text forKey:@"URL"];
    }
    if ([jurisdiction.text length]!=0) {
        [temp setObject:jurisdiction.text forKey:kJurisdictionId];
    }
    if ([api_key.text length]!=0) {
        [temp setObject:api_key.text forKey:kApiKey];
    }
    [temp setValue:[NSNumber numberWithBool:[mediaSwitch isOn]] forKey:@"supports_media"];
    
    [delegate didAddServer:[NSDictionary dictionaryWithDictionary:temp]];
    [temp release];
}

@end
