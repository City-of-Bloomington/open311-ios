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
 * Custom cell which shows an image, for the Media field in the New Report
 */
#import "MediaCell.h"

@implementation MediaCell

#pragma mark - UITapGestureRecognizerSelector

- (void) deleteImage:(UITapGestureRecognizer *) sender
{
	self.image.image = [UIImage imageNamed:@"camera.png"];
	self.closeImage.hidden = YES;
	self.header.text = @"Add image";
}

- (void)setCloseImage:(UIImageView *)closeImage
{
	_closeImage = closeImage;
	self.closeImage.userInteractionEnabled = YES;
	UITapGestureRecognizer * gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteImage:)];
	[self.closeImage addGestureRecognizer:gestureRecognizer];
	gestureRecognizer.cancelsTouchesInView = YES;
}
@end
