//
//  CustomServerViewController.h
//  open311
//
//  Created by Cliff Ingham on 10/28/11.
//  Copyright (c) 2011 City of Bloomington. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomServerAddDelegate
- (void)didAddServer:(NSDictionary *)server;
@end


@interface CustomServerViewController : UIViewController <UITextFieldDelegate> {
    id <CustomServerAddDelegate> delegate;
    IBOutlet UITextField *name;
    IBOutlet UITextField *url;
    IBOutlet UITextField *jurisdiction;
    IBOutlet UITextField *api_key;
}

@property (nonatomic, retain) id <CustomServerAddDelegate> delegate;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
@end



