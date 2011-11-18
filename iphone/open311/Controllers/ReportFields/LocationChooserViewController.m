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

#import "LocationChooserViewController.h"
#import "Locator.h"


@implementation LocationChooserViewController
@synthesize reportForm;

- (id)initWithReport:(NSMutableDictionary *)report
{
    self = [super init];
    if (self) {
        self.reportForm = report;
    }
    return self;
}

- (void)dealloc
{
    [reportForm release];
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

    [self.navigationItem setTitle:@"Location"];
    [self.navigationItem.backBarButtonItem setTitle:@"Cancel"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(didChooseLocation)];
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

- (IBAction)handleZoomButton:(id)sender {
    [self zoomToGpsLocation:TRUE];
}

- (IBAction)switchMapViewStyle:(id)sender {
    //UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    if ([sender selectedSegmentIndex]==0) {
        [self.map setMapType:MKMapTypeStandard];
    }
    else {
        [self.map setMapType:MKMapTypeSatellite];
    }
}

/**
 * Grabs the coordinates, reverse geocodes the address, and updates the report
 *
 * The user is centering the map onto the location they want to use.
 * We need to grab the center coordinates of the map and use those to
 * reverse geocode the address.  Once we update the reportForm with the 
 * coordinates and the address, we're done here, and can send them back
 * to the ReportView
 */
- (void)didChooseLocation
{
    CLLocationCoordinate2D center = [super.map centerCoordinate];
    NSMutableDictionary *data = [reportForm objectForKey:@"data"];
    
    // It's going to much easier if we convert them to strings now
    NSString *latitude = [NSString stringWithFormat:@"%f",center.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f",center.longitude];
    [data setObject:latitude forKey:@"lat"];
    [data setObject:longitude forKey:@"long"];

    [self.navigationController popViewControllerAnimated:YES];
}

@end
