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

@interface AddServerController ()

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
}

- (IBAction)save:(id)sender
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
@end
