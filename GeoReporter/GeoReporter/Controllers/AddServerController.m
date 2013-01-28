//
//  AddServerController.m
//  GeoReporter
//
//  Created by Cliff Ingham on 1/28/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import "AddServerController.h"
#import "Strings.h"
#import "Preferences.h"

@interface AddServerController ()

@end

@implementation AddServerController

- (void)viewDidLoad
{
    [super viewDidLoad];

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
