//
//  FooterCell.h
//  GeoReporter
//
//  Created by Marius Constantinescu on 9/2/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FooterCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UISwitch *anonymousSwitch;
- (IBAction)didChangeSwitchValue:(id)sender;

@end
