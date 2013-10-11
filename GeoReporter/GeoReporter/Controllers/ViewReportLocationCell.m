/**
 * @copyright 2013 City of Bloomington, Indiana. All Rights Reserved
 * @author Marius Constantinescu <constantinescu.marius@gmail.com>
 * @license http://www.gnu.org/licenses/gpl.txt GNU/GPLv3, see LICENSE.txt
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 *
 * Custom cell used in the ViewRequestController for the cell containing
 * the map. Custom cells are needed so we can change the width for the
 * iPad version in the Landscape orientation.
 */

#import "ViewReportLocationCell.h"

@implementation ViewReportLocationCell

// Override the setFrame method to customize the table width for the iPad
- (void)setFrame:(CGRect)frame
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		// The device is an iPad running iOS 3.2 or later.
		UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
		
		if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
			frame.origin.x += VIEW_REPORT_LOCATION_CELL_IPAD_OFFSET;
			frame.size.width -= 2 * VIEW_REPORT_LOCATION_CELL_IPAD_OFFSET;
		}
	}
	else {
		// The device is an iPhone or iPod touch. We use the default frame of the superclass (TableViewCell)
	}
	[super setFrame:frame];
}


@end
