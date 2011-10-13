//
//  SettingsViewController.h
//  open311
//
//  Created by Cliff Ingham on 10/12/11.
//  Copyright 2011 City of Bloomington. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController <UITextFieldDelegate> {
    UITextField *firstname;
    UITextField *lastname;
    UITextField *email;
    UITextField *phone;
}

@property (nonatomic, retain) IBOutlet UITextField *firstname;
@property (nonatomic, retain) IBOutlet UITextField *lastname;
@property (nonatomic, retain) IBOutlet UITextField *email;
@property (nonatomic, retain) IBOutlet UITextField *phone;

@end
