//
//  AboutViewController.h
//  open311
//
//  Created by Cliff Ingham on 11/3/11.
//  Copyright (c) 2011 City of Bloomington. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutViewController : UIViewController <UIWebViewDelegate>
@property (retain, nonatomic) IBOutlet UIWebView *aboutView;

@end
