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

@interface AddServerController : UITableViewController <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelUrl;
@property (weak, nonatomic) IBOutlet UILabel *labelJurisdiction;
@property (weak, nonatomic) IBOutlet UILabel *labelApiKey;
@property (weak, nonatomic) IBOutlet UILabel *labelSupportsMedia;

@property (weak, nonatomic) IBOutlet UITextField *textFieldName;
@property (weak, nonatomic) IBOutlet UITextField *textFieldUrl;
@property (weak, nonatomic) IBOutlet UITextField *textFieldJurisdiction;
@property (weak, nonatomic) IBOutlet UITextField *textFieldApiKey;
@property (weak, nonatomic) IBOutlet UISwitch *switchSupportsMedia;

@property (weak, nonatomic) IBOutlet UIView *separator0;
@property (weak, nonatomic) IBOutlet UIView *separator1;
@property (weak, nonatomic) IBOutlet UIView *separator2;
@property (weak, nonatomic) IBOutlet UIView *separator3;

- (IBAction)save:(id)sender;

@end
