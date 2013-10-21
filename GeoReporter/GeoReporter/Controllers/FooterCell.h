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

#import <UIKit/UIKit.h>

@interface FooterCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UISwitch *anonymousSwitch;
- (IBAction)didChangeSwitchValue:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *anonymousHeader;
@property (weak, nonatomic) IBOutlet UILabel *anonymousDetails;

@end
