//
//  ContainerViewController.h
//  GeoReporter
//
//  Created by Marius Constantinescu on 9/16/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupDelegate.h"
#import "ChooseServiceController.h"
#import <MBProgressHUD.h>

@interface ContainerViewController : UIViewController <GroupDelegate, ServiceDelegate, MBProgressHUDDelegate> {
    MBProgressHUD *HUD;
}

@property (weak, nonatomic) NSString* selectedGroup;
@property (weak, nonatomic) NSDictionary* selectedService;
@property (strong, nonatomic) ChooseServiceController* serviceController;
@end
