/**
 * @copyright 2011 City of Bloomington, Indiana. All Rights Reserved
 * @author Cliff Ingham <inghamn@bloomington.in.gov>
 * @license http://www.gnu.org/licenses/gpl.txt GNU/GPLv3, see LICENSE.txt
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */

#import "MyServersViewController.h"
#import "Settings.h"
#import "AvailableServers.h"
#import "Open311.h"
#import "BusyViewController.h"

@implementation MyServersViewController
@synthesize myServersTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Report To" image:[UIImage imageNamed:@"megaphone.png"] tag:0];
    }
    return self;
}

- (void)dealloc
{
    [myServersTableView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setTitle:@"My Servers"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(goToAvailableServers)];
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    if ([[[Settings sharedSettings] myServers] count] == 0) {
        [self goToAvailableServers];
    }
}

- (void)viewDidUnload
{
    [self setMyServersTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [myServersTableView reloadData];
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table Vew Handlers

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[Settings sharedSettings] myServers] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"] autorelease];
    }
    
    Settings *settings = [Settings sharedSettings];
    NSDictionary *server = [[settings myServers] objectAtIndex:indexPath.row];
    cell.textLabel.text = [server objectForKey:@"Name"];
    cell.detailTextLabel.text = [server objectForKey:@"URL"];
    
    // Highlight the current server
    cell.accessoryType = UITableViewCellAccessoryNone;
    NSDictionary *currentServer = [settings currentServer];
    if (currentServer) {
        if ([[currentServer objectForKey:@"URL"] isEqualToString:[server objectForKey:@"URL"]]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    return cell;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.myServersTableView setEditing:editing animated:animated];
    if (!editing) {
        if ([[[Settings sharedSettings] myServers] count]==0) {
            [self goToAvailableServers];
        }
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Settings *settings = [Settings sharedSettings];
        if ([[settings.currentServer objectForKey:@"URL"] isEqualToString:[[settings.myServers objectAtIndex:indexPath.row] objectForKey:@"URL"]]) {
            [settings setCurrentServer:nil];
            [[Open311 sharedOpen311] reset];
            DLog(@"MyServer deleted currentServer %@", settings.currentServer);
        }
        [settings.myServers removeObjectAtIndex:indexPath.row];
        [self.myServersTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[[Settings sharedSettings] myServers] count]==0) {
        [self goToAvailableServers];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    Settings *settings = [Settings sharedSettings];
    settings.currentServer = [settings.myServers objectAtIndex:indexPath.row];
    
    self.tabBarController.selectedIndex = 0;
}

/**
 * Navigates to the Servers tab
 */
- (void) goToAvailableServers
{
    [self.navigationController pushViewController:[[AvailableServers alloc] init] animated:TRUE];
}

@end
