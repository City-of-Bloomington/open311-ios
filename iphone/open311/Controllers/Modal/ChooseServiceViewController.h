//
//  ChooseServiceViewController.h
//  open311
//
//  Created by Cliff Ingham on 11/3/11.
//  Copyright (c) 2011 City of Bloomington. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChooseGroupViewController.h"

@interface ChooseServiceViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    id <ServiceChooserDelegate> delegate;
    NSString *group;
    NSMutableArray *services;
}
@property (retain, nonatomic) IBOutlet UITableView *serviceTable;
@property (nonatomic, retain) NSMutableArray *services;

- (id)initWithDelegate:(id <ServiceChooserDelegate>)serviceChooserDelegate group:(NSString *)serviceGroup;
- (void)loadServices;

@end
