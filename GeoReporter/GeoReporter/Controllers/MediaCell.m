//
//  MediaCell.m
//  GeoReporter
//
//  Created by Marius Constantinescu on 8/3/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import "MediaCell.h"

@implementation MediaCell

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

@end
