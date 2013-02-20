/**
 * @copyright 2013 City of Bloomington, Indiana. All Rights Reserved
 * @author Cliff Ingham <inghamn@bloomington.in.gov>
 * @license http://www.gnu.org/licenses/gpl.txt GNU/GPLv3, see LICENSE.txt
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self.tabBarController.tabBar.items objectAtIndex:kTab_Report]  setTitle:NSLocalizedString(kUI_Report,  nil)];
    [[self.tabBarController.tabBar.items objectAtIndex:kTab_Archive] setTitle:NSLocalizedString(kUI_Archive, nil)];
    [[self.tabBarController.tabBar.items objectAtIndex:kTab_Servers] setTitle:NSLocalizedString(kUI_Servers, nil)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    Preferences *preferences = [Preferences sharedInstance];
    
    NSDictionary *currentServer = [preferences getCurrentServer];
    if (currentServer == nil) {
        [self.tabBarController setSelectedIndex:3];
    }
    else {
        self.navigationItem.title = currentServer[kOpen311_Name];
        
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
