//
//  MultiValueListController.m
//  GeoReporter
//
//  Created by Cliff Ingham on 2/6/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import "MultiValueListController.h"
#import "Strings.h"

@interface MultiValueListController ()

@end

@implementation MultiValueListController

- (void)viewDidLoad
{
    self.label.text = self.attribute[kOpen311_Description];
}

@end
