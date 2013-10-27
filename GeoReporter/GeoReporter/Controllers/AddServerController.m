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

@implementation AddServerController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	//make view controller start below navigation bar; this works in iOS 7
	if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
		self.edgesForExtendedLayout = UIRectEdgeNone;
	}
	
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
	//check if server has no name
	if ([self.textFieldName.text isEqualToString:@""]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(kUI_ServerNameError, nil)
														message:NSLocalizedString(kUI_ServerNameErrorMessage, nil)
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(kUI_Cancel, nil)
											  otherButtonTitles:nil];
		[alert show];
	}
	//else check if url is valid
	else if ([NSURL URLWithString:self.textFieldUrl.text] == nil) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(kUI_ServerURLError, nil)
														message:NSLocalizedString(kUI_ServerURLErrorMessage, nil)
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(kUI_Cancel, nil)
											  otherButtonTitles:nil];
		[alert show];
	}
	else {
        [[Open311 sharedInstance] checkServerValidity:self.textFieldUrl.text fromSender:self];   
    }
}

- (void)didFinishSaving
{
	Preferences *prefs = [Preferences sharedInstance];
	[prefs addCustomServer:@{
                             kOpen311_Name         : [self getTextFromTextField:self.textFieldName],
                             kOpen311_Url          : [self getTextFromTextField:self.textFieldUrl],
                             kOpen311_Jurisdiction : [self getTextFromTextField:self.textFieldJurisdiction],
                             kOpen311_ApiKey       : [self getTextFromTextField:self.textFieldApiKey],
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
	label.font = [UIFont fontWithName:@"Heiti SC" size:15];
	label.text = sectionTitle;
	
	UIView *view = [[UIView alloc] init];
	[view addSubview:label];
	
	return view;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    switch (indexPath.row) {
        case 0: [_textFieldName         becomeFirstResponder]; break;
        case 1: [_textFieldUrl          becomeFirstResponder]; break;
        case 2: [_textFieldJurisdiction becomeFirstResponder]; break;
        case 3: [_textFieldApiKey       becomeFirstResponder]; break;
        default:
            break;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGPoint location = [self.tableView convertPoint:textField.frame.origin fromView:textField.superview];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if      (textField == _textFieldName)         { [_textFieldUrl          becomeFirstResponder]; }
    else if (textField == _textFieldUrl)          { [_textFieldJurisdiction becomeFirstResponder]; }
    else if (textField == _textFieldJurisdiction) { [_textFieldApiKey       becomeFirstResponder]; }
    else { [textField resignFirstResponder]; }
    return TRUE;
}

#pragma mark - additional methods

- (NSString *)getTextFromTextField:(UITextField *)textField {
    return textField.text.length ? textField.text : @"";
}

@end
