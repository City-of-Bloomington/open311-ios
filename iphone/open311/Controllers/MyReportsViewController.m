/**
 * Displays all the reports this phone has remembered submitting
 *
 * @copyright 2011 City of Bloomington, Indiana. All Rights Reserved
 * @author Cliff Ingham <inghamn@bloomington.in.gov>
 * @license http://www.gnu.org/licenses/gpl.txt GNU/GPLv3, see LICENSE.txt
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */

#import "MyReportsViewController.h"
#import "Settings.h"
#import "SingleReportViewController.h"

@implementation MyReportsViewController
@synthesize myRequestsTable;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"My Reports" image:[UIImage imageNamed:@"list.png"] tag:0];
    }
    return self;
}

- (void)dealloc {
    [myRequestsTable release];
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
    // Do any additional setup after loading the view from its nib.
    [self.navigationItem setTitle:@"My Reports"];
    [self.navigationItem setLeftBarButtonItem:self.editButtonItem];
}

- (void)viewDidUnload
{
    [self setMyRequestsTable:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [myRequestsTable reloadData];
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table View Handlers
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [[[Settings sharedSettings] myRequests] count];
    DLog(@"Loading table.  Count is %d", count);
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"] autorelease];
    }
    
    NSDictionary *request = [[[Settings sharedSettings] myRequests] objectAtIndex:indexPath.row];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:kCFDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    DLog(@"Formatting date %@", [request objectForKey:@"date"]);
    
    cell.textLabel.text = [[request objectForKey:@"service"] objectForKey:@"service_name"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@: %@",
                                 [dateFormatter stringFromDate:[request objectForKey:@"date"]],
                                 [[request objectForKey:@"server"] objectForKey:@"Name"]
                                 ];
    [dateFormatter release];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    Settings *settings = [Settings sharedSettings];
    NSDictionary *myReport = [settings.myRequests objectAtIndex:indexPath.row];
    NSString *service_request_id = [myReport objectForKey:@"service_request_id"];

    [self.navigationController pushViewController:[[SingleReportViewController alloc] initWithServiceRequestId:service_request_id] animated:YES];
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.myRequestsTable setEditing:editing animated:animated];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[[Settings sharedSettings] myRequests] removeObjectAtIndex:indexPath.row];
        [self.myRequestsTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
