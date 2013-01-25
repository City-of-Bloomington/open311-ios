//
//  PersonalInfoController.h
//  GeoReporter
//
//  Created by Cliff Ingham on 1/25/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersonalInfoController : UITableViewController <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, weak) IBOutlet UILabel *labelFirstName;
@property (nonatomic, weak) IBOutlet UILabel *labelLastName;
@property (nonatomic, weak) IBOutlet UILabel *labelEmail;
@property (nonatomic, weak) IBOutlet UILabel *labelPhone;
@property (nonatomic, weak) IBOutlet UITextField *textFieldFirstName;
@property (nonatomic, weak) IBOutlet UITextField *textFieldLastName;
@property (nonatomic, weak) IBOutlet UITextField *textFieldEmail;
@property (nonatomic, weak) IBOutlet UITextField *textFieldPhone;

@end
