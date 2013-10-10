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

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "Report.h"

#define MEDIA_CELL_HEIGHT 122
#define LOCATION_CELL_HEIGHT 122
#define LOCATION_CELL_HEIGHT_IPAD 222
#define FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 290.0f
#define CELL_CONTENT_MARGIN 10.0f

@interface ViewRequestController : UITableViewController <ServiceRequestDelegate>
@property Report *report;
@property NSInteger reportIndex;
@property NSDateFormatter *dateFormatterDisplay;
@property NSDateFormatter *dateFormatterISO;
@property NSURL *mediaUrl;
@property UIImage *media;
@property UIImage *original;
@property UITapGestureRecognizer * gestureRecognizer;
@property BOOL loadedOnce;

- (void)startRefreshingServiceRequest;
@end
