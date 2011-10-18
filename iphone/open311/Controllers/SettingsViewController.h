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

@interface SettingsViewController : UIViewController <UITextFieldDelegate> {
    UITextField *firstname;
    UITextField *lastname;
    UITextField *email;
    UITextField *phone;
}

@property (nonatomic, retain) IBOutlet UITextField *firstname;
@property (nonatomic, retain) IBOutlet UITextField *lastname;
@property (nonatomic, retain) IBOutlet UITextField *email;
@property (nonatomic, retain) IBOutlet UITextField *phone;

@end
