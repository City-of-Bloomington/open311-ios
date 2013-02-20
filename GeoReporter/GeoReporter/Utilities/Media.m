/**
 * @copyright 2013 City of Bloomington, Indiana. All Rights Reserved
 * @author Cliff Ingham <inghamn@bloomington.in.gov>
 * @license http://www.gnu.org/licenses/gpl.txt GNU/GPLv3, see LICENSE.txt
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */

#import "Media.h"

@implementation Media

+ (UIImage *)resizeImage:(UIImage *)image toBoundingBox:(NSInteger)size
{
	//resize the image that will be sent to city webservice
	CGFloat originalWidth = image.size.width;
	CGFloat originalHeight = image.size.height;
	CGFloat smallerDimensionMultiplier;
	CGFloat newWidth;
	CGFloat newHeight;
	if (originalWidth > originalHeight) {
		smallerDimensionMultiplier = originalHeight / originalWidth;
		newWidth = size;
		newHeight = newWidth * smallerDimensionMultiplier;
	}
	else {
		smallerDimensionMultiplier = originalWidth / originalHeight;
		newHeight =  size;
		newWidth = newHeight * smallerDimensionMultiplier;
	}
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [image drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
	UIImage *output = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return output;
}
@end
