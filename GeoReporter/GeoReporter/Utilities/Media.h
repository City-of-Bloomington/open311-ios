//
//  Media.h
//  GeoReporter
//
//  Created by Cliff Ingham on 2/12/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface Media : NSObject
+ (UIImage *)resizeImage:(UIImage *)image toBoundingBox:(NSInteger)size;
@end
