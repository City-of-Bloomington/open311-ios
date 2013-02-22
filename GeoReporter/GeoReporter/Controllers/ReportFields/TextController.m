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
    self.label   .text = self.attribute[kOpen311_Description];
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
@end
