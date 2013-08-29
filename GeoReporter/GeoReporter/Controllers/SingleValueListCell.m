//
//  SingleValueListCell.m
//  GeoReporter
//
//  Created by Marius Constantinescu on 7/22/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import "SingleValueListCell.h"
#import "Strings.h"

@implementation SingleValueListCell

static NSString * const kInnerCellIdentifier = @"inner_cell";

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
    return SINGLE_VALUE_INNER_CELL_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.attribute[kOpen311_Values] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kInnerCellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                       reuseIdentifier:kInnerCellIdentifier];
    }
    
    cell.textLabel.text = self.attribute[kOpen311_Values][indexPath.row][kOpen311_Name];
    NSObject *key = self.attribute[kOpen311_Values][indexPath.row][kOpen311_Key];
    if ([key isKindOfClass:[NSNumber class]]) {
        key = [(NSNumber *)key stringValue];
    }
    if ([key isEqual:self.selectedOption]) {
        cell.imageView.image = [UIImage imageNamed:@"radio_selected"];
    }
    else {
        cell.imageView.image = [UIImage imageNamed:@"radio_unselected"];
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
    if ([key isEqual:self.selectedOption]) {
        [self.delegate didProvideValue:nil fromField:self.fieldname] ;
    }
    else {
        [self.delegate didProvideValue:(NSString *)key fromField:self.fieldname] ;
    }
    
}

- (void)setAttribute:(NSDictionary *)attribute
{
    _attribute = attribute;
    [self.tableViewInsideCell reloadData];
}

- (void)setSelectedOption:(NSString *)selectedOption
{
    _selectedOption = selectedOption;
    [self.tableViewInsideCell reloadData];
}

@end
