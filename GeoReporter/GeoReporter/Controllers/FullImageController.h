//
//  FullImageController.h
//  GeoReporter
//
//  Created by Marius Constantinescu on 8/4/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FullImageController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) UIImage *image;
- (IBAction)close:(id)sender;
@end
