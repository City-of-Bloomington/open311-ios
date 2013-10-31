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

#import <UIKit/UIKit.h>
#import "TextEntryDelegate.h"

#define TEXT_CELL_TEXT_VIEW_HEIGHT 70
#define TEXT_CELL_HEADER 20
#define TEXT_CELL_BOTTOM_SPACE 4

@interface TextCell : UITableViewCell <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *header;
@property (weak, nonatomic) IBOutlet UITextView *text;
@property (weak, nonatomic) id<TextEntryDelegate>delegate;
@property (strong, nonatomic) NSString* fieldname;

@end
