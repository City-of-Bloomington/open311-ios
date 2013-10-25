//
//  NBAsYouTypeFormatter.h
//  libPhoneNumber
//
//  Created by ishtar on 13. 2. 25..
//  Copyright (c) 2013년 NHN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NBAsYouTypeFormatter : NSObject

- (id)initWithRegionCode:(NSString*)regionCode;
- (id)initWithRegionCodeForTest:(NSString*)regionCode;

- (NSString*)inputDigit:(NSString*)nextChar;
- (NSString*)inputDigitAndRememberPosition:(NSString*)nextChar;
- (int)getRememberedPosition;
- (void)clear;

@end
