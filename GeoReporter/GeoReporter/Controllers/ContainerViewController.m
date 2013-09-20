//
//  ContainerViewController.m
//  GeoReporter
//
//  Created by Marius Constantinescu on 9/16/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import "ContainerViewController.h"
#import "ChooseServiceController.h"
#import "ChooseGroupController.h"
#import "NewReportController.h"
#import "Open311.h"

@interface ContainerViewController ()

@end

@implementation ContainerViewController
static NSString * const kEmbeddedSegueToGroup = @"EmbeddedSegueToGroup";
static NSString * const kEmbeddedSegueToService = @"EmbeddedSegueToService";
static NSString * const kSegueToNewReport = @"SegueToNewReport";




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
    
    //make view controller start below navigation bar; this wrks in iOS 7
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark GroupDelegate

- (void) didSelectGroup:(NSString *) group
{
    self.selectedGroup = group;
    self.serviceController.group = self.selectedGroup;
}

# pragma mark ServiceDelegate

- (void) didSelectService:(NSDictionary *) service
{
    self.selectedService = service;
    [self performSegueWithIdentifier:kSegueToNewReport sender:self];
}



- (void) prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kEmbeddedSegueToService])    {
        self.serviceController = segue.destinationViewController;
        self.serviceController.delegate = self;
    }
    else if ([segue.identifier isEqualToString:kEmbeddedSegueToGroup]){
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            // The device is an iPad running iOS 3.2 or later.
            ChooseGroupController* groupController = segue.destinationViewController;
            groupController.delegate = self;
        }
    }
    else if ([segue.identifier isEqualToString:kSegueToNewReport]){
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            // The device is an iPad running iOS 3.2 or later.
            NewReportController *report = [segue destinationViewController];
            report.service = [[Open311 sharedInstance] getServicesForGroup:self.selectedGroup][[[self.serviceController.tableView indexPathForSelectedRow] row]];
        }
    }
    

}

@end
