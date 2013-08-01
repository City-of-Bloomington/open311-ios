//
//  StringCell.h
//  GeoReporter
//
//  Created by Marius Constantinescu on 7/22/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextEntryDelegate.h"

#define STRING_CELL_TEXT_FIELD_HEIGHT 30
#define STRING_CELL_HEADER 20
#define STRING_CELL_BOTTOM_SPACE 4

@interface StringCell : UITableViewCell <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *header;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property id<TextEntryDelegate>delegate;
@property (strong, nonatomic) NSString* fieldname;
@end
