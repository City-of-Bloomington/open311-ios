//
//  FooterCell.m
//  GeoReporter
//
//  Created by Marius Constantinescu on 9/2/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import "FooterCell.h"
#import "Strings.h"

@implementation FooterCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)didChangeSwitchValue:(id)sender {
    if (self.anonymousSwitch.isOn) {
        //restore values
    }
    else {
        
//        NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
//        
//        [preferences setValue:@"" forKey:kOpen311_FirstName];
//        [preferences setValue:@"" forKey:kOpen311_LastName];
//        [preferences setValue:@"" forKey:kOpen311_Email];
//        [preferences setValue:@"" forKey:kOpen311_Phone];
    }
}
@end
