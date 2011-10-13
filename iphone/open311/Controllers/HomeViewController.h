//
//  HomeViewController.h
//  open311
//
//  Created by Cliff Ingham on 9/6/11.
//  Copyright 2011 City of Bloomington. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HomeViewController : UIViewController {
    UIImageView *splashImage;
}
@property (nonatomic, retain) IBOutlet UIImageView *splashImage;

- (void)gotoSettings;

@end
