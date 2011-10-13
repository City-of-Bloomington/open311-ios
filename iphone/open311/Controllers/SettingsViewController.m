//
//  SettingsViewController.m
//  open311
//
//  Created by Cliff Ingham on 10/12/11.
//  Copyright 2011 City of Bloomington. All rights reserved.
//

#import "SettingsViewController.h"
#import "Settings.h"

@implementation SettingsViewController
@synthesize firstname;
@synthesize lastname;
@synthesize email;
@synthesize phone;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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

@end
