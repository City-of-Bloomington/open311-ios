//
//  HomeController.m
//  GeoReporter
//
//  Created by Cliff Ingham on 1/25/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import "HomeController.h"
#import "Strings.h"
#import "Preferences.h"

@interface HomeController ()

@end

@implementation HomeController {
    Preferences *preferences;
}
static NSString * const kSegueToServers = @"SegueToServers";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    preferences = [Preferences sharedInstance];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSDictionary *currentServer = [preferences getCurrentServer];
    if (currentServer == nil) {
        [self performSegueWithIdentifier:kSegueToServers sender:self];
    }
}
@end
