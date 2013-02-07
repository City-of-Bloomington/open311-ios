//
//  MultiValueListController.h
//  GeoReporter
//
//  Created by Cliff Ingham on 2/6/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MultiValueListController : UITableViewController
@property (strong, nonatomic) NSDictionary *attribute;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end
