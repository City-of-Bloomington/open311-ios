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
#import "ChooseServiceController.h"
#import <MBProgressHUD.h>

@interface ContainerViewController : UIViewController <GroupDelegate, ServiceDelegate, MBProgressHUDDelegate> {
	MBProgressHUD *HUD;
}

@property (weak, nonatomic) NSString* selectedGroup;
@property (weak, nonatomic) NSDictionary* selectedService;
@property (strong, nonatomic) ChooseServiceController* serviceController;
@end
