/**
 * @copyright 2011 City of Bloomington, Indiana. All Rights Reserved
 * @author Cliff Ingham <inghamn@bloomington.in.gov>
 * @license http://www.gnu.org/licenses/gpl.txt GNU/GPLv3, see LICENSE.txt
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */
#import <UIKit/UIKit.h>
#import "BusyViewController.h"

@interface HomeViewController : UIViewController {
    BusyViewController *busyController;
    UIButton *splashImageButton;
}

@property (nonatomic, retain) IBOutlet UIButton *splashImageButton;

- (void)gotoSettings;
- (IBAction)gotoNewReport:(id)sender;
- (IBAction)gotoFeedback:(id)sender;
- (IBAction)sendEmail:(id)sender;
- (void)discoveryFinishedLoading:(NSNotification *)notification;

@end
