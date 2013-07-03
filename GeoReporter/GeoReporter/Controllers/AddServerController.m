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

#import "AddServerController.h"
#import "Strings.h"
#import "Preferences.h"
#import "Open311.h"

@interface AddServerController ()
@property (weak, nonatomic) IBOutlet UIView *separator0;
@property (weak, nonatomic) IBOutlet UIView *separator1;
@property (weak, nonatomic) IBOutlet UIView *separator2;
@property (weak, nonatomic) IBOutlet UIView *separator3;

@end

@implementation AddServerController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = NSLocalizedString(kUI_ButtonAddServer, nil);
    
    self.labelName         .text = NSLocalizedString(kUI_Name,           nil);
    self.labelUrl          .text = NSLocalizedString(kUI_Url,            nil);
    self.labelJurisdiction .text = NSLocalizedString(kUI_JurisdictionId, nil);
    self.labelApiKey       .text = NSLocalizedString(kUI_ApiKey,         nil);
    self.labelSupportsMedia.text = NSLocalizedString(kUI_SupportsMedia,  nil);
 
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:gestureRecognizer];
    
    
}
- (void)closeKeyboard
{
    [self.textFieldName resignFirstResponder];
    [self.textFieldUrl resignFirstResponder];
    [self.textFieldApiKey resignFirstResponder];
    [self.textFieldJurisdiction resignFirstResponder];
    
}

- (IBAction)save:(id)sender
{
    [[Open311 sharedInstance] checkServerValidity:self.textFieldUrl.text fromSender:self];
}

- (void)didFinishSaving
{
    Preferences *prefs = [Preferences sharedInstance];
    [prefs addCustomServer:@{
    kOpen311_Name         : self.textFieldName.text,
    kOpen311_Url          : self.textFieldUrl.text,
    kOpen311_Jurisdiction : self.textFieldJurisdiction.text,
    kOpen311_ApiKey       : self.textFieldApiKey.text,
    kOpen311_SupportsMedia: [NSNumber numberWithBool:self.switchSupportsMedia.on]
     }];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view handlers

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(kUI_ButtonAddServer, nil);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            [self.textFieldName becomeFirstResponder];
            break;
        case 1:
            [self.textFieldUrl becomeFirstResponder];
            break;
        case 2:
            [self.textFieldJurisdiction becomeFirstResponder];
            break;
        case 3:
            [self.textFieldApiKey becomeFirstResponder];
            break;
        default:
            break;
    }
}




@end
