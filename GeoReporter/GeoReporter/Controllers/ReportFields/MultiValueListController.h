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

#import <UIKit/UIKit.h>
#import "MultiValueDelegate.h"

@interface MultiValueListController : UITableViewController
@property (strong, nonatomic) NSDictionary *attribute;
@property (strong, nonatomic) NSArray *currentValue;
@property (weak, nonatomic) IBOutlet UILabel *label;
- (IBAction)done:(id)sender;
@property id<MultiValueDelegate>delegate;
@end
