//
//  ChooseGroupViewController.m
//  open311
//
//  Created by Cliff Ingham on 11/3/11.
//  Copyright (c) 2011 City of Bloomington. All rights reserved.
//

#import "ChooseGroupViewController.h"
#import "ChooseServiceViewController.h"
#import "Open311.h"

@implementation ChooseGroupViewController
@synthesize groupTable;

- (id)initWithDelegate:(id <ServiceChooserDelegate>)serviceChooserDelegate
{
    self = [super init];
    if (self) {
        delegate = serviceChooserDelegate;
        groups = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    [groups release];
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
    for (NSDictionary *service in services) {
        NSString *group = @"";
        if ([service objectForKey:@"group"] == [NSNull null]
            || [[service objectForKey:@"group"] length] == 0) {
            group = @"Other";
        }
        else {
            group = [service objectForKey:@"group"];
        }
        if (![groups containsObject:group]) {
            DLog(@"Adding group %@", group);
            [groups addObject:group];
        }
    }
    
    if ([groups count] <= 1) {
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
    return [groups count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"] autorelease];
    }
    cell.textLabel.text = [groups objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    ChooseServiceViewController *chooser = [[ChooseServiceViewController alloc] initWithDelegate:delegate group:[groups objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:chooser animated:YES];
    [chooser release];
}
@end
