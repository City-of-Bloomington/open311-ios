/**
 * Protocol used to send user input back to ReportController
 *
 * The bulk of our report views just ask the user for one
 * value at a time.  No matter what the Open311 type, the
 * user is really only providing a single string per field.
 *
 * @copyright 2013 City of Bloomington, Indiana. All Rights Reserved
 * @author Cliff Ingham <inghamn@bloomington.in.gov>
 * @license http://www.gnu.org/licenses/gpl.txt GNU/GPLv3, see LICENSE.txt
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */

#import <Foundation/Foundation.h>

@protocol TextEntryDelegate <NSObject>
@required
- (void)didProvideValue:(NSString *)value;
@end
