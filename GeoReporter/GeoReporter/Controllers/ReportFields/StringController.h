//
//  StringController.h
//  GeoReporter
//
//  Created by Cliff Ingham on 2/6/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextEntryDelegate.h"

@interface StringController : UIViewController
@property (strong, nonatomic) NSDictionary *attribute;
@property (strong, nonatomic) NSString *currentValue;
@property id<TextEntryDelegate>delegate;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UITextField *textField;
- (IBAction)done:(id)sender;
@end
