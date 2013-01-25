//
//  PersonalInfoController.m
//  GeoReporter
//
//  Created by Cliff Ingham on 1/25/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import "PersonalInfoController.h"
#import "Strings.h"

@interface PersonalInfoController ()

@end

@implementation PersonalInfoController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.labelFirstName.text = NSLocalizedString(kUI_FirstName, nil);
    self.labelLastName .text = NSLocalizedString(kUI_LastName,  nil);
    self.labelEmail    .text = NSLocalizedString(kUI_Email,     nil);
    self.labelPhone    .text = NSLocalizedString(kUI_Phone,     nil);
    
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    
    self.textFieldFirstName.text = [preferences stringForKey:kOpen311_FirstName];
    self.textFieldLastName .text = [preferences stringForKey:kOpen311_LastName];
    self.textFieldEmail    .text = [preferences stringForKey:kOpen311_Email];
    self.textFieldPhone    .text = [preferences stringForKey:kOpen311_Phone];
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    [preferences setValue:self.textFieldFirstName.text forKey:kOpen311_FirstName];
    [preferences setValue:self.textFieldLastName .text forKey:kOpen311_LastName];
    [preferences setValue:self.textFieldEmail    .text forKey:kOpen311_Email];
    [preferences setValue:self.textFieldPhone    .text forKey:kOpen311_Phone];
    
    [super viewWillDisappear:animated];
}


#pragma mark - Table view handlers

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(kUI_PersonalInfo, nil);
}

@end
