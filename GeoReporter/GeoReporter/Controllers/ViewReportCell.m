//
//  ViewReportCell.m
//  GeoReporter
//
//  Created by Marius Constantinescu on 9/13/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import "ViewReportCell.h"

@implementation ViewReportCell

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

- (void)setFrame:(CGRect)frame {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // The device is an iPad running iOS 3.2 or later.
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        
        if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
            frame.origin.x += VIEW_REPORT_CELL_IPAD_OFFSET;
            frame.size.width -= 2 * VIEW_REPORT_CELL_IPAD_OFFSET;
        }
    }
    else {
        // The device is an iPhone or iPod touch. We use the default frame of the superclass (TableViewCell)
    }
    [super setFrame:frame];
}

@end
