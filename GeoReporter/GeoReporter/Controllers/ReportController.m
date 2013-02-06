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

@interface ReportController ()

@end

@implementation ReportController {
    NSMutableArray *fields;
    // In the ServiceRequest, we are only storing the URL for the photo asset.
    // Retrieving the actual image data from the asset is an async call.
    // We need to know what the current |mediaUrl| is, that way, we can invalidate
    // the |mediaThumnail| when the |mediaUrl| changes
    ALAssetsLibrary *library;
    NSURL   *mediaUrl;
    UIImage *mediaThumbnail;
}
static NSString * const kReportCell = @"report_cell";
static NSString * const kFieldname  = @"fieldname";
static NSString * const kLabel      = @"label";
static NSString * const kType       = @"type";

static NSString * const kSegueToLocation = @"SegueToLocationChooser";

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
    _serviceRequest = [[ServiceRequest alloc] initWithService:_service];
    
    // First section: Photo and Location choosers
    fields = [[NSMutableArray alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES
        && [[[Preferences sharedInstance] getCurrentServer][kOpen311_SupportsMedia] boolValue]) {
        DLog(@"Adding media and address to display");
        [fields addObject:@[
            @{kFieldname:kOpen311_Media,   kLabel:NSLocalizedString(kUI_AddPhoto, nil), kType:kOpen311_Media },
            @{kFieldname:kOpen311_Address, kLabel:NSLocalizedString(kUI_Location, nil), kType:kOpen311_Address}
        ]];
        
        // Initialize the Asset Library object for saving/reading images
        library = [[ALAssetsLibrary alloc] init];
    }
    else {
        DLog(@"Adding only address to display");
        [fields addObject:@[
            @{kFieldname:kOpen311_Address, kLabel:NSLocalizedString(kUI_Location, nil), kType:kOpen311_Address}
        ]];
    }
    
    // Second section: Report Description
    DLog(@"Adding description to display");
    [fields addObject:@[
        @{kFieldname:kOpen311_Description, kLabel:NSLocalizedString(kUI_ReportDescription, nil), kType:kOpen311_Text}
    ]];
    
    // Third section: Attributes
    if (_service[kOpen311_Metadata]) {
        DLog(@"Adding attributes");
        NSMutableArray *attributes = [[NSMutableArray alloc] init];
        for (NSDictionary *attribute in _serviceRequest.serviceDefinition[kOpen311_Attributes]) {
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
                DLog(@"Adding %@", code);
                
                [attributes addObject:@{kFieldname:code, kLabel:attribute[kOpen311_Description], kType:type}];
            }
            else {
                // This is an information-only attribute.
                // Save it somewhere so we can display those differently
                DLog(@"Attribute is info-only");
            }
        }
        [fields addObject:attributes];
    }
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
    cell.textLabel.text = field[kLabel];
    
    if ([field[kFieldname] isEqualToString:kOpen311_Media]) {
        NSURL *url = _serviceRequest.postData[kOpen311_Media];
        if (url != nil) {
            // When the user-selected mediaUrl changes, we need to load a fresh thumbnail image
            // This is an async call, that could take some time.
            if (![mediaUrl isEqual:url]) {
                [library assetForURL:url
                    resultBlock:^(ALAsset *asset) {
                        // Once we finally get the image loaded, we need to tell the
                        // table to redraw itself, which should pick up the new |mediaThumbnail|
                        mediaThumbnail = [UIImage imageWithCGImage:[asset thumbnail]];
                        [self.tableView reloadData];
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
    else if ([field[kFieldname] isEqualToString:kOpen311_Address]) {
        NSString *address   = _serviceRequest.postData[kOpen311_AddressString];
        NSString *latitude  = _serviceRequest.postData[kOpen311_Latitude];
        NSString *longitude = _serviceRequest.postData[kOpen311_Longitude];
        if (address.length==0 && latitude.length!=0 && longitude.length!=0) {
            CLLocation *location = [[CLLocation alloc] initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
                if (error) {
                    DLog(@"%@", error);
                }
                DLog(@"Placemarks: %@", placemarks);
                _serviceRequest.postData[kOpen311_AddressString] = [placemarks[0] name];
                [self.tableView reloadData];
            }];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@", latitude, longitude];
        }
        else {
            cell.detailTextLabel.text = address;
        }
    }
    else {
        if ([field[kType] isEqualToString:kOpen311_MultiValueList]) {
            
        }
        else {
            cell.detailTextLabel.text = _serviceRequest.postData[field[kFieldname]];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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
    else if ([type isEqualToString:kOpen311_Address]) {
        [self performSegueWithIdentifier:kSegueToLocation sender:self];
    }
    else if ([type isEqualToString:kOpen311_SingleValueList]) {
        
    }
    else if ([type isEqualToString:kOpen311_MultiValueList]) {
        
    }
    else {
        
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kSegueToLocation]) {
        [segue.destinationViewController setDelegate:self];
    }
}

#pragma mark - Location choosing handlers
- (void)didChooseLocation:(CLLocationCoordinate2D)location
{
    [self.navigationController popViewControllerAnimated:YES];
    _serviceRequest.postData[kOpen311_Latitude]  = [NSString stringWithFormat:@"%f", location.latitude];
    _serviceRequest.postData[kOpen311_Longitude] = [NSString stringWithFormat:@"%f", location.longitude];
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
        DLog(@"Camera returned a picture");
        [library writeImageToSavedPhotosAlbum:[image CGImage]
                                     metadata:info[UIImagePickerControllerMediaMetadata]
                              completionBlock:^(NSURL *assetURL, NSError *error) {
                                  DLog(@"Setting POST media to: %@", assetURL);
                                  _serviceRequest.postData[kOpen311_Media] = assetURL;
                                  [self.tableView reloadData];
                              }];
    }
    else {
        // The user chose an image from the library
        DLog(@"User chose a picture from the library");
        _serviceRequest.postData[kOpen311_Media] = info[UIImagePickerControllerReferenceURL];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.tableView reloadData];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
