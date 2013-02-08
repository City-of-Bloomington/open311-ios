//
//  MultiValueDelegate.h
//  GeoReporter
//
//  Created by Cliff Ingham on 2/7/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MultiValueDelegate <NSObject>
@required
- (void)didProvideValues:(NSArray *)values;
@end
