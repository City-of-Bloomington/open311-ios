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

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
        [preferences setValue:@"no" forKey:kOpen311_IsAnonymous];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)didChangeSwitchValue:(id)sender {
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    if ([self.anonymousSwitch isOn]) {
        [preferences setValue:@"yes" forKey:kOpen311_IsAnonymous];
    }
    else {
        [preferences setValue:@"no" forKey:kOpen311_IsAnonymous];
    }
}
@end
