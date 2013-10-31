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

#import "PersonalInfoController.h"
#import "Strings.h"

@implementation PersonalInfoController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
	
	self.textFieldFirstName.text = [preferences stringForKey:kOpen311_FirstName];
	self.textFieldLastName .text = [preferences stringForKey:kOpen311_LastName];
	self.textFieldEmail    .text = [preferences stringForKey:kOpen311_Email];
	self.textFieldPhone    .text = [preferences stringForKey:kOpen311_Phone];
}

- (void)viewWillDisappear:(BOOL)animated
{
	NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
	[preferences setValue:self.textFieldFirstName.text forKey:kOpen311_FirstName];
	[preferences setValue:self.textFieldLastName .text forKey:kOpen311_LastName];
	[preferences setValue:self.textFieldEmail    .text forKey:kOpen311_Email];
	[preferences setValue:self.textFieldPhone    .text forKey:kOpen311_Phone];
	
	[super viewWillDisappear:animated];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self.tableView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Table view handlers

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if      (indexPath.row == 0) { [self.textFieldFirstName becomeFirstResponder]; }
    else if (indexPath.row == 1) { [self.textFieldLastName  becomeFirstResponder]; }
    else if (indexPath.row == 2) { [self.textFieldEmail     becomeFirstResponder]; }
    else if (indexPath.row == 3) { [self.textFieldPhone     becomeFirstResponder]; }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGPoint location = [self.tableView convertPoint:textField.frame.origin fromView:textField.superview];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
	if (textField == _textFieldPhone) {
		NSString * formattedPhoneNumber = _textFieldPhone.text;
		_textFieldPhone.text = [[[[formattedPhoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"(" withString:@""] stringByReplacingOccurrencesOfString:@")" withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@""];
	}
	
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	if (textField == _textFieldPhone) {
		
		NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];
		
		NSLocale *locale = [NSLocale currentLocale];
		NSString *countryCode = [locale objectForKey: NSLocaleCountryCode];
		
		NSError *aError = nil;
		NBPhoneNumber *myNumber = [phoneUtil parse:_textFieldPhone.text defaultRegion:countryCode error:&aError];
		
		if (aError == nil) {
			// Check https://github.com/me2day/libPhoneNumber-iOS#sample-usage for usage example
			
			if ([phoneUtil isValidNumber:myNumber]) {
				_textFieldPhone.text = [phoneUtil format:myNumber numberFormat:NBEPhoneNumberFormatINTERNATIONAL
												   error:&aError];
			}
		}
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if      (textField == _textFieldFirstName) { [_textFieldLastName becomeFirstResponder]; }
    else if (textField == _textFieldLastName ) { [_textFieldEmail    becomeFirstResponder]; }
    else if (textField == _textFieldEmail    ) { [_textFieldPhone    becomeFirstResponder]; }
    else { [textField resignFirstResponder]; }
    return TRUE;
}

@end
