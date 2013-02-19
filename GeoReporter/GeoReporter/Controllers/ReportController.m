//
//  ReportController.m
//  GeoReporter
//
//  Created by Cliff Ingham on 1/25/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import "ReportController.h"
#import "Strings.h"
#import "Preferences.h"
#import "Open311.h"

#import "StringController.h"
#import "TextController.h"
#import "SingleValueListController.h"
#import "MultiValueListController.h"

@interface ReportController ()

@end

@implementation ReportController {
    NSMutableArray *fields;
    NSIndexPath *currentIndexPath;
    
    // In the ServiceRequest, we are only storing the URL for the photo asset.
    // Retrieving the actual image data from the asset is an async call.
    // We need to know what the current |mediaUrl| is, that way, we can invalidate
    // the |mediaThumnail| when the |mediaUrl| changes
    ALAssetsLibrary *library;
    NSURL   *mediaUrl;
    UIImage *mediaThumbnail;
    
    UIActivityIndicatorView *busyIcon;
}
static NSString * const kReportCell = @"report_cell";
static NSString * const kFieldname  = @"fieldname";
static NSString * const kLabel      = @"label";
static NSString * const kType       = @"type";

static NSString * const kSegueToLocation        = @"SegueToLocation";
static NSString * const kSegueToText            = @"SegueToText";
static NSString * const kSegueToString          = @"SegueToString";
static NSString * const kSegueToSingleValueList = @"SegueToSingleValueList";
static NSString * const kSegueToMultiValueList  = @"SegueToMultiValueList";


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
    if (_service[kOpen311_Metadata]) {
        NSMutableArray *attributes = [[NSMutableArray alloc] init];
        for (NSDictionary *attribute in _report.serviceDefinition[kOpen311_Attributes]) {
            // According to the spec, attribute paramters need to be named:
            // attribute[code]
            //
            // Also, if the attribute is a MultiValueList, it needs to be named:
            // attribute[code][]
            //
            // The server will interpret the parameter as an array of values.
            if ([attribute[kOpen311_Variable] boolValue]) {
                NSString *code = [NSString stringWithFormat:@"%@[%@]", kOpen311_Attribute, attribute[kOpen311_Code]];
                NSString *type = attribute[kOpen311_Datatype];
                if ([type isEqualToString:kOpen311_MultiValueList]) {
                    code = [code stringByAppendingString:@"[]"];
                }
                
                [attributes addObject:@{kFieldname:code, kLabel:attribute[kOpen311_Description], kType:type}];
            }
            else {
                // This is an information-only attribute.
                // Save it somewhere so we can display those differently
            }
        }
        [fields addObject:attributes];
    }
}

/**
 * POST the service request to the endpoint
 */
- (IBAction)done:(id)sender
{
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
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)postFailed
{
    [busyIcon stopAnimating];
    [busyIcon removeFromSuperview];
}

/**
 * Refresh the view after a response from user data entry
 */
- (void)popViewAndReloadTable
{
    [self.navigationController popViewControllerAnimated:YES];
    [self.tableView reloadData];
    currentIndexPath = nil;
}

#pragma mark - Table view handlers
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [fields count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [fields[section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return _service[kOpen311_Description];
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReportCell forIndexPath:indexPath];
    
    NSDictionary *field = fields[indexPath.section][indexPath.row];
    NSString *fieldname = field[kFieldname];
    cell.textLabel.text = field[kLabel];
    
    // Media cell
    if ([fieldname isEqualToString:kOpen311_Media]) {
        NSURL *url = _report.postData[kOpen311_Media];
        if (url != nil) {
            // When the user-selected mediaUrl changes, we need to load a fresh thumbnail image
            // This is an async call, that could take some time.
            if (![mediaUrl isEqual:url]) {
                [library assetForURL:url
                         resultBlock:^(ALAsset *asset) {
                             DLog(@"Loaded image from library");
                            // Once we finally get the image loaded, we need to tell the
                            // table to redraw itself, which should pick up the new |mediaThumbnail|
                            mediaThumbnail = [UIImage imageWithCGImage:[asset thumbnail]];
                        }
                        failureBlock:^(NSError *error) {
                            DLog(@"Failed to load thumbnail from library");
                        }];
            }
            if (mediaThumbnail != nil) {
                [cell.imageView setImage:mediaThumbnail];
            }
        }
    }
    // Location cell
    else if ([fieldname isEqualToString:kOpen311_Address]) {
        NSString *address   = _report.postData[kOpen311_AddressString];
        NSString *latitude  = _report.postData[kOpen311_Latitude];
        NSString *longitude = _report.postData[kOpen311_Longitude];
        if (address.length==0 && latitude.length!=0 && longitude.length!=0) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@", latitude, longitude];
        }
        else {
            cell.detailTextLabel.text = address;
        }
    }
    // Attribute cells
    else {
        NSString *datatype  = field[kType];
        
        // SingleValueList and MultiValueList values are a set of key:name pairs
        // The |postData| will contain the key - but we want to display
        // the name associated with each key
        if ([datatype isEqualToString:kOpen311_SingleValueList]) {
            NSString *userInput = _report.postData[fieldname];
            cell.detailTextLabel.text = [_report attributeValueForKey:userInput atIndex:indexPath.row];
        }
        else if ([datatype isEqualToString:kOpen311_MultiValueList]) {
            NSString *display = @"";
            NSArray *userInput = _report.postData[fieldname];
            int count = [userInput count];
            for (int i=0; i<count; i++) {
                NSString *name = [_report attributeValueForKey:userInput[i] atIndex:indexPath.row];
                display = [display stringByAppendingFormat:@"%@,", name];
            }
            cell.detailTextLabel.text = display;
        }
        else {
            NSString *userInput = _report.postData[fieldname];
            cell.detailTextLabel.text = userInput;
        }
    }
    
    return cell;
}

// We do the data entry for each field in a seperate view.
// This is because:
// 1) The questions being asked can be very long.
// and
// 2) The form controls displayed can take up a lot of room.
// It just makes sense to devote a full screen to each field
//

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
    else if ([type isEqualToString:kOpen311_Address])         { [self performSegueWithIdentifier:kSegueToLocation        sender:self]; }
    else if ([type isEqualToString:kOpen311_SingleValueList]) { [self performSegueWithIdentifier:kSegueToSingleValueList sender:self]; }
    else if ([type isEqualToString:kOpen311_MultiValueList])  { [self performSegueWithIdentifier:kSegueToMultiValueList  sender:self]; }
    else if ([type isEqualToString:kOpen311_Text])            { [self performSegueWithIdentifier:kSegueToText            sender:self]; }
    else {
        [self performSegueWithIdentifier:kSegueToString sender:self];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Because we're pushing a new view and responding to delegate
    // calls later on, we need to remember what indexPath we were working on
    // We'll refer to this later, in the delegate response methods
    currentIndexPath = [self.tableView indexPathForSelectedRow];
    
    [segue.destinationViewController setDelegate:self];
    
    // If this is data entry for an attribute, send the attribute definition
    if (currentIndexPath.section == 2) {
         NSDictionary *attribute = _report.serviceDefinition[kOpen311_Attributes][currentIndexPath.row];
        [segue.destinationViewController setAttribute:attribute];
        
        // The fieldname is different from the attribute code.
        // Fieldnames for attributes are in the form of "attribute[code]"
        // It is fieldname that we use as the key for the value in |postData|.
        // |postData| contains the raw key:value pairs we will be sending to the
        // Open311 endpoint
        NSString *fieldname = fields[currentIndexPath.section][currentIndexPath.row][kFieldname];
        [segue.destinationViewController setCurrentValue:_report.postData[fieldname]];
    }
    // The only other common field is "description"
    // We're going to have it use the same data entry view that any other
    // text attribute would use
    else {
        NSString *fieldname = fields[currentIndexPath.section][currentIndexPath.row][kFieldname];
        if ([fieldname isEqualToString:kOpen311_Description]) {
            // Create an attribute definition so we can use the same TextController
            // that all the other attribute definitions use
            NSDictionary *attribute = @{
                kOpen311_Code       :kOpen311_Description,
                kOpen311_Datatype   :kOpen311_Text,
                kOpen311_Description:NSLocalizedString(kUI_ReportDescription, nil)
            };
            [segue.destinationViewController setAttribute:attribute];
            [segue.destinationViewController setCurrentValue:_report.postData[kOpen311_Description]];
        }
    }
}


#pragma mark - Attribute result delegate handlers
// The controllers for String, Text, and SingleValueList will
// call this delegate method when the user clicks "Done"
- (void)didProvideValue:(NSString *)value
{
    NSString *fieldname = fields[currentIndexPath.section][currentIndexPath.row][kFieldname];
    _report.postData[fieldname] = value;
    
    [self popViewAndReloadTable];
}

- (void)didProvideValues:(NSArray *)values
{
    NSString *fieldname = fields[currentIndexPath.section][currentIndexPath.row][kFieldname];
    _report.postData[fieldname] = values;
    
    [self popViewAndReloadTable];
}

#pragma mark - Location choosing handlers
- (void)didChooseLocation:(CLLocationCoordinate2D)location
{
    _report.postData[kOpen311_Latitude]  = [NSString stringWithFormat:@"%f", location.latitude];
    _report.postData[kOpen311_Longitude] = [NSString stringWithFormat:@"%f", location.longitude];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude]
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       DLog(@"Got a geocoder response");
                       NSString *address = [placemarks[0] name];
                       DLog(@"Geocoder returned %@", address);
                       _report.postData[kOpen311_AddressString] = address ? address : @"";
                       [self.tableView reloadData];
                   }];
    
    [self popViewAndReloadTable];
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
        DLog(@"Camera returned a picture");
        [library writeImageToSavedPhotosAlbum:[image CGImage]
                                     metadata:info[UIImagePickerControllerMediaMetadata]
                              completionBlock:^(NSURL *assetURL, NSError *error) {
                                  DLog(@"Setting POST media to: %@", assetURL);
                                  _report.postData[kOpen311_Media] = assetURL;
                                  [self refreshMediaThumbnail];
                              }];
    }
    else {
        // The user chose an image from the library
        DLog(@"User chose a picture from the library");
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

@end
