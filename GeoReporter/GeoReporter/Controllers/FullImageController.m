//
//  FullImageController.m
//  GeoReporter
//
//  Created by Marius Constantinescu on 8/4/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import "FullImageController.h"

@interface FullImageController ()

@end

@implementation FullImageController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.imageView setImage:_image];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
