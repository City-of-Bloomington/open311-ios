//
//  HomeViewController.h
//  GeoReporter
//
//  Created by Cliff Ingham on 1/23/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *reportButton;
@property (weak, nonatomic) IBOutlet UIButton *serversButton;
@property (weak, nonatomic) IBOutlet UIButton *archiveButton;
@property (weak, nonatomic) IBOutlet UIButton *personalInfoButton;
@property (weak, nonatomic) IBOutlet UIButton *aboutButton;
- (IBAction)buttonWasClicked:(id)sender;

@end
