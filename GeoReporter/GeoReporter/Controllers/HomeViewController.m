//
//  HomeViewController.m
//  GeoReporter
//
//  Created by Cliff Ingham on 1/23/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import "HomeViewController.h"
#import "Strings.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

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

    [_reportButton       setTitle:NSLocalizedString(kUI_Report,       nil) forState:UIControlStateNormal];
    [_serversButton      setTitle:NSLocalizedString(kUI_Servers,      nil) forState:UIControlStateNormal];
    [_archiveButton      setTitle:NSLocalizedString(kUI_Archive,      nil) forState:UIControlStateNormal];
    [_personalInfoButton setTitle:NSLocalizedString(kUI_PersonalInfo, nil) forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
