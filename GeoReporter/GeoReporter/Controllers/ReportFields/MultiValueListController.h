//
//  MultiValueListController.h
//  GeoReporter
//
//  Created by Cliff Ingham on 2/6/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultiValueDelegate.h"

@interface MultiValueListController : UITableViewController
@property (strong, nonatomic) NSDictionary *attribute;
@property (strong, nonatomic) NSArray *currentValue;
@property (weak, nonatomic) IBOutlet UILabel *label;
- (IBAction)done:(id)sender;
@property id<MultiValueDelegate>delegate;
@end
