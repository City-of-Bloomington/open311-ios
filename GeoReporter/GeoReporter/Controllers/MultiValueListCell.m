//
//  MultiValueListCell.m
//  GeoReporter
//
//  Created by Marius Constantinescu on 7/22/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import "MultiValueListCell.h"
#import "Strings.h"

@implementation MultiValueListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark table view stuff

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return MULTI_VALUE_INNER_CELL_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.attribute[kOpen311_Values] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning hardcoded
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
#warning hardoced string inner cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"inner_cell" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:@"inner_cell"];
    }
    
    cell.textLabel.text = self.attribute[kOpen311_Values][indexPath.row][kOpen311_Name];
    NSObject *key = self.attribute[kOpen311_Values][indexPath.row][kOpen311_Key];
    if ([key isKindOfClass:[NSNumber class]]) {
        key = [(NSNumber *)key stringValue];
    }
    if ([self.selectedOptions containsObject:key]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject *key = self.attribute[kOpen311_Values][indexPath.row][kOpen311_Key];
    if ([key isKindOfClass:[NSNumber class]]) {
        key = [(NSNumber *)key stringValue];
    }
    
    NSMutableArray* selected = [self.selectedOptions mutableCopy];
    if (selected != nil) {
        if ([selected containsObject:key]) {
            [selected removeObject:key];
        }
        else {
            [selected addObject:key];
        }
    }
    else {
        selected = [[NSMutableArray alloc] init];
        [selected addObject:key];
    }
    
    [self.delegate didProvideValues:selected fromField:self.fieldname];
//    if ([key isEqual:self.selectedOption]) {
//        [self.delegate didProvideValues:nil fromField:self.fieldname] ;
//    }
//    else {
//        [self.delegate didProvideValues:(NSArray *)key fromField:self.fieldname] ;
//    }
    
}

- (void)setAttribute:(NSDictionary *)attribute
{
    _attribute = attribute;
    [self.tableViewInsideCell reloadData];
}

- (void)setSelectedOptions:(NSArray *)selectedOptions
{
    _selectedOptions = selectedOptions;
    [self.tableViewInsideCell reloadData];
}

@end

