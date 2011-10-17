//
//  HomeViewController.m
//  open311
//
//  Created by Cliff Ingham on 9/6/11.
//  Copyright 2011 City of Bloomington. All rights reserved.
//

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    Settings *settings = [Settings sharedSettings];
    if (!settings.currentServer) {
        self.tabBarController.selectedIndex = 3;
    }
    else {
        [[Open311 sharedOpen311] reload:[NSURL URLWithString:[settings.currentServer objectForKey:@"URL"]]];
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(gotoSettings)];
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
    self.navigationItem.title = [[[Settings sharedSettings] currentServer] objectForKey:@"Name"];
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
