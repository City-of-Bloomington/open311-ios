//
//  ServersController.m
//  GeoReporter
//
//  Created by Cliff Ingham on 1/25/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [availableServers count] + [customServers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellIdentifier];
    }
    
    NSDictionary *server = [self getTargetServer:indexPath.row];
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
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [prefs setCurrentServer:[self getTargetServer:indexPath.row]];
    [self.tabBarController setSelectedIndex:kTab_Home];
}

#pragma mark - Table View Deletion Handlers
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= [availableServers count]) {
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
        NSInteger index = indexPath.row - [availableServers count];
        [customServers removeObjectAtIndex:index];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}
@end
