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

static NSString * const kSegueToSettings = @"SegueToSettings";

@implementation HomeController {
    UIActivityIndicatorView *busyIcon;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.reportLabel     .text = NSLocalizedString(kUI_Report,  nil);
    self.archiveLabel    .text = NSLocalizedString(kUI_Archive, nil);
    self.reportingAsLabel.text = NSLocalizedString(kUI_ReportingAs, nil);
    [self.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(kUI_Settings, nil)];
    
    [[self.tabBarController.tabBar.items objectAtIndex:kTab_Report]  setTitle:NSLocalizedString(kUI_Report,  nil)];
    [[self.tabBarController.tabBar.items objectAtIndex:kTab_Archive] setTitle:NSLocalizedString(kUI_Archive, nil)];
    [[self.tabBarController.tabBar.items objectAtIndex:kTab_Servers] setTitle:NSLocalizedString(kUI_Servers, nil)];
}

/**
 * Check if the user has chosen a server.
 * If not, redirect them to the servers tab;
 * otherwise, load all service information from the server.
 */
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
        
        [self startBusyIcon];
        Open311 *open311 = [Open311 sharedInstance];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(serviceListReady)
                                                     name:kNotification_ServiceListReady
                                                   object:open311];
        [open311 loadAllMetadataForServer:currentServer];
    }
    
    [self refreshPersonalInfo];
}

- (void)startBusyIcon
{
    busyIcon = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    busyIcon.center = self.view.center;
    [busyIcon setFrame:self.view.frame];
    [busyIcon setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5]];
    [busyIcon startAnimating];
    [self.view addSubview:busyIcon];
}

- (void)serviceListReady
{
    [busyIcon stopAnimating];
    [busyIcon removeFromSuperview];
}

- (void)refreshPersonalInfo
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *text = @"";
    NSString *firstname = [defaults stringForKey:kOpen311_FirstName];
    NSString *lastname  = [defaults stringForKey:kOpen311_LastName];
    NSString *email     = [defaults stringForKey:kOpen311_Email];
    NSString *phone     = [defaults stringForKey:kOpen311_Phone];
    if ([firstname length] > 0 || [lastname length] > 0) {
        text = [text stringByAppendingFormat:@"%@ %@", firstname, lastname];
    }
    if ([email length] > 0) {
        text = [text stringByAppendingFormat:@"\r%@", email];
    }
    if ([phone length] > 0) {
        text = [text stringByAppendingFormat:@"\r%@", phone];
    }
    if ([text length] == 0) {
        text = @"anonymous";
    }
    DLog(@"Contact info is: %@", text);
    self.personalInfoLabel.text = text;
}

#pragma mark - Table Handler Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        
        CGSize size = [self.personalInfoLabel.text sizeWithFont:self.personalInfoLabel.font
                                              constrainedToSize:CGSizeMake(300, 140)
                                                  lineBreakMode:self.personalInfoLabel.lineBreakMode];
        NSInteger height = size.height + 28;
        DLog(@"Setting report_to height: %d", height);
        return (CGFloat)height;
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self.tabBarController setSelectedIndex:kTab_Report];
        }
        if (indexPath.row == 1) {
            [self.tabBarController setSelectedIndex:kTab_Archive];
        }
    }
    if (indexPath.section == 1) {
        [self performSegueWithIdentifier:kSegueToSettings sender:self];
    }
}

@end
