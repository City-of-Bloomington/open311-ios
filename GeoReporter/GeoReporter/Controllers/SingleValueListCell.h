//
//  SingleValueListCell.h
//  GeoReporter
//
//  Created by Marius Constantinescu on 7/22/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextEntryDelegate.h"

#define SINGLE_VALUE_INNER_CELL_HEIGHT 28
#define SINGLE_VALUE_INNER_CELL_HEADER 20
#define SINGLE_VALUE_INNER_CELL_BOTTOM_SPACE 4

@interface SingleValueListCell : UITableViewCell <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *header;
@property (weak, nonatomic) IBOutlet UITableView *tableViewInsideCell;
@property (strong, nonatomic) NSDictionary *attribute;
@property (weak, nonatomic) id <TextEntryDelegate> delegate;
@property (strong, nonatomic) NSString* fieldname;
@property (strong, nonatomic) NSString* selectedOption;
@end
