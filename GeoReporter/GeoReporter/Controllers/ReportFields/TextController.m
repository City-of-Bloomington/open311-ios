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

#import "TextController.h"
#import "Strings.h"

@interface TextController ()

@end

@implementation TextController

- (void)viewDidLoad
{
	//		adjust the height of the label
	
	// Calculate the expected size based on the font and linebreak mode of the label
	// FLT_MAX here simply means no constraint in height
	CGSize maximumLabelSize = CGSizeMake(296, FLT_MAX);
	
	CGSize expectedLabelSize = [self.attribute[kOpen311_Description] sizeWithFont:self.label.font constrainedToSize:maximumLabelSize lineBreakMode:self.label.lineBreakMode];
	
	
	//		adjust the label to the new height
	
	CGRect newLabelFrame = self.label.frame;
	newLabelFrame.size.height = expectedLabelSize.height;
	self.label.frame = newLabelFrame;
	
	
	//		set text in label
	
	self.label   .text = self.attribute[kOpen311_Description];
	
	
	//		move the textView to the bottom, according to the new size of the label
	CGRect newTextViewFrame = self.textView.frame;
	newTextViewFrame.origin.y = newTextViewFrame.origin.y + newLabelFrame.size.height;
	self.textView.frame = newTextViewFrame;
	
	//		add gesture recognizer to close the keyboard
	
	UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
	gestureRecognizer.cancelsTouchesInView = NO;
	[self.view addGestureRecognizer:gestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.textView.text = self.currentValue;
    [self.textView becomeFirstResponder];
}

- (IBAction)done:(id)sender
{
    [self.delegate didProvideValue:self.textView.text];
}

- (void) hideKeyboard {
	[self.textView resignFirstResponder];
}
@end
