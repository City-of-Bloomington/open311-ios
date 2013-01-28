//
//  AddServerController.h
//  GeoReporter
//
//  Created by Cliff Ingham on 1/28/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddServerController : UITableViewController
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

- (IBAction)save:(id)sender;

@end
