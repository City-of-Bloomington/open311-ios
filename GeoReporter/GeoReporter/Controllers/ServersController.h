//
//  ServersController.h
//  GeoReporter
//
//  Created by Cliff Ingham on 1/25/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServersController : UITableViewController <UITableViewDataSource, UITableViewDelegate>
- (NSDictionary *)getTargetServer:(NSInteger)index;
@end
