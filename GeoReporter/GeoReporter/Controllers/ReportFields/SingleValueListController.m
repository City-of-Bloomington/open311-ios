//
//  SingleValueListController.m
//  GeoReporter
//
//  Created by Cliff Ingham on 2/6/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import "SingleValueListController.h"
#import "Strings.h"

@interface SingleValueListController ()

@end

@implementation SingleValueListController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.label.text = self.attribute[kOpen311_Description];
}

// Pre-select the |currentValue|
//
// Because of AutoLayout, we cannot change the picker's selection
// until after it has appeared.  Doing this in |viewWillAppear|
// will not work.
- (void)viewDidAppear:(BOOL)animated
{
    if ([self.currentValue length] > 0) {
        NSArray *values = self.attribute[kOpen311_Values];
        int count = [values count];
        for (int i=0; i<count; i++) {
            // Some servers use non-string keys.
            // We need to convert them to strings before comparing them.
            // If they were unique to begin with, they should still be unique
            // after string conversion.
            NSObject *valueKey = values[i][kOpen311_Key];
            if ([valueKey isKindOfClass:[NSNumber class]]) {
                valueKey = [(NSNumber *)valueKey stringValue];
            }
            if ([(NSString *)valueKey isEqualToString:self.currentValue]) {
                [self.picker selectRow:(NSInteger)i inComponent:0 animated:YES];
            }
        }
    }
}

- (IBAction)done:(id)sender
{
    // Some servers use non-string keys.
    // We need to convert them to strings before saving them.
    // If they were unique to begin with, they should still be unique
    // after string conversion.
    NSObject *key = self.attribute[kOpen311_Values][[self.picker selectedRowInComponent:0]][kOpen311_Key];
    if ([key isKindOfClass:[NSNumber class]]) {
        key = [(NSNumber *)key stringValue];
    }
    [self.delegate didProvideValue:(NSString *)key];
}

#pragma mark - Picker handlers
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.attribute[kOpen311_Values] count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.attribute[kOpen311_Values][row][kOpen311_Name];
}

@end
