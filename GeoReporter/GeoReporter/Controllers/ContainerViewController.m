/**
 * @copyright 2013 City of Bloomington, Indiana. All Rights Reserved
 * @author Marius Constantinescu <constantinescu.marius@gmail.com>
 * @license http://www.gnu.org/licenses/gpl.txt GNU/GPLv3, see LICENSE.txt
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */

#import "ContainerViewController.h"
#import "ChooseServiceController.h"
#import "ChooseGroupController.h"
#import "NewReportController.h"
#import "Open311.h"
#import "Strings.h"

@interface ContainerViewController ()

@end

@implementation ContainerViewController
static NSString * const kEmbeddedSegueToGroup = @"EmbeddedSegueToGroup";
static NSString * const kEmbeddedSegueToService = @"EmbeddedSegueToService";
static NSString * const kSegueToNewReport = @"SegueToNewReport";




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	
	//make view controller start below navigation bar; this works in iOS 7
	if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
		self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

# pragma mark GroupDelegate

- (void) didSelectGroup:(NSString *) group
{
	self.selectedGroup = group;
	self.serviceController.group = self.selectedGroup;
}

# pragma mark ServiceDelegate

- (void) didSelectService:(NSDictionary *) service
{
	self.selectedService = service;
	if ([[service objectForKey:kOpen311_Metadata] boolValue]) {
		HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
		[self.navigationController.view addSubview:HUD];
		HUD.delegate = self;
		HUD.labelText = @"Loading";
		[HUD show:YES];
		Open311* open311 = [Open311 sharedInstance];
		[open311 getMetadataForService:service WithCompletion:^() {
			[MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
			[self performSegueWithIdentifier:kSegueToNewReport sender:self];
		}];
	}
	else {
		[self performSegueWithIdentifier:kSegueToNewReport sender:self];
	}
}



- (void) prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:kEmbeddedSegueToService])    {
		self.serviceController = segue.destinationViewController;
		self.serviceController.delegate = self;
	}
	else if ([segue.identifier isEqualToString:kEmbeddedSegueToGroup]){
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			// The device is an iPad running iOS 3.2 or later.
			ChooseGroupController* groupController = segue.destinationViewController;
			groupController.delegate = self;
		}
	}
	else if ([segue.identifier isEqualToString:kSegueToNewReport]){
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			// The device is an iPad running iOS 3.2 or later.
			NewReportController *report = [segue destinationViewController];
			report.service = self.selectedService;
		}
	}
	
	
}

#pragma mark MBProgressHUDDelegate methods
- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[HUD removeFromSuperview];
	HUD.labelText = nil;
	HUD = nil;
}

@end
