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

@protocol CustomServerAddDelegate
- (void)didAddServer:(NSDictionary *)server;
@end


@interface CustomServerViewController : UIViewController <UITextFieldDelegate> {
    id <CustomServerAddDelegate> delegate;
    IBOutlet UITextField *name;
    IBOutlet UITextField *url;
    IBOutlet UITextField *jurisdiction;
    IBOutlet UITextField *api_key;
    IBOutlet UISwitch *mediaSwitch;
}

@property (nonatomic, retain) id <CustomServerAddDelegate> delegate;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
@end



