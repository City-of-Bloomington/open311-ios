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
 * Custom cell which shows a text field, for the String field in the New Report
 */

#import <UIKit/UIKit.h>
#import "TextEntryDelegate.h"

#define STRING_CELL_TEXT_FIELD_HEIGHT 30
#define STRING_CELL_HEADER 20
#define STRING_CELL_BOTTOM_SPACE 4

@interface StringCell : UITableViewCell <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *header;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) id<TextEntryDelegate>delegate;
@property (strong, nonatomic) NSString* fieldname;
@end
