//
//  MultiValueListCell.h
//  GeoReporter
//
//  Created by Marius Constantinescu on 7/22/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultiValueDelegate.h"

#define MULTI_VALUE_INNER_CELL_HEIGHT 28
#define MULTI_VALUE_INNER_CELL_HEADER 20
#define MULTI_VALUE_INNER_CELL_BOTTOM_SPACE 4

@interface MultiValueListCell : UITableViewCell <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *header;
@property (weak, nonatomic) IBOutlet UITableView *tableViewInsideCell;
@property (strong, nonatomic) NSDictionary *attribute;
@property (weak, nonatomic) id <MultiValueDelegate> delegate;
@property (strong, nonatomic) NSString* fieldname;
@property (strong, nonatomic) NSArray* selectedOptions;
@end
