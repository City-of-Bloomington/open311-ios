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
 * Custom cell which shows a single value choice list, for the
 * Single Value List field in the New Report
 */

#import <UIKit/UIKit.h>
#import "TextEntryDelegate.h"

#define SINGLE_VALUE_INNER_CELL_HEIGHT 28
#define SINGLE_VALUE_INNER_CELL_HEADER 20
#define SINGLE_VALUE_INNER_CELL_BOTTOM_SPACE 4

@interface SingleValueListCell : UITableViewCell <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *header;
@property (weak, nonatomic) IBOutlet UITableView *tableViewInsideCell;
@property (strong, nonatomic) NSDictionary *attribute;
@property (weak, nonatomic) id <TextEntryDelegate> delegate;
@property (strong, nonatomic) NSString* fieldname;
@property (strong, nonatomic) NSString* selectedOption;
@end
