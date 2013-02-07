//
//  StringController.m
//  GeoReporter
//
//  Created by Cliff Ingham on 2/6/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import "StringController.h"
#import "Strings.h"

@interface StringController ()

@end

@implementation StringController

- (void)viewDidLoad
{
    self.label    .text = self.attribute[kOpen311_Description];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.textField.text = self.currentValue;
    [self.textField becomeFirstResponder];
}

- (IBAction)done:(id)sender
{
    [self.delegate didProvideValue:self.textField.text];
}

@end
