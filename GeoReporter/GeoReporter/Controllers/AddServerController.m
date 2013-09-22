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

#import "AddServerController.h"
#import "Strings.h"
#import "Preferences.h"
#import "Open311.h"

@interface AddServerController ()
@property (weak, nonatomic) IBOutlet UIView *separator0;
@property (weak, nonatomic) IBOutlet UIView *separator1;
@property (weak, nonatomic) IBOutlet UIView *separator2;
@property (weak, nonatomic) IBOutlet UIView *separator3;

@end

@implementation AddServerController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	//make view controller start below navigation bar; this wrks in iOS 7
	if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
		self.edgesForExtendedLayout = UIRectEdgeNone;
	
	self.navigationItem.title = NSLocalizedString(kUI_ButtonAddServer, nil);
	
	self.labelName         .text = NSLocalizedString(kUI_Name,           nil);
	self.labelUrl          .text = NSLocalizedString(kUI_Url,            nil);
	self.labelJurisdiction .text = NSLocalizedString(kUI_JurisdictionId, nil);
	self.labelApiKey       .text = NSLocalizedString(kUI_ApiKey,         nil);
	self.labelSupportsMedia.text = NSLocalizedString(kUI_SupportsMedia,  nil);
	
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self.tableView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}


- (IBAction)save:(id)sender
{
	if ([self.textFieldName.text isEqualToString:@""]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(kUI_ServerNameError, nil)
														message:NSLocalizedString(kUI_ServerNameErrorMessage, nil)
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(kUI_Cancel, nil)
											  otherButtonTitles:nil];
		[alert show];
	}
	else [[Open311 sharedInstance] checkServerValidity:self.textFieldUrl.text fromSender:self];
}

- (void)didFinishSaving
{
	Preferences *prefs = [Preferences sharedInstance];
	[prefs addCustomServer:@{
							 kOpen311_Name         : self.textFieldName.text,
							 kOpen311_Url          : self.textFieldUrl.text,
							 kOpen311_Jurisdiction : self.textFieldJurisdiction.text,
							 kOpen311_ApiKey       : self.textFieldApiKey.text,
							 kOpen311_SupportsMedia: [NSNumber numberWithBool:self.switchSupportsMedia.on]
							 }];
	
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view handlers

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return NSLocalizedString(kUI_ButtonAddServer, nil);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	NSString *sectionTitle = NSLocalizedString(kUI_ButtonAddServer, nil);
	
	UILabel *label = [[UILabel alloc] init];
	CGRect frame = CGRectMake(20, 8, 320, 20);
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		// The device is an iPad running iOS 3.2 or later.
		UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
		
		if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
			// The iPad is orientated Landscape
			frame = CGRectMake(120, 8, 320, 20);
		}
	}
	
	label.frame = frame;
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor colorWithRed:78/255.0f green:84/255.0f blue:102/255.0f alpha:1];
	//    label.shadowColor = [UIColor grayColor];
	//    label.shadowOffset = CGSizeMake(-1.0, 1.0);
	label.font = [UIFont fontWithName:@"Heiti SC" size:15];
	label.text = sectionTitle;
	
	UIView *view = [[UIView alloc] init];
	[view addSubview:label];
	
	return view;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.row) {
		case 0:
			[self.textFieldName becomeFirstResponder];
			break;
		case 1:
			[self.textFieldUrl becomeFirstResponder];
			break;
		case 2:
			[self.textFieldJurisdiction becomeFirstResponder];
			break;
		case 3:
			[self.textFieldApiKey becomeFirstResponder];
			break;
		default:
			break;
	}
}


@end
