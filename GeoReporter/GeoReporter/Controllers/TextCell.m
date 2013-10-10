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
 * Custom cell which shows a text view, for the Text field in the New Report
 */

#import "TextCell.h"

@implementation TextCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		// Initialization code
		
	}
	return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	[super setSelected:selected animated:animated];
	
	// Configure the view for the selected state
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.delegate.currentTextEntry = textView;
}

- (void) textViewDidEndEditing:(UITextView *)textView
{
    self.delegate.currentTextEntry = nil;
	[self.delegate didProvideValue:textView.text fromField:self.fieldname];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //hides keyboard when another part of layout was touched
    [_text endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

@end
