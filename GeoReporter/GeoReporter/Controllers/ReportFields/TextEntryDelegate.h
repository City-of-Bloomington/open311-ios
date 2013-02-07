//
//  TextEntryDelegate.h
//  GeoReporter
//
//  Created by Cliff Ingham on 2/6/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//
// The bulk of our report views just ask the user for one
// value at a time.  No matter what the Open311 type, the
// user is really only providing a single string per field.

#import <Foundation/Foundation.h>

@protocol TextEntryDelegate <NSObject>
@required
- (void)didProvideValue:(NSString *)value;
@end
