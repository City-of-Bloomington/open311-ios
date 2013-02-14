//
//  Media.m
//  GeoReporter
//
//  Created by Cliff Ingham on 2/12/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

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
