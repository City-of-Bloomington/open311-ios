/**
 * @copyright 2013 City of Bloomington, Indiana. All Rights Reserved
 * @author Marius Constantinescu <constantinescu.marius@gmail.com>
 * @license http://www.gnu.org/licenses/gpl.txt GNU/GPLv3, see LICENSE.txt
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */

#import "NewReportController.h"
#import "Strings.h"
#import "Preferences.h"
#import "Open311.h"
#import "TextCell.h"
#import "LocationCell.h"
#import "MultiValueListCell.h"
#import "SingleValueListCell.h"
#import "StringCell.h"
#import "MediaCell.h"
#import "FooterCell.h"
#import "SVProgressHUD.h"
#import <QuartzCore/QuartzCore.h>
#import "Maps.h"

@implementation NewReportController
NSMutableArray *fields;
NSIndexPath *currentIndexPath;
NSString *currentServerName;

ALAssetsLibrary *library;
NSURL   *mediaUrl;
UIImage *mediaThumbnail;

NSString *header;

CLLocation *locationFromLocationController;

static NSString * const kSegueToLocation        = @"SegueToLocation";
static NSString * const kReportCell             = @"report_cell";
static NSString * const kReportTextCell         = @"report_text_cell";
static NSString * const kFooterCell             = @"report_footer_cell";
static NSString * const kReportLocationCell     = @"report_location_cell";
static NSString * const kReportSingleValueCell  = @"report_sinlge_value_cell";
static NSString * const kReportMultiValueCell   = @"report_multi_value_cell";
static NSString * const kReportStringCell       = @"report_string_cell";
static NSString * const kReportMediaCell        = @"report_media_cell";
static NSString * const kReportSwitchCell       = @"report_switch_cell";
static NSString * const kFieldname              = @"fieldname";
static NSString * const kLabel                  = @"label";
static NSString * const kType                   = @"type";
static NSString * const kUnwindSegueFromReportToHome = @"UnwindSegueFromReportToHome";
CLLocationManager *locationManager;
CLLocationCoordinate2D currentLocation;


/**
 * Creates a multi-dimensional array to represent the fields to display in the table view.
 *
 * You can access individual cells like so:
 * fields[row][@"fieldname"]
 *            [@"label"]
 *            [@"type"]
 *
 * Pointers to the full attribute definitions will also be stored in |fields|
 * fields[row][@"attribute"] = NSDictionary *attribute
 *
 * The actual stuff the user enters will be stored in the ServiceRequest
 * This data structure is only for display
 */
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[self.sendButton setTitle:NSLocalizedString(kUI_Submit, nil)];
	
	//make view controller start below navigation bar; this works in iOS 7
	if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
		self.edgesForExtendedLayout = UIRectEdgeNone;
	}
	
	locationManager = [[CLLocationManager alloc] init];
	locationManager.delegate = self;
	locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
	locationManager.distanceFilter = 50;
	[locationManager startUpdatingLocation];
	
	locationFromLocationController = nil;
	currentServerName = [[Preferences sharedInstance] getCurrentServer][kOpen311_Name];
	
	// First section: Photo and Location choosers
	fields = [[NSMutableArray alloc] init];
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES
		&& [[[Preferences sharedInstance] getCurrentServer][kOpen311_SupportsMedia] boolValue]) {
		// Initialize the Asset Library object for saving/reading images
		library = [[ALAssetsLibrary alloc] init];
        [fields addObject:@{kFieldname:kOpen311_Media,   kLabel:NSLocalizedString(kUI_AddPhoto,          nil), kType:kOpen311_Media  }];
	}
    [fields addObject:@{kFieldname:kOpen311_Address,     kLabel:NSLocalizedString(kUI_Location,          nil), kType:kOpen311_Address}];
	[fields addObject:@{kFieldname:kOpen311_Description, kLabel:NSLocalizedString(kUI_ReportDescription, nil), kType:kOpen311_Text}];
	
	header = _report.service[kOpen311_Description];
	if (_report.service[kOpen311_Metadata]) {
		for (NSDictionary *attribute in _report.serviceDefinition[kOpen311_Attributes]) {
			// According to the spec, attribute paramters need to be named:
			// attribute[code]
			//
			// Multivaluelist values will be arrays.  Because of that, the HTTPClient
			// will append the appropriate "[]" when the POST is created.  We do not
			// need to use a special name here for the Multivaluelist attributes.
			if ([attribute[kOpen311_Variable] boolValue]) {
				NSString *code = [NSString stringWithFormat:@"%@[%@]", kOpen311_Attribute, attribute[kOpen311_Code]];
				NSString *type = attribute[kOpen311_Datatype];
				
				[fields addObject:@{kFieldname:code, kLabel:attribute[kOpen311_Description], kType:type, kOpen311_Attribute:attribute}];
			}
			else {
				// This is an information-only attribute.
				// Save it somewhere so we can display those differently
				//header = [header stringByAppendingFormat:@"\n%@", attribute[kOpen311_Description]];
			}
		}
	}
    
	self.navigationItem.title = _report.service[kOpen311_ServiceName];
	
	//add empty footer so that empty rows will not be shown at the end of the table
	[self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
	
	// Table Header
	CGSize headerSize = [header sizeWithFont:[UIFont fontWithName:@"Heiti SC" size:13]
                           constrainedToSize:CGSizeMake(280, CGFLOAT_MAX)
                               lineBreakMode:NSLineBreakByWordWrapping];
	
	self.headerViewLabel.backgroundColor = [UIColor clearColor];
	self.headerViewLabel.textColor = [UIColor colorWithRed:78/255.0f green:84/255.0f blue:102/255.0f alpha:1];
	self.headerViewLabel.text = header;
	self.headerView.frame = CGRectMake(20, 8, 280, headerSize.height + 5 + 8);
	
	self.tableView.tableHeaderView = self.headerView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [fields count] + 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The last row in the table is the anonymous switch cell
    // It does not have an entry in |fields|
    if (indexPath.row == [fields count]) {
        return 50;
    }
	
	NSDictionary *field = fields[indexPath.row];
	NSString *type  = field[kType];
    NSString *label = field[kLabel];
    CGSize headerSize = [label sizeWithFont:[UIFont fontWithName:@"Heiti SC" size:15]
                          constrainedToSize:CGSizeMake(280, CGFLOAT_MAX)
                              lineBreakMode:NSLineBreakByWordWrapping];
    
    NSUInteger numValues = ([type isEqualToString:kOpen311_SingleValueList] || [type isEqualToString:kOpen311_MultiValueList])
        ? [field[kOpen311_Attribute][kOpen311_Values] count]
        : 0;
    
	if ([type isEqualToString:kOpen311_Text]) {
		return headerSize.height + TEXT_CELL_BOTTOM_SPACE + TEXT_CELL_TEXT_VIEW_HEIGHT;
	}
	else if ([type isEqualToString:kOpen311_SingleValueList]) {
		return headerSize.height + 2 + SINGLE_VALUE_INNER_CELL_BOTTOM_SPACE + SINGLE_VALUE_INNER_CELL_HEIGHT * numValues;
	}
	else if ([type isEqualToString:kOpen311_MultiValueList]){
		return headerSize.height + 2 + MULTI_VALUE_INNER_CELL_BOTTOM_SPACE  + MULTI_VALUE_INNER_CELL_HEIGHT  * numValues;
	}
	else if ([type isEqualToString:kOpen311_String]) {
		return headerSize.height + 2 + STRING_CELL_BOTTOM_SPACE + STRING_CELL_TEXT_FIELD_HEIGHT;
	}
	else if ([type isEqualToString:kOpen311_Address]) {
		return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            ? LOCATION_CELL_HEIGHT_IPAD
            : LOCATION_CELL_HEIGHT;
    }
	else if ([type isEqualToString:kOpen311_Media]) { return MEDIA_CELL_HEIGHT; }
	return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The last row in the table is the anonymous switch cell
    // It does not have an entry in |fields|
    if (indexPath.row == [fields count]) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kFooterCell forIndexPath:indexPath];
		FooterCell* footerCell = (FooterCell*) cell;
		footerCell.anonymousHeader.text = NSLocalizedString(kUI_ReportAnonymousHeader, nil);
		footerCell.anonymousDetails.text = NSLocalizedString(kUI_ReportAnonymousDetails, nil);
		
		return footerCell;
	}
	NSDictionary *field = fields[indexPath.row];
	NSString *type  = field[kType];
    NSString *label = field[kLabel];
    
	if ([type isEqualToString:kOpen311_Text]) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReportTextCell forIndexPath:indexPath];
		TextCell* textCell = (TextCell*) cell;
		textCell.header.text = label;
		textCell.delegate = self;
		textCell.fieldname = field[kFieldname];
		// appearance customization
        textCell.text.layer.borderColor = [[UIColor orangeColor] CGColor];
        
		// get text from the datasource
		if (_report.postData[field[kFieldname]] != nil) {
			textCell.text.text = _report.postData[field[kFieldname]];
		}
		return textCell;
	}
	if ([type isEqualToString:kOpen311_Address]) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReportLocationCell forIndexPath:indexPath];
		LocationCell* locationCell = (LocationCell*) cell;
		locationCell.header.text = label;
		if (_report.postData[kOpen311_Latitude] != nil && _report.postData[kOpen311_Longitude] != nil &&
			_report.postData[kOpen311_Latitude] != 0   && _report.postData[kOpen311_Longitude] != 0) {
			
			CLLocationCoordinate2D point = {
                [_report.postData[kOpen311_Latitude ] doubleValue],
                [_report.postData[kOpen311_Longitude] doubleValue]
            };
            [Maps zoomMap:locationCell.mapView toCoordinate:point withMarker:YES];
		}
		else {
            [Maps zoomMap:locationCell.mapView toCoordinate:currentLocation withMarker:NO];
		}
		return locationCell;
	}
	if ([type isEqualToString:kOpen311_MultiValueList]) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReportMultiValueCell forIndexPath:indexPath];
		MultiValueListCell* multiValueListCell = (MultiValueListCell*) cell;
		multiValueListCell.delegate = self;
		multiValueListCell.fieldname = field[kFieldname];
		multiValueListCell.attribute = field[kOpen311_Attribute];
		multiValueListCell.header.text = label;
		if (_report.postData[field[kFieldname]] != nil) {
			multiValueListCell.selectedOptions = _report.postData[field[kFieldname]];
        }
		else {
			multiValueListCell.selectedOptions = nil;
        }
		return multiValueListCell;
	}
	if ([type isEqualToString:kOpen311_SingleValueList]) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReportSingleValueCell forIndexPath:indexPath];
		SingleValueListCell* singleValueListCell = (SingleValueListCell*) cell;
		singleValueListCell.delegate = self;
		singleValueListCell.fieldname = field[kFieldname];
		singleValueListCell.attribute = field[kOpen311_Attribute];
		singleValueListCell.header.text = field[kLabel];
		if (_report.postData[field[kFieldname]] != nil) {
			singleValueListCell.selectedOption = _report.postData[field[kFieldname]];
        }
		else {
			singleValueListCell.selectedOption = nil;
        }
		return singleValueListCell;
	}
	if ([type isEqualToString:kOpen311_String]) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReportStringCell forIndexPath:indexPath];
		StringCell* stringCell = (StringCell*) cell;
		stringCell.header.text = label;
		stringCell.delegate = self;
		stringCell.fieldname = field[kFieldname];
		// appearance customization
		stringCell.textField.layer.borderColor = [[UIColor orangeColor] CGColor];
		// get text from the datasource
		if (_report.postData[field[kFieldname]] != nil) {
			stringCell.textField.text = _report.postData[field[kFieldname]];
		}
		return stringCell;
	}
	if ([type isEqualToString:kOpen311_Media]) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReportMediaCell forIndexPath:indexPath];
		MediaCell* mediaCell = (MediaCell*) cell;
		
		mediaCell.header.text = NSLocalizedString(kUI_AddPhoto, nil);
		NSURL *url = _report.postData[kOpen311_Media];
		if (url != nil) {
			// When the user-selected mediaUrl changes, we need to load a fresh thumbnail image
			// This is an async call, that could take some time.
			if (![mediaUrl isEqual:url]) {
				[library assetForURL:url
						 resultBlock:^(ALAsset *asset) {
							 // Once we finally get the image loaded, we need to tell the
							 // table to redraw itself, which should pick up the new |mediaThumbnail|
							 mediaThumbnail = [UIImage imageWithCGImage:[asset thumbnail]];
						 }
						failureBlock:^(NSError *error) {
							DLog(@"Failed to load thumbnail from library");
						}];
			}
			if (mediaThumbnail != nil) {
				[mediaCell.image setImage:mediaThumbnail];
				mediaCell.header.text = NSLocalizedString(kUI_ChangePhoto, nil);
				mediaCell.closeImage.hidden = NO;
			}
		}
		return mediaCell;
	}
	//it should NEVER get here. It should always go on an if branch
	return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *type = fields[indexPath.row][kType];
    
    if ([type isEqualToString:kOpen311_Media]) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES) {
            UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(kUI_ChooseMediaSource, nil)
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                 destructiveButtonTitle:nil
                                                      otherButtonTitles:nil, nil];
            popup.actionSheetStyle = UIActionSheetStyleBlackOpaque;
            [popup addButtonWithTitle:NSLocalizedString(kUI_Camera,  nil)];
            [popup addButtonWithTitle:NSLocalizedString(kUI_Gallery, nil)];
            [popup addButtonWithTitle:NSLocalizedString(kUI_Cancel,  nil)];
            [popup setCancelButtonIndex:2];
            [popup showInView:self.view];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

# pragma mark Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:kSegueToLocation]) {
		[segue.destinationViewController setDelegate:self];
		LocationController *destinationController = (LocationController*)segue.destinationViewController;
		if (locationFromLocationController.coordinate.latitude != 0 && locationFromLocationController.coordinate.longitude != 0) {
			destinationController.selectedLocation = locationFromLocationController;
		}
	}
}

#pragma mark - TextEntryDelegate
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.tableView.contentInset          = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, _currentTextEntry.frame.origin) ) {
        [self.tableView scrollRectToVisible:_currentTextEntry.frame animated:YES];
    }
}

- (void)didProvideValue:(NSString *)value fromField:(NSString *)field
{
	if (value != nil) {
		_report.postData[field] = value;
    }
	else {
		[_report.postData removeObjectForKey:field];
    }
	[self.tableView reloadData];
}

#pragma mark - MultiValueDelegate
- (void)didProvideValues:(NSArray *)values fromField:(NSString*)field
{
	if (values != nil) {
		_report.postData[field] = values;
    }
	else {
		[_report.postData removeObjectForKey:field];
    }
	[self.tableView reloadData];
}

#pragma mark - Location delegate
- (void)didChooseLocation:(CLLocationCoordinate2D)location
{
	locationFromLocationController = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];
	if (location.latitude != 0 && location.longitude != 0) {
		
		_report.postData[kOpen311_Latitude]  = [NSString stringWithFormat:@"%f", location.latitude];
		_report.postData[kOpen311_Longitude] = [NSString stringWithFormat:@"%f", location.longitude];
		
		CLGeocoder *geocoder = [[CLGeocoder alloc] init];
		[geocoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude]
					   completionHandler:^(NSArray *placemarks, NSError *error) {
						   NSString *address = [placemarks[0] name];
						   _report.postData[kOpen311_AddressString] = address ? address : @"";
						   [self.tableView reloadData];
					   }];
		
		
	}
	[self.tableView reloadData];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
	CLLocation* location = [locations lastObject];
	currentLocation = location.coordinate;
	[self.tableView reloadData];
}

#pragma mark - Image choosing handlers
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
		[self presentViewController:picker animated:YES completion:nil];
	}
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
	if (info[UIImagePickerControllerMediaMetadata] != nil) {
		// The user took a picture with the camera.
		// We need to save that picture and just use the reference to it from the Saved Photos library.
		[library writeImageToSavedPhotosAlbum:[image CGImage]
									 metadata:info[UIImagePickerControllerMediaMetadata]
							  completionBlock:^(NSURL *assetURL, NSError *error) {
								  _report.postData[kOpen311_Media] = assetURL;
								  [self refreshMediaThumbnail];
							  }];
	}
	else {
		// The user chose an image from the library
		_report.postData[kOpen311_Media] = info[UIImagePickerControllerReferenceURL];
		[self refreshMediaThumbnail];
	}
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)refreshMediaThumbnail
{
	[library assetForURL:_report.postData[kOpen311_Media]
			 resultBlock:^(ALAsset *asset) {
				 mediaThumbnail = [UIImage imageWithCGImage:[asset thumbnail]];
				 [self.tableView reloadData];
			 }
			failureBlock:^(NSError *error) {
				DLog(@"Failed to load chosen image from library");
			}];
}



#pragma mark send the report

- (IBAction)send:(id)sender {
	
	[self.tableView endEditing:YES];
	[SVProgressHUD showWithStatus:NSLocalizedString(kUI_HudSendingMessage, nil) maskType:SVProgressHUDMaskTypeClear];
	
	Open311 *open311 = [Open311 sharedInstance];
	
	NSNotificationCenter *notifications = [NSNotificationCenter defaultCenter];
	[notifications addObserver:self selector:@selector(postSucceeded) name:kNotification_PostSucceeded object:open311];
	[notifications addObserver:self selector:@selector(postFailed)    name:kNotification_PostFailed    object:open311];
	[_report checkAnonymousReporting];
	[open311 startPostingServiceRequest:_report];
}

- (void)postSucceeded
{
	[SVProgressHUD showSuccessWithStatus:NSLocalizedString(kUI_HudSuccessMessage, nil)];
	
	// Remove the report so they cannot post this report again,
	// without starting the process from scratch.
	_report = nil;
	
	// Go to Home screen
	[self performSegueWithIdentifier:kUnwindSegueFromReportToHome sender:self];
}

- (void)postFailed
{
	[SVProgressHUD dismiss];
}


@end
