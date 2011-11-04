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

#import "ChooseGroupViewController.h"
#import "ChooseServiceViewController.h"
#import "Open311.h"

@implementation ChooseGroupViewController
@synthesize groups;
@synthesize groupTable;

- (id)initWithDelegate:(id <ServiceChooserDelegate>)serviceChooserDelegate
{
    self = [super init];
    if (self) {
        delegate = serviceChooserDelegate;
    }
    return self;
}

- (void)dealloc {
    [self.groups release];
    [groupTable release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

/**
 * Loads all the distinct groups from the service list
 *
 * For services without a group, we'll create a group called , "Other"
 */
- (void)loadGroups
{
    NSArray *services = [[Open311 sharedOpen311] services];
    self.groups = [NSMutableArray array];
    BOOL hasOther = false;
    
    for (NSDictionary *service in services) {
        NSString *group = nil;
        if ([service objectForKey:@"group"] == [NSNull null]
            || [[service objectForKey:@"group"] length] == 0) {
            hasOther = TRUE;
        }
        else {
            group = [service objectForKey:@"group"];
        }
        if (group && ![self.groups containsObject:group]) {
            DLog(@"Adding group %@", group);
            [self.groups addObject:group];
        }
    }
    self.groups = [NSMutableArray arrayWithArray:[self.groups sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    if (hasOther) {
        [self.groups addObject:@"Other"];
    }
    
    if ([self.groups count] <= 1) {
        ChooseServiceViewController *chooser = [[ChooseServiceViewController alloc] initWithDelegate:delegate group:nil];
        [self.navigationController pushViewController:chooser animated:YES];
        [chooser release];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"Groups"];
    [self loadGroups];
}

- (void)viewDidUnload
{
    [self setGroupTable:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - Table Handler Functions
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.groups count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"] autorelease];
    }
    cell.textLabel.text = [self.groups objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSString *detail = @"";
    for (NSDictionary *service in [[Open311 sharedOpen311] services]) {
        if ([[service objectForKey:@"group"] isEqualToString:[self.groups objectAtIndex:indexPath.row]]) {
            detail = [detail stringByAppendingFormat:@"%@, ",[service objectForKey:@"service_name"]];
        }
    }
    cell.detailTextLabel.text = detail;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    ChooseServiceViewController *chooser = [[ChooseServiceViewController alloc] initWithDelegate:delegate group:[self.groups objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:chooser animated:YES];
    [chooser release];
}
@end
