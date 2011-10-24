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

#import <Foundation/Foundation.h>


@interface Settings : NSObject {
@public
    NSDictionary *availableServers;
    NSMutableArray *myServers;
    NSMutableArray *myRequests;
}
@property (nonatomic, retain) NSDictionary *availableServers;
@property (nonatomic, retain) NSMutableArray *myServers;
@property (nonatomic, retain) NSMutableArray *myRequests;

@property (nonatomic, retain) NSDictionary *currentServer;
@property (nonatomic, retain) NSString *first_name;
@property (nonatomic, retain) NSString *last_name;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *phone;

+ (id)sharedSettings;

- (void)load;
- (void)save;

- (void)loadAvailableServers;
- (void)loadMyServers;
- (void)loadMyRequests;
- (void)loadStandardUserDefaults;

@end
