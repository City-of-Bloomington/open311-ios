//
//  ChooseServiceViewController.m
//  open311
//
//  Created by Cliff Ingham on 11/3/11.
//  Copyright (c) 2011 City of Bloomington. All rights reserved.
//

#import "ChooseServiceViewController.h"
#import "Open311.h"

@implementation ChooseServiceViewController
@synthesize serviceTable;
@synthesize services;

- (id)initWithDelegate:(id<ServiceChooserDelegate>)serviceChooserDelegate group:(NSString *)serviceGroup
{
    self = [super init];
    if (self) {
        delegate = serviceChooserDelegate;
        group = serviceGroup;
    }
    return self;
}

- (void)dealloc {
    [group release];
    [services release];
    [serviceTable release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

/**
 * Loads all the services matching the chosen group
 *
 * A special group called, "Other" will be used to only load services
 * without a group.
 *
 * If group is nil, then load all services.
 */
- (void)loadServices
{
    self.services = [NSMutableArray array];
    if (group) {
        DLog(@"Looking for %@ services", group);
        for (NSDictionary *service in [[Open311 sharedOpen311] services]) {
            if (([group length] == 0 || [group isEqualToString:@"Other"])
                && ([service objectForKey:@"group"] == [NSNull null] || [[service objectForKey:@"group"] length] == 0)) {
                [self.services addObject:service];
            }
            else if ([[service objectForKey:@"group"] isEqualToString:group]) {
                [self.services addObject:service];
            }
        }
    }
    else {
        DLog(@"No group specified, loading all services");
        self.services = [NSMutableArray arrayWithArray:[[Open311 sharedOpen311] services]];
    }
    [serviceTable reloadData];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"Choose Service"];
}

- (void)viewDidUnload
{
    [group release];
    [services release];
    [self setServiceTable:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self loadServices];
    [super viewDidAppear:animated];
}

#pragma mark - Table Handler Functions
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.services count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"] autorelease];
    }
    
    cell.textLabel.text = [[self.services objectAtIndex:indexPath.row] objectForKey:@"service_name"];
    cell.detailTextLabel.text = [[self.services objectAtIndex:indexPath.row] objectForKey:@"description"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [delegate didSelectService:[self.services objectAtIndex:indexPath.row]];
}

@end
