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
#import "Open311.h"
#import "AFJSONRequestOperation.h"

@interface HomeController ()

@end

@implementation HomeController {
    UIActivityIndicatorView *busyIcon;
}
static NSString * const kSegueToServers = @"SegueToServers";

- (void)viewWillAppear:(BOOL)animated
{
    Preferences *preferences = [Preferences sharedInstance];
    
    NSDictionary *currentServer = [preferences getCurrentServer];
    if (currentServer == nil) {
        [self performSegueWithIdentifier:kSegueToServers sender:self];
    }
    else {
        busyIcon = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        busyIcon.center = self.view.center;
        [busyIcon setFrame:self.view.frame];
        [busyIcon setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5]];
        [busyIcon startAnimating];
        [self.view addSubview:busyIcon];

        Open311 *open311 = [Open311 sharedInstance];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(serviceListReady)
                                                     name:kNotification_ServiceListReady
                                                   object:open311];
        [open311 loadAllMetadataForServer:currentServer];
    }
}

- (void)serviceListReady
{
    [busyIcon stopAnimating];
    [busyIcon removeFromSuperview];
}

@end
