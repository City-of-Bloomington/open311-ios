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
#import "SwitchCell.h"

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

static NSString * const kReportCell = @"report_cell";
static NSString * const kReportTextCell = @"report_text_cell";
static NSString * const kReportLocationCell = @"report_location_cell";
static NSString * const kReportSingleValueCell = @"report_sinlge_value_cell";
static NSString * const kReportMultiValueCell = @"report_multi_value_cell";
static NSString * const kReportStringCell = @"report_string_cell";
static NSString * const kReportSwitchCell = @"report_switch_cell";
static NSString * const kFieldname  = @"fieldname";
static NSString * const kLabel      = @"label";
static NSString * const kType       = @"type";


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
    
    if ([type isEqualToString:kOpen311_SingleValueList])
        return 60;
    
    if ([type isEqualToString:kOpen311_Address] && [indexPath isEqual: [tableView indexPathForSelectedRow]])
        return 150;
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{   
    NSDictionary *field = fields[indexPath.section][indexPath.row];

    NSString *type = field[kType];
#warning - didn't cover the case for image cell
    
    
    if ([type isEqualToString:kOpen311_Text]) {
       // cell = (TextCell *)[tableView dequeueReusableCellWithIdentifier:kReportCell forIndexPath:indexPath];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReportTextCell forIndexPath:indexPath];
        TextCell* textCell = (TextCell*) cell;
        textCell.header.text = field[kLabel];
        return textCell;
    }
    if ([type isEqualToString:kOpen311_Address]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReportLocationCell forIndexPath:indexPath];
        LocationCell* locationCell = (LocationCell*) cell;
        locationCell.header.text = field[kLabel];
        return locationCell;
    }
    if ([type isEqualToString:kOpen311_MultiValueList]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReportMultiValueCell forIndexPath:indexPath];
        MultiValueListCell* multiValueListCell = (MultiValueListCell*) cell;
        multiValueListCell.header.text = field[kLabel];
        return multiValueListCell;
    }
    if ([type isEqualToString:kOpen311_SingleValueList]) {
        //TODO: if only have two options, yes and n, show Switch
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReportSingleValueCell forIndexPath:indexPath];
        SingleValueListCell* singleValueListCell = (SingleValueListCell*) cell;
        NSDictionary *attribute = _report.serviceDefinition[kOpen311_Attributes][currentIndexPath.row];
        singleValueListCell.delegate = self;
        singleValueListCell.fieldname = field[kFieldname];
        singleValueListCell.attribute = attribute;
        singleValueListCell.header.text = field[kLabel];
        if (_report.postData[field[kFieldname]] != nil) {
            singleValueListCell.selectedOption = _report.postData[field[kFieldname]];
        }
        return singleValueListCell;
    }
    if ([type isEqualToString:kOpen311_String]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReportStringCell forIndexPath:indexPath];
        StringCell* stringCell = (StringCell*) cell;
        stringCell.header.text = field[kLabel];
        return stringCell;
    }
    
    
    if ([type isEqualToString:kOpen311_Media]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReportStringCell forIndexPath:indexPath];
        StringCell* stringCell = (StringCell*) cell;
#warning - media image 
        stringCell.header.text = @"image - hardcoded";
        return stringCell;
        /*
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
                [cell.imageView setImage:mediaThumbnail];
            }
        }*/
    }
         
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView beginUpdates];
    [tableView endUpdates];
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - TextEntryDelegate
- (void)didProvideValue:(NSString *)value fromField:(NSString *)field
{
//    NSString *fieldname = fields[currentIndexPath.section][currentIndexPath.row][kFieldname];
    _report.postData[field] = value;
    [self.tableView reloadData];
}

@end
