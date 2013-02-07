//
//  TextController.m
//  GeoReporter
//
//  Created by Cliff Ingham on 2/6/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import "TextController.h"
#import "Strings.h"

@interface TextController ()

@end

@implementation TextController

- (void)viewDidLoad
{
    self.label   .text = self.attribute[kOpen311_Description];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.textView.text = self.currentValue;
    [self.textView becomeFirstResponder];
}

- (IBAction)done:(id)sender
{
    [self.delegate didProvideValue:self.textView.text];
}
@end
