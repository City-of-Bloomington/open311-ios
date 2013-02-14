//
//  ViewRequestController.m
//  GeoReporter
//
//  Created by Cliff Ingham on 2/12/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import "ViewRequestController.h"

@interface ViewRequestController ()

@end

@implementation ViewRequestController
static NSString * const kCellIdentifier = @"request_cell";

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (section == 0) ? 1 : 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    
    return cell;
}

@end
