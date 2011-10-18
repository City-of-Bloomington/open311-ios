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
#import "HomeViewController.h"
#import "Settings.h"
#import "Open311.h"
#import "SettingsViewController.h"
#import "ReportViewController.h"

@implementation HomeViewController
@synthesize splashImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Home" image:[UIImage imageNamed:@"home_w.png"] tag:0];
    }
    return self;
}

- (void)dealloc
{
    [busyController release];
    [splashImage release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/**
 * Does a fresh reload of the Open311 discovery information
 *
 * This could take a while.  Remember to display a Busy view
 * until we get something back.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    DLog(@"viewDidLoad");
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(gotoSettings)];
    
}

- (void)discoveryFinishedLoading:(NSNotification *)notification
{
    DLog(@"Finished Loading Discovery");
    [busyController.view removeFromSuperview];
    busyController = nil;
}

- (void)viewDidUnload
{
    [self setSplashImage:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated
{
    Settings *settings = [Settings sharedSettings];
    
    // If the user hasn't chosen a server, send them to the MyServer screen
    if (!settings.currentServer) {
        self.tabBarController.selectedIndex = 3;
    }
    // The user has chosen a server.
    else {
        self.navigationItem.title = [settings.currentServer objectForKey:@"Name"];
        
        // Show a busy screen and start up a full reload of discovery information
        busyController = [[BusyViewController alloc] init];
        [self.view addSubview:busyController.view];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(discoveryFinishedLoading:) name:@"discoveryFinishedLoading" object:nil];
        
        [[Open311 sharedOpen311] reload:[NSURL URLWithString:[settings.currentServer objectForKey:@"URL"]]];
    }

    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
     
- (void)gotoSettings
{
    [self.navigationController pushViewController:[[SettingsViewController alloc] init] animated:YES];
}

- (IBAction)gotoNewReport:(id)sender
{
    DLog(@"Sending to new report");
    [self.navigationController pushViewController:[[ReportViewController alloc] init] animated:YES];
}

@end
