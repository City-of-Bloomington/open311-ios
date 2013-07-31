//
//  TextCell.h
//  GeoReporter
//
//  Created by Marius Constantinescu on 7/22/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextEntryDelegate.h"

#define TEXT_CELL_TEXT_VIEW_HEIGHT 70
#define TEXT_CELL_HEADER 20
#define TEXT_CELL_BOTTOM_SPACE 4

@interface TextCell : UITableViewCell <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *header;
@property (weak, nonatomic) IBOutlet UITextView *text;
@property id<TextEntryDelegate>delegate;
@property (strong, nonatomic) NSString* fieldname;

@end
