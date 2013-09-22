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

#import "ViewRequestController.h"
#import "Strings.h"
#import "Preferences.h"
#import "Media.h"
#import "FullImageController.h"
#import "ViewReportLocationCell.h"

@interface ViewRequestController ()
@property NSDateFormatter *dateFormatterDisplay;
@property NSDateFormatter *dateFormatterISO;
@property NSURL *mediaUrl;
@property UIImage *media;
@property UIImage *original;
@property UITapGestureRecognizer * gestureRecognizer;
@property BOOL loadedOnce;
@end

@implementation ViewRequestController

static NSString * const kCellIdentifier  = @"request_cell";
static NSString * const kMediaCell       = @"media_cell";
static NSString * const kLocationCell       = @"location_cell";
static NSInteger  const kImageViewTag    = 100;
static NSInteger  const kLabelTag    = 114;
static CGFloat    const kMediaCellHeight = 122;
static NSString * const kSegueToFullImage = @"segueToFullImage";



- (void)viewDidLoad
{
	[super viewDidLoad];
	
	//make view controller start below navigation bar; this works in iOS 7
	if ([self respondsToSelector:@selector(edgesForExtendedLayout)]){
		self.edgesForExtendedLayout = UIRectEdgeNone;
	}
	
	self.navigationItem.title = self.report.service[kOpen311_ServiceName];
	
	_loadedOnce = NO;
	
	
	_dateFormatterDisplay = [[NSDateFormatter alloc] init];
	[_dateFormatterDisplay setDateStyle:NSDateFormatterMediumStyle];
	[_dateFormatterDisplay setTimeStyle:NSDateFormatterShortStyle];
	
	_dateFormatterISO = [[NSDateFormatter alloc] init];
	[_dateFormatterISO setDateFormat:kDate_ISO8601];
	
	[self startRefreshingServiceRequest];
	
	_mediaUrl = _report.postData[kOpen311_Media];
	if (_mediaUrl) {
		ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
		[library assetForURL:_mediaUrl
				 resultBlock:^(ALAsset *asset) {
					 ALAssetRepresentation *rep = [asset defaultRepresentation];
					 _original = [UIImage imageWithCGImage:[rep fullScreenImage]];
					 _media = [Media resizeImage:_original toBoundingBox:100];
				 }
				failureBlock:^(NSError *error) {
					DLog(@"Failed to load media from library");
				}];
	}
}

#pragma mark Service Request Refreshing
- (void)startRefreshingServiceRequest
{
	NSDictionary *sr = _report.serviceRequest;
	NSString *serviceRequestId = sr[kOpen311_ServiceRequestId];
	if (serviceRequestId) {
		[_report startLoadingServiceRequest:serviceRequestId delegate:self];
	}
	else {
		NSString *token = sr[kOpen311_Token];
		[_report startLoadingServiceRequestIdFromToken:token delegate:self];
	}
}

- (void)didReceiveServiceRequest:(NSDictionary *)serviceRequest
{
	for (NSString *key in [serviceRequest allKeys]) {
		_report.serviceRequest[key] = serviceRequest[key];
	}
	[[Preferences sharedInstance] saveReport:_report forIndex:_reportIndex];
	[self.tableView reloadData];
}

-(NSString *)getReportDescription
{
	NSDictionary *sr = _report.serviceRequest;
	NSDictionary *post = _report.postData;
	
	NSString *titleForHeader = nil;
	
	if ( sr ) {
		id srDescription = sr[kOpen311_Description];
		if ( srDescription != [NSNull null] ) {
			titleForHeader = srDescription;
		}
	}
	
	if ( titleForHeader == nil ) {
		id postDescription = post[kOpen311_Description];
		if ( postDescription != [NSNull null] ) {
			titleForHeader = postDescription;
		}
	}
	
	//if ( titleForHeader )
	return titleForHeader;
}

- (void)didReceiveServiceRequestId:(NSString *)serviceRequestId
{
	_report.serviceRequest[kOpen311_ServiceRequestId] = serviceRequestId;
	[[Preferences sharedInstance] saveReport:_report forIndex:_reportIndex];
	[_report startLoadingServiceRequest:serviceRequestId delegate:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	int numberOfRows = 1;    //we always have the "Description" cell
	if (section == 0) {
		return 3;
	}
	else {
		if (_mediaUrl) {
			numberOfRows += 1;
		}
		if (_report.postData[kOpen311_Latitude] != nil && _report.postData[kOpen311_Longitude] != nil) {
			numberOfRows += 1;
		}
		return numberOfRows;
	}
	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell;
	
	NSDictionary *sr   = _report.serviceRequest;
	NSDictionary *post = _report.postData;
	if (indexPath.section == 0) {
		//date, status, responsible
		cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
		switch (indexPath.row) {
			case 0:
				//date
				cell.textLabel.text = NSLocalizedString(kUI_ReportDate, nil);
				cell.detailTextLabel.text = [_dateFormatterDisplay stringFromDate:[_dateFormatterISO dateFromString:sr[kOpen311_RequestedDatetime]]];
				break;
				
			case 1:
				//status
				cell.textLabel.text = NSLocalizedString(kUI_ReportStatus, nil);
				cell.detailTextLabel.text = (sr && sr[kOpen311_Status]!=[NSNull null]) ? sr[kOpen311_Status] : kUI_Pending;
				break;
				
			case 2:
				//responsible
				cell.textLabel.text = NSLocalizedString(kOpen311_AgencyResponsible, nil);
				cell.detailTextLabel.text = (sr && sr[kOpen311_AgencyResponsible]!=[NSNull null]) ? sr[kOpen311_AgencyResponsible] : @"";
				break;
				
			default:
				break;
		}
	}
	else {
		if (indexPath.row == 0) {
			// description cell
			cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
			
			cell.textLabel.text = kUI_DescriptionOfProblem;
			[cell.detailTextLabel setLineBreakMode:NSLineBreakByWordWrapping];
			[cell.detailTextLabel setNumberOfLines:0];
			cell.detailTextLabel.text = [self getReportDescription];
		}
		else {
			if (indexPath.row == 1 && _report.postData[kOpen311_Latitude] != nil && _report.postData[kOpen311_Longitude] != nil) {
				ViewReportLocationCell *locationCell = [tableView dequeueReusableCellWithIdentifier:kLocationCell forIndexPath:indexPath];
				locationCell.titleLabel.text = NSLocalizedString(kUI_Location, nil);
				
				NSString *text = nil;
				if (sr          &&   sr[kOpen311_Address]       != [NSNull null]) { text =   sr[kOpen311_Address];       }
				if (text == nil && post[kOpen311_AddressString] != [NSNull null]) { text = post[kOpen311_AddressString]; }
				if (text != nil) { locationCell.description.text = text; }
				
				MKCoordinateRegion region;
				region.center.latitude  = [(NSNumber*)_report.postData[kOpen311_Latitude] doubleValue];
				region.center.longitude = [(NSNumber*)_report.postData[kOpen311_Longitude] doubleValue];
				MKCoordinateSpan span;
				span.latitudeDelta  = 0.0025;
				span.longitudeDelta = 0.0025;
				region.span = span;
				[locationCell.mapView setRegion:region animated:YES];
				
				MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
				// Set your annotation to point at your coordinate
				point.coordinate = region.center;
				//Drop pin on map
				[locationCell.mapView addAnnotation:point];
				
				return locationCell;
			}
			else {
				//media cell
				cell = [tableView dequeueReusableCellWithIdentifier:kMediaCell forIndexPath:indexPath];
				UIImageView *imageView = (UIImageView *)[cell viewWithTag:kImageViewTag];
				[imageView setImage:_media];
				imageView.userInteractionEnabled = YES;
				
				if (_loadedOnce == NO) {
					_gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openFullScreenImage:)];
					[cell addGestureRecognizer:_gestureRecognizer];
					_loadedOnce = YES;
				}
			}
		}
	}
	
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (_mediaUrl && indexPath.section==1 && indexPath.row==1) {
		return MEDIA_CELL_HEIGHT;
	}
	if ((_report.postData[kOpen311_Latitude] != nil && _report.postData[kOpen311_Longitude] != nil && indexPath.section==1 && indexPath.row==2) ||
		(!_mediaUrl && _report.postData[kOpen311_Latitude] != nil && _report.postData[kOpen311_Longitude] != nil && indexPath.section==1 && indexPath.row==1)) {
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			// The device is an iPad running iOS 3.2 or later.
			return LOCATION_CELL_HEIGHT_IPAD;
		}
		return LOCATION_CELL_HEIGHT;
	}
	
#define FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 290.0f
#define CELL_CONTENT_MARGIN 10.0f
	
	if  ((indexPath.section == 1 && indexPath.row == 1 && !_mediaUrl) ||
		 (indexPath.section == 1 && indexPath.row == 2 && _mediaUrl)) {
		CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH, 20000.0f);
		
		CGSize size = [[self getReportDescription] sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
		
		return size.height + 30.f;
	}
	return UITableViewAutomaticDimension;
}

#pragma mark - UITapGestureRecognizerSelector

- (void) openFullScreenImage:(UITapGestureRecognizer *) sender
{
	[self performSegueWithIdentifier:kSegueToFullImage sender:self];
}

# pragma mark Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	FullImageController *controller = [segue destinationViewController];
	
	[controller setImage:_original];
}

@end
