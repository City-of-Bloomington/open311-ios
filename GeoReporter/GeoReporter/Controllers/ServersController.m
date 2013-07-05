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

#import "ServersController.h"
#import "Strings.h"
#import "Preferences.h"

@interface ServersController ()

@end

@implementation ServersController {
    Preferences *prefs;
    NSArray *availableServers;
    NSMutableArray *customServers;
    
}
static NSString * const kCellIdentifier = @"server_cell";
static NSString * const kUnwindSegueToHome = @"UnwindSegueToHome";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(kUI_Servers, nil);

    availableServers = [Preferences getAvailableServers];
    prefs = [Preferences sharedInstance];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSDictionary *currentServer = [prefs getCurrentServer];
    if (currentServer == nil) {
        [[self navigationItem] setHidesBackButton:YES];
    }
    
    customServers = [NSMutableArray arrayWithArray:[prefs getCustomServers]];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [prefs saveCustomServers:customServers];
    
    [super viewWillDisappear:animated];
}

/**
 * Returns a server dictionary from either Available or Custom servers.
 *
 * We are displaying both AvailableServers and CustomServers in one table:
 * AvailableServers first, then any customServers.
 * CustomServer indexes need to be offset by the number of availableServers
 */
- (NSDictionary *)getTargetServer:(NSInteger)index
{
    NSUInteger numAvailableServers = [availableServers count];
    if (index < numAvailableServers) {
        return availableServers[index];
    }
    else {
        index = index - numAvailableServers;
        return customServers[index];
    }
}



#pragma mark - Table View Handlers
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([customServers count] > 0) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [availableServers count];
    }
    return [customServers count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) return @"Available Servers";
    return @"Custom Servers";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellIdentifier];
    }
    NSDictionary *server;
    if (indexPath.section == 0) {
        server = [self getTargetServer:indexPath.row];
    }
    else {
        server = [self getTargetServer:(indexPath.row + [availableServers count])];
    }
    
    
    
    cell.textLabel      .text = server[kOpen311_Name];
    cell.detailTextLabel.text = server[kOpen311_Url];
    cell.accessoryType = UITableViewCellAccessoryNone;
    if ([[prefs getCurrentServer][kOpen311_Name] isEqualToString:cell.textLabel.text]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [prefs setCurrentServer:[self getTargetServer:indexPath.row]];
    }
    else {
        [prefs setCurrentServer:[self getTargetServer:(indexPath.row + [availableServers count])]];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    [self performSegueWithIdentifier:kUnwindSegueToHome sender:self];
}

#pragma mark - Table View Deletion Handlers
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return TRUE;
    }
    return FALSE;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if ([tableView numberOfRowsInSection:[indexPath section]] > 1) {
            [customServers removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        else
        {
            [customServers removeObjectAtIndex:indexPath.row];
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}
@end
