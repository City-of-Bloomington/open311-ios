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
}
static NSString * const kReportCell = @"report_cell";
static NSString * const kFieldname  = @"fieldname";
static NSString * const kLabel      = @"label";
static NSString * const kType       = @"type";

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
    if ([[[Preferences sharedInstance] getCurrentServer][kOpen311_SupportsMedia] boolValue]) {
        DLog(@"Adding media and address to display");
        [fields addObject:@[
            @{kFieldname:kOpen311_Media,         kLabel:NSLocalizedString(kUI_AddPhoto, nil), kType:kOpen311_Media },
            @{kFieldname:kOpen311_Address, kLabel:NSLocalizedString(kUI_Location, nil), kType:kOpen311_Address}
        ]];
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
        
    }
    else if ([field[kFieldname] isEqualToString:kOpen311_Address]) {
        NSString *address = _serviceRequest.postData[kOpen311_AddressString];
        cell.detailTextLabel.text = address;
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
@end
