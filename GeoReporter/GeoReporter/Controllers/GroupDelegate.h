//
//  GroupDelegate.h
//  GeoReporter
//
//  Created by Marius Constantinescu on 9/18/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GroupDelegate <NSObject>
@required 
- (void) didSelectGroup:(NSString *) group;
@end
