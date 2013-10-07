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

#import <UIKit/UIKit.h>
#import "GroupDelegate.h"
#import "Open311.h"

@interface ChooseGroupController : UITableViewController
@property (strong, nonatomic) NSString* chosenGroup;
@property (weak, nonatomic) id <GroupDelegate> delegate;
@property Open311 *open311;

- (IBAction)cancel:(id)sender;

@end
