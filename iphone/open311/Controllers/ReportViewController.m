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
 * @copyright 2011-2012 City of Bloomington, Indiana. All Rights Reserved
 * @author Cliff Ingham <inghamn@bloomington.in.gov>
 * @license http://www.gnu.org/licenses/gpl.txt GNU/GPLv3, see LICENSE.txt
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */

#import <AddressBook/AddressBook.h>
#import <MobileCoreServices/UTCoreTypes.h>
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

// We're organizing the table view into these sections
int const kLocationSection   = 0;
int const kProblemSection    = 1;
int const kAdditionalSection = 2;
int const kPersonalSection   = 3;

@implementation ReportViewController

@synthesize previousServerURL;
@synthesize currentService;
@synthesize service_definition;
@synthesize reportForm;
@synthesize locator;
@synthesize serviceMessages;

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
    [serviceMessages release];
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
        
        [self.navigationItem setTitle:[self.currentService objectForKey:kServiceName]];
        [self initReportForm];
        [self loadServiceDefinition:[self.currentService objectForKey:kServiceCode]];
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
    [data setObject:[self.currentService objectForKey:kServiceCode] forKey:kServiceCode];

    // Load the user's firstname, lastname, email, and phone number
    Settings *settings = [Settings sharedSettings];
    [data setObject:settings.first_name	forKey:kFirstname];
    [data setObject:settings.last_name	forKey:kLastname];
    [data setObject:settings.email		forKey:kEmail];
    [data setObject:settings.phone		forKey:kPhone];
    
    // Remove Media uploading for servers that don't support it
    BOOL supports_media = [[settings.currentServer objectForKey:@"supports_media"] boolValue];
    if (!supports_media || [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]==NO) {
        DLog(@"Removing media support");
        [[[self.reportForm objectForKey:@"fields"] objectAtIndex:kLocationSection] removeObjectAtIndex:0];
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
    DLog(@"Service Defition: %@", [request responseString]);
    self.service_definition = [[request responseString] JSONValue];
    if (!self.service_definition) {
        [[Open311 sharedOpen311] responseFormatInvalid:request];
    }
    
    self.serviceMessages = @"";
    
    NSMutableArray *attributeFields = [[self.reportForm objectForKey:@"fields"] objectAtIndex:kAdditionalSection];
	
	for (NSDictionary *attribute in [self.service_definition objectForKey:kAttributes]) {
        NSString *code = [attribute objectForKey:@"code"];
        DLog(@"Attribute found: %@",code);
        if ([[attribute objectForKey:@"variable"] boolValue]) {
            NSMutableDictionary *entry = [[NSMutableDictionary alloc] init];
            [entry setObject:code                                   forKey:@"fieldname"];
            [entry setObject:[attribute objectForKey:kDescription]  forKey:@"label"];
            [entry setObject:[attribute objectForKey:kDatatype]     forKey:@"type"];
            
            if ([[attribute objectForKey:kRequired] boolValue]) {
                [[self.reportForm objectForKey:@"requiredFields"] addObject:code];
            }
            
            NSDictionary *values = [attribute objectForKey:@"values"];
            if (values) {
                [entry setObject:values forKey:@"values"];
                DLog(@"Added values for %@",code);
            }
            [attributeFields addObject:entry];
            [entry release];
        }
        else {
            self.serviceMessages = [self.serviceMessages stringByAppendingFormat:@"\n%@", [attribute objectForKey:kDescription]];
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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not load service" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
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
 */
- (void)postReport
{
    busyController = [[BusyViewController alloc] init];
    [self.view.superview.superview addSubview:busyController.view];
    
    NSMutableDictionary *data = [self.reportForm objectForKey:@"data"];
    NSURL *url = [[Open311 sharedOpen311] getPostServiceRequestURL];
    DLog(@"Creating POST to %@", url);
    ASIFormDataRequest *post = [ASIFormDataRequest requestWithURL:url];
    
    Settings *settings = [Settings sharedSettings];
    NSString *jurisdiction_id	= [settings.currentServer objectForKey:kJurisdictionId];
    NSString *api_key			= [settings.currentServer objectForKey:kApiKey];
    if (jurisdiction_id)	[post setPostValue:jurisdiction_id	forKey:kJurisdictionId];
    if (api_key)			[post setPostValue:api_key			forKey:kApiKey];
    
    // Handle all the normal arguments
    [post setPostValue:[self.currentService objectForKey:kServiceCode] forKey:kServiceCode];
    [post setPostValue:[[UIDevice currentDevice] uniqueIdentifier] forKey:kDeviceId];
    [post setPostValue:[data objectForKey:@"lat"]				forKey:kLat];
    [post setPostValue:[data objectForKey:@"long"]				forKey:kLong];
    [post setPostValue:[data objectForKey:@"address_string"]	forKey:kAddressString];
    [post setPostValue:[data objectForKey:@"description"]		forKey:kDescription];
    [post setPostValue:[data objectForKey:@"first_name"]		forKey:kFirstname];
    [post setPostValue:[data objectForKey:@"last_name"]			forKey:kLastname];
    [post setPostValue:[data objectForKey:@"email"]				forKey:kEmail];
    [post setPostValue:[data objectForKey:@"phone"]				forKey:kPhone];
    
    UIImage *image = [data objectForKey:@"media"];
    if (image) {
		[post setData:UIImageJPEGRepresentation(image, 1.0) withFileName:@"media.jpg" andContentType:@"image/jpeg" forKey:@"media"];
        // Give the media enough time to upload
		[post setTimeOutSeconds:30];
    }
    
    // Handle any custom attributes in the service definition
    if (self.service_definition) {
        for (NSDictionary *entry in [[self.reportForm objectForKey:@"fields"] objectAtIndex:kAdditionalSection]) {
            NSString *code = [entry objectForKey:@"fieldname"];
            NSString *type = [entry objectForKey:@"type"];
            
            // singlevaluelist and multivaluelist need special handling, but all the rest are just strings
            if ([type isEqualToString:kMultiValueList]) {
                for (NSDictionary *value in [data objectForKey:code]) {
                    [post addPostValue:[value objectForKey:@"key"] forKey:[NSString stringWithFormat:@"attribute[%@][]",code]];
                }
            }
            else if ([type isEqualToString:kSingleValueList]) {
                [post setPostValue:[[data objectForKey:code] objectForKey:@"key"] forKey:[NSString stringWithFormat:@"attribute[%@]",code]];
            }
            else {
                [post setPostValue:[data objectForKey:code] forKey:[NSString stringWithFormat:@"attribute[%@]",code]];
            }
        }
    }
    
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
            NSString *service_request_id = [request objectForKey:kServiceRequestId] ? [request objectForKey:kServiceRequestId] : @"";
            NSString *token = [request objectForKey:kToken] ? [request objectForKey:kToken] : @"";
            
            NSArray *storedData = [NSArray arrayWithObjects:
                                   [[Settings sharedSettings] currentServer],
                                   self.currentService,
                                   service_request_id,
                                   token,
                                   [NSDate date], nil];
            NSArray *storedKeys = [NSArray arrayWithObjects:@"server", @"service", kServiceRequestId, kToken, @"date", nil];
            [[[Settings sharedSettings] myRequests] addObject:[NSMutableDictionary dictionaryWithObjects:storedData forKeys:storedKeys]];
            DLog(@"POST saved, count is now %@", [[Settings sharedSettings] myRequests]);
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Report Sent" message:@"Thank you, your report has been submitted." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            [alert release];
            
            // Clear the report form
            [self initReportForm];
            self.currentService = nil;
            self.service_definition = nil;
            
            self.tabBarController.selectedIndex = 2;
        }
        else {
            [[Open311 sharedOpen311] responseFormatInvalid:post];
        }
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
        NSString *description = [[errors objectAtIndex:0] objectForKey:kDescription];
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
    return [[[self.reportForm objectForKey:@"fields"] objectAtIndex:kAdditionalSection] count]==0 ? 3 : 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == kLocationSection && self.currentService) {
        NSString *serviceDescription	= [self.currentService objectForKey:kDescription];
        NSString *serviceName			= [self.currentService objectForKey:kServiceName];
        NSString *title;
        
        DLog(@"Loaded service description: %@", serviceDescription);
        if (([self.currentService objectForKey:kDescription]==[NSNull null] || [serviceDescription length] == 0)
            && serviceName) {
            title = [NSString stringWithFormat:@"Report %@",serviceName];
        }
        else {
            title = serviceDescription;
        }
        if (self.serviceMessages) {
            title = [title stringByAppendingString:self.serviceMessages];
        }
        return title;
    }
    else {
        return section==kLocationSection ? @"Choose a service to report to" : nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self.reportForm objectForKey:@"fields"] objectAtIndex:[self transpose:section]] count];
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
    
    NSDictionary *entry = [[[self.reportForm objectForKey:@"fields"] objectAtIndex:[self transpose:indexPath.section]] objectAtIndex:indexPath.row];
    NSString *fieldname = [entry objectForKey:@"fieldname"];
    NSString *type      = [entry objectForKey:@"type"];
    
    cell.textLabel.text = [entry objectForKey:@"label"];
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
    else if ([fieldname isEqualToString:kAddressString]) {
        NSString *address   = [data objectForKey:kAddressString];
        NSString *latitude  = [data objectForKey:kLat];
        NSString *longitude = [data objectForKey:kLong];
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
        if ([type isEqualToString:kSingleValueList]) {
            cell.detailTextLabel.text = [[data objectForKey:fieldname] objectForKey:@"name"];
        }
        else if ([type isEqualToString:kMultiValueList]) {
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
    NSDictionary *entry = [[[self.reportForm objectForKey:@"fields"] objectAtIndex:[self transpose:indexPath.section]] objectAtIndex:indexPath.row];
    NSString *type      = [entry objectForKey:@"type"];
    if ([type isEqualToString:@"media"]) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES) {
            UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
            popup.actionSheetStyle = UIActionSheetStyleBlackOpaque;
            [popup addButtonWithTitle:@"Take Photo"];
            [popup addButtonWithTitle:@"Choose From Library"];
            [popup addButtonWithTitle:@"Cancel"];
            popup.cancelButtonIndex = 2;
            [popup showInView:self.view];
            [popup release];
        }
    }
    if ([type isEqualToString:@"location"]) {
        LocationChooserViewController *c = [[LocationChooserViewController alloc] initWithReport:self.reportForm];
        [c setLocator:self.locator];
        [self.navigationController pushViewController:c animated:YES];
        [c release];
    }
    if ([type isEqualToString:@"text"]) {
        TextFieldViewController      *c = [[TextFieldViewController      alloc] initWithReportFormEntry:entry report:self.reportForm];
        [self.navigationController pushViewController:c animated:YES];
        [c release];
    }
    if ([type isEqualToString:@"string"]) {
        StringFieldViewController    *c = [[StringFieldViewController    alloc] initWithReportFormEntry:entry report:self.reportForm];
        [self.navigationController pushViewController:c animated:YES];
        [c release];
    }
    if ([type isEqualToString:@"number"]) {
        NumberFieldViewController    *c = [[NumberFieldViewController    alloc] initWithReportFormEntry:entry report:self.reportForm];
        [self.navigationController pushViewController:c animated:YES];
        [c release];
    }
    if ([type isEqualToString:@"datetime"]) {
        DateFieldViewController      *c = [[DateFieldViewController      alloc] initWithReportFormEntry:entry report:self.reportForm];
        [self.navigationController pushViewController:c animated:YES];
        [c release];
    }
    if ([type isEqualToString:kSingleValueList]) {
        SelectSingleViewController   *c = [[SelectSingleViewController   alloc] initWithReportFormEntry:entry report:self.reportForm];
        [self.navigationController pushViewController:c animated:YES];
        [c release];
    }
    if ([type isEqualToString:kMultiValueList]) {
        SelectMultipleViewController *c = [[SelectMultipleViewController alloc] initWithReportFormEntry:entry report:self.reportForm];
        [self.navigationController pushViewController:c animated:YES];
        [c release];
    }
}

#pragma mark - Image Choosing Functions
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 2) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
        picker.sourceType = buttonIndex == 0
            ? UIImagePickerControllerSourceTypeCamera
            : UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentModalViewController:picker animated:YES];
        [picker release];
    }
}

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
    [[reportForm objectForKey:@"data"] setObject:address forKey:kAddressString];
    [reportTableView reloadData];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    // Just ignore any errors.  We don't really need an address string.
    // We're only displaying it to be all fancy.
    // The only thing that matters on submission will be the lat/long
}

# pragma mark - Internal Helper Functions
/**
 * Transposes the section number based on whether there's Additional Info or not
 *
 * Services might not have addition attributes.  If the current service does not
 * have any attributes, there's no reason to display an empty Table Section 
 * for Addtional Info.  In this case, we just change the section number to point
 * to the Personal Info fields inside the reportForm.
 *
 * @param NSInteger section This is usually indexPath.section
 * @return int
 */
- (int)transpose:(NSInteger)section
{
    if (section == kAdditionalSection 
        && [[[self.reportForm objectForKey:@"fields"] objectAtIndex:kAdditionalSection] count]==0)  {
        section = kPersonalSection;
    }
    return section;
}
@end
