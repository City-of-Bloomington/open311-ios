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

#import "AvailableServers.h"
#import "Settings.h"


@implementation AvailableServers

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
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
    [self.navigationItem setTitle:@"Available Servers"];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return [[[[Settings sharedSettings] availableServers] objectForKey:@"Servers"] count];
    }
    else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *server = [[[[Settings sharedSettings] availableServers] objectForKey:@"Servers"] objectAtIndex:indexPath.row];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"] autorelease];
    }
    cell.textLabel.text = [server objectForKey:@"Name"];
    cell.detailTextLabel.text = [server objectForKey:@"URL"];
    return cell;
}

/**
 * Adds tha chosen server to MyServers
 *
 * We want to make sure that the server isn't already there.  Otherwise,
 * people will fill up their MyServers list with a bunch of the same one.
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    Settings *settings = [Settings sharedSettings];
    NSDictionary *chosenServer = [[settings.availableServers objectForKey:@"Servers"] objectAtIndex:indexPath.row];
    
    // Make sure the server we're about to add isn't already in MyServers
    BOOL alreadyExists = FALSE;
    for (NSDictionary *server in settings.myServers) {
        if ([[server objectForKey:@"URL"] isEqualToString:[chosenServer objectForKey:@"URL"]]) {
            alreadyExists = TRUE;
            break;
        }
    }
    
    if (!alreadyExists) {
        [settings.myServers addObject:chosenServer];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
