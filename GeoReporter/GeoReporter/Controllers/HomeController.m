/**
 * @copyright 2013 City of Bloomington, Indiana. All Rights Reserved
 * @author Cliff Ingham <inghamn@bloomington.in.gov>
 * @license http://www.gnu.org/licenses/gpl.txt GNU/GPLv3, see LICENSE.txt
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */

#import "HomeController.h"
#import "Strings.h"
#import "Preferences.h"
#import "Open311.h"
#import <AFNetworking/AFJSONRequestOperation.h>

@interface HomeController ()

@end

static NSString * const kSegueToSettings = @"SegueToSettings";
static NSString * const kSegueToChooseGroup = @"SegueToChooseGroup";
static NSString * const kSegueToContainerView = @"SegueToChooseGroupiPad";
static NSString * const kSegueToServers = @"SegueToServers";
static NSString * const kSegueToArchive = @"SegueToArchive";
static NSString * const kUnwindSegueFromServersToHome = @"UnwindSegueFromServersToHome";
static NSString * const kUnwindSegueFromReportToHome = @"UnwindSegueFromReportToHome";
static NSString * const kSegueToAbout = @"SegueToAbout";




@implementation HomeController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	//make view controller start below navigation bar; this works in iOS 7
	if ([self respondsToSelector:@selector(edgesForExtendedLayout)]){
		self.edgesForExtendedLayout = UIRectEdgeNone;
		self.navigationController.navigationBar.tintColor = [UIColor orangeColor];
	}
	
	[self loadServer];
	self.reportLabel     .text = NSLocalizedString(kUI_Report,  nil);
	self.archiveLabel    .text = NSLocalizedString(kUI_Archive, nil);
	self.reportingAsLabel.text = NSLocalizedString(kUI_ReportingAs, nil);
	self.serversLabel.text = NSLocalizedString(kUI_Servers, nil);
	
//	UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: @"Back" style: UIBarButtonItemStyleBordered target: nil action: nil];
//	
//	[[self navigationItem] setBackBarButtonItem: newBackButton];
}

/**
 * Check if the user has chosen a server.
 * If not, redirect them to the servers tab;
 * otherwise, load all service information from the server.
 */
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self refreshPersonalInfo];
}

- (IBAction)tapAboutButton:(id)sender
{
	[self performSegueWithIdentifier:kSegueToAbout sender:self];
}

- (void) loadServer
{
	Preferences *preferences = [Preferences sharedInstance];
	
	NSDictionary *currentServer = [preferences getCurrentServer];
	if (currentServer == nil) {
		[self performSegueWithIdentifier:kSegueToServers sender:self];
	}
	else {
		self.navigationItem.title = currentServer[kOpen311_Name];
		
		HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
		[self.navigationController.view addSubview:HUD];
		HUD.delegate = self;
		HUD.labelText = @"Loading";
		[HUD show:YES];
		Open311 *open311 = [Open311 sharedInstance];
		[open311 loadAllMetadataForServer:currentServer withCompletion:^() { [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES]; }];
		NSString *filename = currentServer[kOpen311_SplashImage];
		if (!filename) { filename = @"open311"; }
		[self.splashImage setImage:[UIImage imageNamed:filename]];
	}
}

- (void)refreshPersonalInfo
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *text = @"";
	NSString *firstname = [defaults stringForKey:kOpen311_FirstName];
	NSString *lastname  = [defaults stringForKey:kOpen311_LastName];
	if ([firstname length] > 0 || [lastname length] > 0) {
		text = [text stringByAppendingFormat:@"%@ %@", firstname, lastname];
	}
	if ([text length] == 0) {
		text = @"anonymous";
	}
	
	self.personalInfoLabel.text = text;
	[self.tableView reloadData];
}

#pragma mark - Table Handler Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 1 && indexPath.row == 0) {
		
		CGSize size = [self.personalInfoLabel.text sizeWithFont:self.personalInfoLabel.font
											  constrainedToSize:CGSizeMake(300, 140)
												  lineBreakMode:self.personalInfoLabel.lineBreakMode];
		NSInteger height = size.height + 28;
		return (CGFloat)height;
	}
	return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
				// The device is an iPad running iOS 3.2 or later.
				[self performSegueWithIdentifier:kSegueToContainerView sender:self];
			}
			else {
				// The device is an iPhone or iPod touch.
				[self performSegueWithIdentifier:kSegueToChooseGroup sender:self];
			}
		} else if (indexPath.row == 1) {
			[self performSegueWithIdentifier:kSegueToArchive sender:self];
		}
	} else if (indexPath.section == 1) {
		if (indexPath.row == 0) {
			[self performSegueWithIdentifier:kSegueToSettings sender:self];
		} else if (indexPath.row == 1) {
			[self performSegueWithIdentifier:kSegueToServers sender:self];
		}
	}
}


#pragma mark -unwind segue
-(IBAction) didReturnFromServersController:(UIStoryboardSegue *)sender
{
	if ([sender.identifier isEqualToString:kUnwindSegueFromServersToHome])
		[self loadServer];
}

-(IBAction) didReturnAfterSendingReport:(UIStoryboardSegue *)sender
{
	
	//    if ([sender.identifier isEqualToString:kUnwindSegueFromReportToHome])
	//      TODO: do something if it should open the Archive
}

#pragma mark MBProgressHUDDelegate methods
- (void)hudWasHidden:(MBProgressHUD *)hud
{
	// Remove HUD from screen when the HUD was hidded
	[HUD removeFromSuperview];
	HUD.labelText = nil;
	HUD = nil;
}


@end
