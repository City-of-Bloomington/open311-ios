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

@interface HomeController : UITableViewController
@property (weak, nonatomic) IBOutlet UILabel *reportLabel;
@property (weak, nonatomic) IBOutlet UILabel *archiveLabel;
@property (weak, nonatomic) IBOutlet UILabel *reportingAsLabel;
@property (weak, nonatomic) IBOutlet UILabel *personalInfoLabel;

- (void)serviceListReady;
- (void)startBusyIcon;
- (void)refreshPersonalInfo;
@end
