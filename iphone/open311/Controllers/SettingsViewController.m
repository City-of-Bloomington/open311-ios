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

#import "SettingsViewController.h"
#import "Settings.h"
#import "AboutViewController.h"

@implementation SettingsViewController
@synthesize firstname;
@synthesize lastname;
@synthesize email;
@synthesize phone;

- (void)dealloc
{
    [firstname release];
    [lastname release];
    [email release];
    [phone release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationItem setTitle:@"Settings"];
    Settings *settings = [Settings sharedSettings];
    self.firstname.text = settings.first_name;
    self.lastname.text = settings.last_name;
    self.email.text = settings.email;
    self.phone.text = settings.phone;
}

- (void)viewDidUnload
{
    [self setFirstname:nil];
    [self setLastname:nil];
    [self setEmail:nil];
    [self setPhone:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    Settings *settings = [Settings sharedSettings];
    [settings setFirst_name:self.firstname.text];
    [settings setLast_name:self.lastname.text];
    [settings setEmail:self.email.text];
    [settings setPhone:self.phone.text];
    [settings save];
    [super viewWillDisappear:animated];
}

#pragma mark - Text Field Handlers

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.firstname) {
        [self.lastname becomeFirstResponder];
    }
    if (textField == self.lastname) {
        [self.email becomeFirstResponder];
    }
    if (textField == self.email) {
        [self.phone becomeFirstResponder];
    }
    if (textField == self.phone) {
        [textField resignFirstResponder];
        return FALSE;
    }
    return TRUE;
}

- (IBAction)showAboutScreen:(id)sender {
    [self.navigationController pushViewController:[[AboutViewController alloc] init] animated:YES];
}
@end
