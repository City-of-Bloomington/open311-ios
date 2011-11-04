//
//  ChooseGroupViewController.h
//  open311
//
//  Created by Cliff Ingham on 11/3/11.
//  Copyright (c) 2011 City of Bloomington. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ServiceChooserDelegate
- (void)didSelectService:(NSDictionary *)service;
@end

@interface ChooseGroupViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    id <ServiceChooserDelegate> delegate;
    NSMutableArray *groups;
}

@property (nonatomic, retain) NSMutableArray *groups;
@property (retain, nonatomic) IBOutlet UITableView *groupTable;

- (id)initWithDelegate:(id <ServiceChooserDelegate>)serviceChooserDelegate;
- (void)loadGroups;

@end
