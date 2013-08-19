//
//  NewReportController.m
//  GeoReporter
//
//  Created by Marius Constantinescu on 7/20/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

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
#import <QuartzCore/QuartzCore.h>





@interface NewReportController ()

@end

@implementation NewReportController
NSMutableArray *fields;
NSIndexPath *currentIndexPath;
NSString *currentServerName;

ALAssetsLibrary *library;
NSURL   *mediaUrl;
UIImage *mediaThumbnail;

UIActivityIndicatorView *busyIcon;
NSString *header;


CLLocation *locationFromLocationController;

static NSString * const kSegueToLocation        = @"SegueToLocation";
static NSString * const kReportCell             = @"report_cell";
static NSString * const kReportTextCell         = @"report_text_cell";
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


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


// Creates a multi-dimensional array to represent the fields to display in
// the table view.
//
// You can access indivual cells like so:
// fields[section][row][fieldname]
//                     [label]
//                     [type]
//
// The actual stuff the user enters will be stored in the ServiceRequest
// This data structure is only for display
- (void)viewDidLoad
{
    [super viewDidLoad];
    locationFromLocationController = nil;
    currentServerName = [[Preferences sharedInstance] getCurrentServer][kOpen311_Name];
    
    self.navigationItem.title = _service[kOpen311_ServiceName];
    
    _report = [[Report alloc] initWithService:_service];
    
    // First section: Photo and Location choosers
    fields = [[NSMutableArray alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES
        && [[[Preferences sharedInstance] getCurrentServer][kOpen311_SupportsMedia] boolValue]) {
        [fields addObject:@[
         @{kFieldname:kOpen311_Media,   kLabel:NSLocalizedString(kUI_AddPhoto, nil), kType:kOpen311_Media },
         @{kFieldname:kOpen311_Address, kLabel:NSLocalizedString(kUI_Location, nil), kType:kOpen311_Address}
         ]];
        
        // Initialize the Asset Library object for saving/reading images
        library = [[ALAssetsLibrary alloc] init];
    }
    else {
        [fields addObject:@[
         @{kFieldname:kOpen311_Address, kLabel:NSLocalizedString(kUI_Location, nil), kType:kOpen311_Address}
         ]];
    }
    
    // Second section: Report Description
    [fields addObject:@[
     @{kFieldname:kOpen311_Description, kLabel:NSLocalizedString(kUI_ReportDescription, nil), kType:kOpen311_Text}
     ]];
    
    // Third section: Attributes
    // Attributes with variable=false will be appended to the section header
    header = _service[kOpen311_Description];
    if (_service[kOpen311_Metadata]) {
        NSMutableArray *attributes = [[NSMutableArray alloc] init];
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
                
                [attributes addObject:@{kFieldname:code, kLabel:attribute[kOpen311_Description], kType:type}];
            }
            else {
                // This is an information-only attribute.
                // Save it somewhere so we can display those differently
                header = [header stringByAppendingFormat:@"\n%@", attribute[kOpen311_Description]];
            }
        }
        [fields addObject:attributes];
    }
    
    //add empty footer so that empty rows will not be shown at the end of the table
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    //add tabel header:
    CGSize headerSize = [header sizeWithFont:[UIFont fontWithName:@"Heiti SC" size:13] constrainedToSize:CGSizeMake(280, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    
    self.headerViewLabel.backgroundColor = [UIColor clearColor];
    self.headerViewLabel.textColor = [UIColor colorWithRed:78/255.0f green:84/255.0f blue:102/255.0f alpha:1];
    self.headerViewLabel.text = header;
    self.headerView.frame = CGRectMake(20, 8, 280, headerSize.height + 5 + 8);
    
    self.tableView.tableHeaderView = self.headerView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [fields count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [fields[section] count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *field = fields[indexPath.section][indexPath.row];
    NSString *type = field[kType];
    //NSDictionary *attribute = _report.serviceDefinition[kOpen311_Attributes][currentIndexPath.row];
    NSDictionary *attribute = _report.serviceDefinition[kOpen311_Attributes][indexPath.row];
    
    if ([type isEqualToString:kOpen311_Text]) {
        NSString* text = fields[indexPath.section][indexPath.row][kLabel];
        CGSize headerSize = [text sizeWithFont:[UIFont fontWithName:@"Heiti SC" size:15] constrainedToSize:CGSizeMake(280, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        return TEXT_CELL_BOTTOM_SPACE + TEXT_CELL_TEXT_VIEW_HEIGHT + headerSize.height;
    }
    if ([type isEqualToString:kOpen311_SingleValueList]) {
        NSString* text = fields[indexPath.section][indexPath.row][kLabel];
        CGSize headerSize = [text sizeWithFont:[UIFont fontWithName:@"Heiti SC" size:15] constrainedToSize:CGSizeMake(280, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        return 2 + SINGLE_VALUE_INNER_CELL_BOTTOM_SPACE + headerSize.height + SINGLE_VALUE_INNER_CELL_HEIGHT * [attribute[kOpen311_Values] count];
    }
    if ([type isEqualToString:kOpen311_MultiValueList]){
        NSString* text = fields[indexPath.section][indexPath.row][kLabel];
        CGSize headerSize = [text sizeWithFont:[UIFont fontWithName:@"Heiti SC" size:15] constrainedToSize:CGSizeMake(280, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        return 2 + MULTI_VALUE_INNER_CELL_BOTTOM_SPACE + headerSize.height + MULTI_VALUE_INNER_CELL_HEIGHT * [attribute[kOpen311_Values] count];
    }
    if ([type isEqualToString:kOpen311_String]) {
        NSString* text = fields[indexPath.section][indexPath.row][kLabel];
        CGSize headerSize = [text sizeWithFont:[UIFont fontWithName:@"Heiti SC" size:15] constrainedToSize:CGSizeMake(280, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        return 2 + STRING_CELL_BOTTOM_SPACE + STRING_CELL_TEXT_FIELD_HEIGHT + headerSize.height;
    }
    
    if ([type isEqualToString:kOpen311_Address])
        return 110;
    
#warning - hardcoded value
    if ([type isEqualToString:kOpen311_Media])
        return 60;
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{   
    NSDictionary *field = fields[indexPath.section][indexPath.row];

    NSString *type = field[kType];
    
    
    if ([type isEqualToString:kOpen311_Text]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReportTextCell forIndexPath:indexPath];
        TextCell* textCell = (TextCell*) cell;
        textCell.header.text = field[kLabel];
        textCell.delegate = self;
        textCell.fieldname = field[kFieldname];
        // appearance customization
        textCell.text.layer.cornerRadius=8.0f;
        textCell.text.layer.masksToBounds=YES;
        textCell.text.layer.borderColor = [[UIColor orangeColor] CGColor];
        textCell.text.layer.borderWidth = 1.0f;
        // get text from the datasource
        if (_report.postData[field[kFieldname]] != nil) {
            textCell.text.text = _report.postData[field[kFieldname]];
        }
        return textCell;
    }
    if ([type isEqualToString:kOpen311_Address]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReportLocationCell forIndexPath:indexPath];
        LocationCell* locationCell = (LocationCell*) cell;
        locationCell.header.text = field[kLabel];
        if (_report.postData[kOpen311_Latitude] != nil && _report.postData[kOpen311_Longitude] != nil) {
            
            // Create your coordinate
            CLLocationCoordinate2D myCoordinate = {[_report.postData[kOpen311_Latitude] doubleValue], [_report.postData[kOpen311_Longitude] doubleValue]};
            //Create your annotation
            MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
            // Set your annotation to point at your coordinate
            point.coordinate = myCoordinate;
            //If you want to clear other pins/annotations this is how to do it
            for (id annotation in locationCell.mapView.annotations) {
                [locationCell.mapView removeAnnotation:annotation];
            }
            //Drop pin on map
            [locationCell.mapView addAnnotation:point];
            
            MKCoordinateRegion region;
            region.center.latitude  = myCoordinate.latitude;
            region.center.longitude = myCoordinate.longitude;
            MKCoordinateSpan span;
            span.latitudeDelta  = 0.007;
            span.longitudeDelta = 0.007;
            region.span = span;
            [locationCell.mapView setRegion:region animated:YES];
        }
        return locationCell;
    }
    if ([type isEqualToString:kOpen311_MultiValueList]) {
        //TODO: make it multivalue (right now it's radio button style)
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReportMultiValueCell forIndexPath:indexPath];
        MultiValueListCell* multiValueListCell = (MultiValueListCell*) cell;
        NSDictionary *attribute = _report.serviceDefinition[kOpen311_Attributes][indexPath.row];
        multiValueListCell.delegate = self;
        multiValueListCell.fieldname = field[kFieldname];
        multiValueListCell.attribute = attribute;
        multiValueListCell.header.text = field[kLabel];
        if (_report.postData[field[kFieldname]] != nil)
            multiValueListCell.selectedOptions = _report.postData[field[kFieldname]];
        else
            multiValueListCell.selectedOptions = nil;
        return multiValueListCell;
    }
    if ([type isEqualToString:kOpen311_SingleValueList]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReportSingleValueCell forIndexPath:indexPath];
        SingleValueListCell* singleValueListCell = (SingleValueListCell*) cell;
        NSDictionary *attribute = _report.serviceDefinition[kOpen311_Attributes][indexPath.row];
        singleValueListCell.delegate = self;
        singleValueListCell.fieldname = field[kFieldname];
        singleValueListCell.attribute = attribute;
        singleValueListCell.header.text = field[kLabel];
        if (_report.postData[field[kFieldname]] != nil) 
            singleValueListCell.selectedOption = _report.postData[field[kFieldname]];
        else
            singleValueListCell.selectedOption = nil;
        return singleValueListCell;
    }
    if ([type isEqualToString:kOpen311_String]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReportStringCell forIndexPath:indexPath];
        StringCell* stringCell = (StringCell*) cell;
        stringCell.header.text = field[kLabel];
        stringCell.delegate = self;
        stringCell.fieldname = field[kFieldname];
        // appearance customization
        stringCell.textField.layer.cornerRadius=8.0f;
        stringCell.textField.layer.masksToBounds=YES;
        stringCell.textField.layer.borderColor = [[UIColor orangeColor] CGColor];
        stringCell.textField.layer.borderWidth = 1.0f;
        // get text from the datasource
        if (_report.postData[field[kFieldname]] != nil) {
            stringCell.textField.text = _report.postData[field[kFieldname]];
        }
        return stringCell;
    }
    
    
    if ([type isEqualToString:kOpen311_Media]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReportMediaCell forIndexPath:indexPath];
        MediaCell* mediaCell = (MediaCell*) cell;
#warning - media image 
        mediaCell.header.text = @"Add image";        
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
                mediaCell.header.text = @"Change image";
                mediaCell.closeImage.hidden = NO;
               
            }
        }
        
        return mediaCell;
    }
         
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *type = fields[indexPath.section][indexPath.row][kType];

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


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kSegueToLocation]) {
        [segue.destinationViewController setDelegate:self];
        LocationController *destinationController = (LocationController*)segue.destinationViewController;
        destinationController.selectedLocation = locationFromLocationController;
    }
}

#pragma mark - TextEntryDelegate
- (void)didProvideValue:(NSString *)value fromField:(NSString *)field
{
    if (value != nil)
        _report.postData[field] = value;
    else
        [_report.postData removeObjectForKey:field];
    [self.tableView reloadData];
}

#pragma mark - MultiValueDelegate
- (void)didProvideValues:(NSArray *)values fromField:(NSString*)field
{
    if (values != nil)
        _report.postData[field] = values;
    else
        [_report.postData removeObjectForKey:field];
    [self.tableView reloadData];
}

#pragma mark - Location delegate
- (void)didChooseLocation:(CLLocationCoordinate2D)location
{
    locationFromLocationController = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];
    
    _report.postData[kOpen311_Latitude]  = [NSString stringWithFormat:@"%f", location.latitude];
    _report.postData[kOpen311_Longitude] = [NSString stringWithFormat:@"%f", location.longitude];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude]
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       NSString *address = [placemarks[0] name];
                       _report.postData[kOpen311_AddressString] = address ? address : @"";
                       [self.tableView reloadData];
                   }];
    
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
    busyIcon = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    busyIcon.center = self.view.center;
    [busyIcon setFrame:self.view.frame];
    [busyIcon setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5]];
    [busyIcon startAnimating];
    [self.view addSubview:busyIcon];
    
    
    Open311 *open311 = [Open311 sharedInstance];
    
    NSNotificationCenter *notifications = [NSNotificationCenter defaultCenter];
    [notifications addObserver:self selector:@selector(postSucceeded) name:kNotification_PostSucceeded object:open311];
    [notifications addObserver:self selector:@selector(postFailed)    name:kNotification_PostFailed    object:open311];
    
    [open311 startPostingServiceRequest:_report];
}

- (void)postSucceeded
{
    [busyIcon stopAnimating];
    [busyIcon removeFromSuperview];
    
    // Remove the service so they cannot post this report again,
    // without starting the process from scratch.
    _service = nil;
    
    // Go to Home screen
    [self performSegueWithIdentifier:kUnwindSegueFromReportToHome sender:self];
}

- (void)postFailed
{
    [busyIcon stopAnimating];
    [busyIcon removeFromSuperview];
}

@end
