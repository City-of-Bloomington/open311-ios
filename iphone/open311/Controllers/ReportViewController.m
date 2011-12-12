/**
 * This is the screen where the user is creating a report to send to
 * an open311 server.  We need to know what service the user wants to
 * report to on that server.  We'll get the list of attributes for that
 * service and let the user enter data for each one of the attributes.
 *
 * We start by creating an empty report from Report.plist
 * Then, we query the service_definition and add all the attributes
 * defined in the service_defition.
 * Each of the types declared in reportForm has a custom view
 * that opens when the user edits that field.  User responses
 * get saved as strings in reportForm[data].
 * When we're ready to POST, we just have to read through 
 * reportForm[data] for the data to submit.
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

#import <AddressBook/AddressBook.h>
#import "ReportViewController.h"
#import "Settings.h"
#import "Open311.h"
#import "SBJson.h"
#import "LocationChooserViewController.h"
#import "TextFieldViewController.h"
#import "StringFieldViewController.h"
#import "NumberFieldViewController.h"
#import "DateFieldViewController.h"
#import "SelectSingleViewController.h"
#import "SelectMultipleViewController.h"

@implementation ReportViewController

@synthesize previousServerURL;
@synthesize currentService;
@synthesize service_definition;
@synthesize reportForm;
@synthesize locator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Report" image:[UIImage imageNamed:@"report.png"] tag:0];
    }
    return self;
}

- (void)dealloc
{
    [locator release];
    [busyController release];
    [reportForm release];
    [service_definition release];
    [currentService release];
    [previousServerURL release];
    [reportTableView release];
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
    [self.navigationItem setTitle:@"New Report"];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Service" style:UIBarButtonItemStylePlain target:self action:@selector(chooseService)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(postReport)];
    
    // Start up the location services.
    // Do it here, so we should have a position by the time we need it.
    self.locator = [[Locator alloc] init];
    [self.locator startLocationServices];
    

    // If the user hasn't chosen a server yet, send them to the MyServers tab
    if (![[Settings sharedSettings] currentServer]) {
        self.tabBarController.selectedIndex = 3;
    }
    
}

- (void)viewDidUnload
{
    [locator release];
    [reportForm release];
    [reportTableView release];
    reportTableView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    // If the user has changed servers, the previous service they were using is no longer valid
    NSString *currentServerURL = [[[Settings sharedSettings] currentServer] objectForKey:@"URL"];
    if (![self.previousServerURL isEqualToString:currentServerURL]
        || !self.currentService) {
        self.currentService = nil;
        self.service_definition = nil;
        self.previousServerURL = currentServerURL;
        [self chooseService];
    }
    
    [reportTableView reloadData];
    [super viewWillAppear:animated];
}

#pragma mark - Service Picker Functions
/**
 * Tells the Open311 to open the service picker
 */
- (void)chooseService
{
    self.currentService = nil;
    self.service_definition = nil;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[ChooseGroupViewController alloc] initWithDelegate:self]];
    [self.navigationController presentModalViewController:nav animated:YES];
    [nav release];
}

/**
 * Handler for the Open311 service picker
 *
 * Sets the user-chosen service and loads it's service definition
 */
- (void)didSelectService:(NSDictionary *)service;
{
    DLog(@"User done selecting service");
    [self.navigationController dismissModalViewControllerAnimated:YES];
    
    if (service) {
        self.currentService = service;
        
        
        [self.navigationItem setTitle:[self.currentService objectForKey:@"service_name"]];
        [self initReportForm];
        [self loadServiceDefinition:[self.currentService objectForKey:@"service_code"]];
    }
}

#pragma mark - Report Setup

/**
 * Wipes and reloads the reportForm
 *
 * The template for the report is Report.plist in the bundle.
 * We clear out the report by reloading it from the template.
 * Then, we add in any custom attributes defined in the service.
 */
- (void)initReportForm
{
    NSError *error = nil;
    NSData *reportPlist = [[NSFileManager defaultManager] contentsAtPath:[[NSBundle mainBundle] pathForResource:@"Report" ofType:@"plist"]];
    
    self.reportForm = (NSMutableDictionary *)[NSPropertyListSerialization propertyListWithData:reportPlist options:NSPropertyListMutableContainersAndLeaves format:NULL error:&error];

    error = nil;
    
    NSMutableDictionary *data = [self.reportForm objectForKey:@"data"];
    [data setObject:[self.currentService objectForKey:@"service_code"] forKey:@"service_code"];

    Settings *settings = [Settings sharedSettings];
    NSString *jurisdiction_id = [settings.currentServer objectForKey:@"jurisdiction_id"];
    if (jurisdiction_id) {
        [data setObject:jurisdiction_id forKey:@"jurisdiction_id"];
    }
    NSString *api_key = [settings.currentServer objectForKey:@"api_key"];
    if (api_key) {
        [data setObject:api_key forKey:@"api_key"];
    }
    
    // Load the user's firstname, lastname, email, and phone number
    [data setObject:settings.first_name forKey:@"first_name"];
    [data setObject:settings.last_name forKey:@"last_name"];
    [data setObject:settings.email forKey:@"email"];
    [data setObject:settings.phone forKey:@"phone"];
    
    // Remove Media uploading for servers that don't support it
    BOOL supports_media = [[settings.currentServer objectForKey:@"supports_media"] boolValue];
    if (!supports_media) {
        DLog(@"Removing media support");
        [[self.reportForm objectForKey:@"fields"] removeObjectAtIndex:0];
        [data removeObjectForKey:@"media"];
    }

    [reportTableView reloadData];
}


/**
 * Queries the service defintion and populates reportForm with all the attributes
 *
 * If the current service does not have any metadata, there is no need 
 * to load the service_definition.  The defintion is only there to provide
 * descriptions of the custom attributes the service is expecting.
 */
- (void)loadServiceDefinition:(NSString *)service_code
{
    DLog(@"Loading service definition for %@", service_code);
    self.service_definition = nil;
    
    // Only try and load service definition from the server if there's metadata
    if ([[self.currentService objectForKey:@"metadata"] boolValue]) {
        NSURL *url = [[Open311 sharedOpen311] getServiceDefinitionURL:service_code];
        DLog(@"Loading URL: %@",[url absoluteString]);
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        [request setDelegate:self];
        [request setDidFinishSelector:@selector(handleServiceDefinitionSuccess:)];
        [request setDidFailSelector:@selector(handleServiceDefinitionFailure:)];
        [request startAsynchronous];
    }
}

/**
 * Reads the service definition and starts up a new report
 */
- (void)handleServiceDefinitionSuccess:(ASIHTTPRequest *)request
{
    self.service_definition = [[request responseString] JSONValue];
    for (NSDictionary *attribute in [self.service_definition objectForKey:@"attributes"]) {
        NSString *code = [attribute objectForKey:@"code"];
        DLog(@"Attribute found: %@",code);
        [[self.reportForm objectForKey:@"fields"] addObject:code];
        [[self.reportForm objectForKey:@"labels"] setObject:[attribute objectForKey:@"description"] forKey:code];
        [[self.reportForm objectForKey:@"types"] setObject:[attribute objectForKey:@"datatype"] forKey:code];
        if ([[attribute objectForKey:@"required"] boolValue]) {
            [[self.reportForm objectForKey:@"requiredFields"] addObject:code];
        }
        
        NSDictionary *values = [attribute objectForKey:@"values"];
        if (values) {
            [[self.reportForm objectForKey:@"values"] setObject:values forKey:code];
            DLog(@"Added values for %@",code);
        }
        
    }
    // The fields the user needs to report on have changed
    [reportTableView reloadData];
}

/**
 * Just displays a generic error message
 */
- (void)handleServiceDefinitionFailure:(ASIHTTPRequest *)request
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not load service" message:[[request url] absoluteString] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

#pragma mark - Report Posting

/**
 * Sends the report to the Open311 server
 *
 * We need to use the service definition so we can know which fields
 * are the custom attributes.  We can hard code the references to the
 * rest of the arguments, since they're defined in the spec.
 *
 * Todo: Handle responses with token instead of service_request_id
 */
- (void)postReport
{
    busyController = [[BusyViewController alloc] init];
    [self.view.superview.superview addSubview:busyController.view];
    
    NSMutableDictionary *data = [self.reportForm objectForKey:@"data"];
    NSURL *url = [[Open311 sharedOpen311] getPostServiceRequestURL];
    DLog(@"Creating POST to %@", url);
    ASIFormDataRequest *post = [ASIFormDataRequest requestWithURL:url];
    
    if ([data objectForKey:@"jursidiction_id"]) {
        [post setPostValue:[data objectForKey:@"jurisdiction_id"] forKey:@"jurisdiction_id"];
    }
    if ([data objectForKey:@"api_key"]) {
        [post setPostValue:[data objectForKey:@"api_key"] forKey:@"api_key"];
    }
    
    // Handle all the normal arguments
    [post setPostValue:[self.currentService objectForKey:@"service_code"] forKey:@"service_code"];
    [post setPostValue:[[UIDevice currentDevice] uniqueIdentifier] forKey:@"device_id"];
    [post setPostValue:[data objectForKey:@"lat"] forKey:@"lat"];
    [post setPostValue:[data objectForKey:@"long"] forKey:@"long"];
    [post setPostValue:[data objectForKey:@"address_string"] forKey:@"address_string"];
    [post setPostValue:[data objectForKey:@"description"] forKey:@"description"];
    [post setPostValue:[data objectForKey:@"first_name"] forKey:@"first_name"];
    [post setPostValue:[data objectForKey:@"last_name"] forKey:@"last_name"];
    [post setPostValue:[data objectForKey:@"email"] forKey:@"email"];
    [post setPostValue:[data objectForKey:@"phone"] forKey:@"phone"];
    
    UIImage *image = [data objectForKey:@"media"];
    if (image) {
		[post setData:UIImageJPEGRepresentation(image, 1.0) withFileName:@"media.jpg" andContentType:@"image/jpeg" forKey:@"media"];
        // Give the media enough time to upload
		[post setTimeOutSeconds:30];
    }
    
    // Handle any custom attributes in the service definition
    if (self.service_definition) {
        for (NSDictionary *attribute in [self.service_definition objectForKey:@"attributes"]) {
            NSString *code = [attribute objectForKey:@"code"];
            
            // singlevaluelist and multivaluelist need special handling, but all the rest are just strings
            NSString *type = [[self.reportForm objectForKey:@"types"] objectForKey:code];
            if ([type isEqualToString:@"multivaluelist"]) {
                for (NSDictionary *value in [data objectForKey:code]) {
                    [post addPostValue:[value objectForKey:@"key"] forKey:[NSString stringWithFormat:@"attribute[%@][]",code]];
                }
            }
            else if ([type isEqualToString:@"singlevaluelist"]) {
                [post setPostValue:[[data objectForKey:code] objectForKey:@"key"] forKey:[NSString stringWithFormat:@"attribute[%@]",code]];
            }
            else {
                [post setPostValue:[data objectForKey:code] forKey:[NSString stringWithFormat:@"attribute[%@]",code]];
            }
        }
    }
    // Handle any Media that's been attached
    // Todo:
    
    // Send in the POST
    [post setDelegate:self];
    [post setDidFinishSelector:@selector(handlePostReportSuccess:)];
    [post setDidFailSelector:@selector(handlePostReportFailure:)];
    [post startAsynchronous];
}

/**
 * Saves the report to My Reports, empties the current report,
 * then sends the user to My Reports, so they can see what they posted
 */
- (void)handlePostReportSuccess:(ASIFormDataRequest *)post
{
    if ([post responseStatusCode] >= 400) {
        [self handlePostReportFailure:post];
    }
    else {
        [busyController.view removeFromSuperview];
        busyController = nil;
        
        DLog(@"%@",[post responseString]);
        
        // Save the request into MyRequests.plist, so we can display it later.
        // We'll need to include enough information so we ask the Open311 
        // server for new information later on.
        NSArray *service_requests = [[post responseString] JSONValue];
        if (service_requests != nil) {
            NSDictionary *request = [service_requests objectAtIndex:0];
            NSString *service_request_id = [request objectForKey:@"service_request_id"] ? [request objectForKey:@"service_request_id"] : @"";
            NSString *token = [request objectForKey:@"token"] ? [request objectForKey:@"token"] : @"";
            
            NSArray *storedData = [NSArray arrayWithObjects:
                                   [[Settings sharedSettings] currentServer],
                                   self.currentService,
                                   service_request_id,
                                   token,
                                   [NSDate date], nil];
            NSArray *storedKeys = [NSArray arrayWithObjects:@"server", @"service", @"service_request_id", @"token", @"date", nil];
            [[[Settings sharedSettings] myRequests] addObject:[NSMutableDictionary dictionaryWithObjects:storedData forKeys:storedKeys]];
            DLog(@"POST saved, count is now %@", [[Settings sharedSettings] myRequests]);
        }
        
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Report Sent" message:@"Thank you, your report has been submitted." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        // Clear the report form
        [self initReportForm];
        self.currentService = nil;
        self.service_definition = nil;
        
        self.tabBarController.selectedIndex = 2;
    }
}

/**
 * Tries to display any Open311 error message that might be in the response
 */
- (void)handlePostReportFailure:(ASIFormDataRequest *)post
{
    [busyController.view removeFromSuperview];
    busyController = nil;
    
    DLog(@"%@",[post responseString]);
    if ([post error]) {
        DLog(@"Error reported %@",[[post error] description]);
    }
    DLog(@"Status code was %@", [NSString stringWithFormat:@"%d",[post responseStatusCode]]);
    NSString *message = [NSString stringWithFormat:@"An error occurred while sending your report to the server.   You might try again later."];
    if ([post responseString]) {
        DLog(@"%@",[post responseString]);
        NSArray *errors = [[post responseString] JSONValue];
        NSString *description = [[errors objectAtIndex:0] objectForKey:@"description"];
        if (description) {
            message = description;
        }
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sending Failed" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [alert release];
}


#pragma mark - Table View Handlers
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.currentService) {
        NSString *serviceDescription = [self.currentService objectForKey:@"description"];
        NSString *serviceName = [self.currentService objectForKey:@"service_name"];
        DLog(@"Loaded service description: %@", serviceDescription);
        if (([self.currentService objectForKey:@"description"]==[NSNull null] || [serviceDescription length] == 0)
            && serviceName) {
            return [NSString stringWithFormat:@"Report %@",serviceName];
        }
        else {
            return serviceDescription;
        }
    }
    return @"Choose a service to report to";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.reportForm objectForKey:@"fields"] count];
}

/**
 * Render the labels and the text values the user has provided
 *
 * We can check the fieldname to decide if we want to apply custom formatting
 * for the user-provided value
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    
    NSString *fieldname = [[self.reportForm objectForKey:@"fields"] objectAtIndex:indexPath.row];
    NSString *type = [[self.reportForm objectForKey:@"types"] objectForKey:fieldname];
    
    cell.textLabel.text = [[self.reportForm objectForKey:@"labels"] objectForKey:fieldname];
    cell.detailTextLabel.text = nil;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.imageView.image = nil;
    
    if ([[self.reportForm objectForKey:@"requiredFields"] containsObject:fieldname]) {
        cell.textLabel.text = [NSString stringWithFormat:@"* %@",cell.textLabel.text];
    }
    
    // Populate the user-provided data
    NSMutableDictionary *data = [self.reportForm objectForKey:@"data"];
    if ([fieldname isEqualToString:@"media"]) {
        [cell.imageView setFrame:CGRectMake(0, 0, 64, 40)];
        [cell.imageView setContentMode:UIViewContentModeScaleAspectFit];
        cell.imageView.image = [data objectForKey:@"media"];
    }
    else if ([fieldname isEqualToString:@"address_string"]) {
        NSString *address = [data objectForKey:@"address_string"];
        NSString *latitude = [data objectForKey:@"lat"];
        NSString *longitude = [data objectForKey:@"long"];
        cell.detailTextLabel.text = address;
        if ([address length]==0 && [latitude length]!=0 && [longitude length]!=0) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@",latitude,longitude];
            CLLocation *location = [[CLLocation alloc] initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
            MKReverseGeocoder *geocoder = [[MKReverseGeocoder alloc] initWithCoordinate:location.coordinate];
            geocoder.delegate = self;
            [geocoder start];
            [location release];
            [geocoder release];
        }
    }
    else {
        // Apply any custom formatting based on data type
        if ([type isEqualToString:@"singlevaluelist"]) {
            cell.detailTextLabel.text = [[data objectForKey:fieldname] objectForKey:@"name"];
        }
        else if ([type isEqualToString:@"multivaluelist"]) {
            NSString *selectionText = @"";
            for (NSDictionary *selection in [data objectForKey:fieldname]) {
                selectionText = [selectionText stringByAppendingFormat:@"%@, ",[selection objectForKey:@"name"]];
            }
            cell.detailTextLabel.text = selectionText;
        }
        else {
            cell.detailTextLabel.text = [data objectForKey:fieldname];
        }
    }
    
    return cell;
}

/**
 * Create a new view controller based on the data type of the row the user chooses
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Find out what data type the row is and display the appropriate view
    NSString *fieldname = [[self.reportForm objectForKey:@"fields"] objectAtIndex:indexPath.row];
    NSString *type = [[self.reportForm objectForKey:@"types"] objectForKey:fieldname];
    if ([type isEqualToString:@"media"]) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = NO;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentModalViewController:picker animated:YES];
            [picker release];
        }
    }
    if ([type isEqualToString:@"location"]) {
        LocationChooserViewController *chooseLocation = [[LocationChooserViewController alloc] initWithReport:self.reportForm];
        [chooseLocation setLocator:self.locator];
        [self.navigationController pushViewController:chooseLocation animated:YES];
        [chooseLocation release];
    }
    if ([type isEqualToString:@"text"]) {
        TextFieldViewController *editTextController = [[TextFieldViewController alloc] initWithFieldname:fieldname report:self.reportForm];
        [self.navigationController pushViewController:editTextController animated:YES];
        [editTextController release];
    }
    if ([type isEqualToString:@"string"]) {
        StringFieldViewController *editStringController = [[StringFieldViewController alloc] initWithFieldname:fieldname report:self.reportForm];
        [self.navigationController pushViewController:editStringController animated:YES];
        [editStringController release];
    }
    if ([type isEqualToString:@"number"]) {
        NumberFieldViewController *editNumberController = [[NumberFieldViewController alloc] initWithFieldname:fieldname report:self.reportForm];
        [self.navigationController pushViewController:editNumberController animated:YES];
        [editNumberController release];
        
    }
    if ([type isEqualToString:@"datetime"]) {
        DateFieldViewController *dateController = [[DateFieldViewController alloc] initWithFieldname:fieldname report:self.reportForm];
        [self.navigationController pushViewController:dateController animated:YES];
        [dateController release];
    }
    if ([type isEqualToString:@"singlevaluelist"]) {
        SelectSingleViewController *selectController = [[SelectSingleViewController alloc] initWithFieldname:fieldname report:self.reportForm];
        [self.navigationController pushViewController:selectController animated:YES];
        [selectController release];
    }
    if ([type isEqualToString:@"multivaluelist"]) {
        SelectMultipleViewController *multiController = [[SelectMultipleViewController alloc] initWithFieldname:fieldname report:reportForm];
        [self.navigationController pushViewController:multiController animated:YES];
        [multiController release];
    }
}

#pragma mark - Image Choosing Functions

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    // Older versions of iOS use parentViewController.  In iOS 5 the meaning of parentView changed
    // iOS5 now uses presentingViewController
    if ([self respondsToSelector:@selector(presentingViewController)]) {
        [picker.presentingViewController dismissModalViewControllerAnimated:YES];
    }
    else {
        [picker.parentViewController dismissModalViewControllerAnimated:YES];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];

	//resize the image that will be sent to city webservice
	CGFloat originalWidth = image.size.width;
	CGFloat originalHeight = image.size.height;
	CGFloat smallerDimensionMultiplier;
	CGFloat newWidth;
	CGFloat newHeight;
	if (originalWidth > originalHeight) {
		smallerDimensionMultiplier = originalHeight / originalWidth;
		newWidth = 800;
		newHeight = newWidth * smallerDimensionMultiplier;
	}
	else {
		smallerDimensionMultiplier = originalWidth / originalHeight;
		newHeight =  800;
		newWidth = newHeight * smallerDimensionMultiplier;
	}
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [image drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
	UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [[self.reportForm objectForKey:@"data"] setObject:resizedImage forKey:@"media"];

    // Older versions of iOS use parentViewController.  In iOS 5 the meaning of parentView changed
    // iOS5 now uses presentingViewController
    if ([self respondsToSelector:@selector(presentingViewController)]) {
        [picker.presentingViewController dismissModalViewControllerAnimated:YES];
    }
    else {
        [picker.parentViewController dismissModalViewControllerAnimated:YES];
    }
}

#pragma mark - Reverse Geocoder Delegate Functions

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
    NSString *address = [[placemark.addressDictionary objectForKey:@"FormattedAddressLines"] objectAtIndex:0];
    [[reportForm objectForKey:@"data"] setObject:address forKey:@"address_string"];
    [reportTableView reloadData];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    // Just ignore any errors.  We don't really need an address string.
    // We're only displaying it to be all fancy.
    // The only thing that matters on submission will be the lat/long
}

@end
