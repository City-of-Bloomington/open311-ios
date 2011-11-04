/**
 * @copyright 2011 City of Bloomington, Indiana. All Rights Reserved
 * @author Cliff Ingham <inghamn@bloomington.in.gov>
 * @license http://www.gnu.org/licenses/gpl.txt GNU/GPLv3, see LICENSE.txt
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */

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
