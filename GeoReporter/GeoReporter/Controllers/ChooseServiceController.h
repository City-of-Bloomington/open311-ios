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
#import "ServiceDelegate.h"
#import "MBProgressHUD.h"
#import "Open311.h"

@interface ChooseServiceController : UITableViewController<MBProgressHUDDelegate> {
    MBProgressHUD *HUD;
}

@property (nonatomic) NSString *group;
@property Open311 *open311;
@property NSString *currentServerName;
@property NSArray *services;

@end
