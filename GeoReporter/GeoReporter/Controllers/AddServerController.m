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
							 kOpen311_Name         : self.textFieldName.text,
							 kOpen311_Url          : self.textFieldUrl.text,
							 kOpen311_Jurisdiction : self.textFieldJurisdiction.text,
							 kOpen311_ApiKey       : self.textFieldApiKey.text,
							 kOpen311_SupportsMedia: [NSNumber numberWithBool:self.switchSupportsMedia.on]
							 }];
	
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view handlers

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

@end
