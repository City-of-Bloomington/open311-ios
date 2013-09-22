/**
 * @copyright 2013 City of Bloomington, Indiana. All Rights Reserved
 * @author Marius Constantinescu <constantinescu.marius@gmail.com>
 * @license http://www.gnu.org/licenses/gpl.txt GNU/GPLv3, see LICENSE.txt
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 *
 * Cell with the anonymous switch at the bottom of a new report
 */

#import "FooterCell.h"
#import "Strings.h"

@implementation FooterCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		// Initialization code
	}
	return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		// Initialization code
		NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
		[preferences setValue:@"no" forKey:kOpen311_IsAnonymous];
	}
	return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	[super setSelected:selected animated:animated];
	
	// Configure the view for the selected state
}

- (IBAction)didChangeSwitchValue:(id)sender {
	NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
	if ([self.anonymousSwitch isOn]) {
		[preferences setValue:@"yes" forKey:kOpen311_IsAnonymous];
	}
	else {
		[preferences setValue:@"no" forKey:kOpen311_IsAnonymous];
	}
}
@end
