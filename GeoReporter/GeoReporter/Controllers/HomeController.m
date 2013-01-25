//
//  HomeViewController.m
//  GeoReporter
//
//  Created by Cliff Ingham on 1/23/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import "HomeViewController.h"
#import "Strings.h"
#import "AboutViewController.h"

#define kReport

@interface HomeViewController ()

@end


@implementation HomeViewController

- (id)init
{
    self = [super initWithNibName:@"HomeView" bundle:nil];
    if (self) {
        
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
    [_aboutButton        setTitle:NSLocalizedString(kUI_About,        nil) forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Reads the tag from the button that was clicked
// Tags should be set correctly in InterfaceBuilder
- (IBAction)buttonWasClicked:(id)sender {
    DLog(@"Button %d was clicked", [sender tag]);
    enum HomeViewButtons {
        ReportButton       = 0,
        ServersButton      = 1,
        ArchiveButton      = 2,
        PersonalInfoButton = 3,
        AboutButton        = 4
    };
    
    switch ([(UIButton *)sender tag]) {
        case ReportButton:
            break;
        case ServersButton:
            break;
        case ArchiveButton:
            break;
        case PersonalInfoButton:
            break;
        case AboutButton: {
            AboutViewController *about = [[AboutViewController alloc] init];
            [self.navigationController pushViewController:about animated:YES];
        }
            break;
            
        default:
            break;
    }
}
@end
