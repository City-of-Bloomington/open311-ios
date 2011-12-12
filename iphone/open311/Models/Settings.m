/**
 * Handles loading and saving of all data from storage on the phone
 *
 * @copyright 2011 City of Bloomington, Indiana. All Rights Reserved
 * @author Cliff Ingham <inghamn@bloomington.in.gov>
 * @license http://www.gnu.org/licenses/gpl.txt GNU/GPLv3, see LICENSE.txt
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */

#import "Settings.h"
#import "Open311.h"

@implementation Settings

static id _sharedSettings = nil;

@synthesize availableServers,myServers,myRequests;
@synthesize currentServer;
@synthesize first_name, last_name, email, phone;

+ (void)initialize
{
    if (self == [Settings class]) {
        _sharedSettings = [[self alloc] init];
    }
}

+ (id)sharedSettings
{
    return _sharedSettings;
}

- (id) init
{
    self = [super init];
    if (self) {
        [self load];
        // Always load the first server in the plist
        // This is the only server this app should work with.
        self.currentServer = [[self.availableServers objectForKey:@"Servers"] objectAtIndex:0];
    }
    return self;
}

- (void) dealloc
{
    [first_name release];
    [last_name release];
    [email release];
    [phone release];
    [myRequests release];
    [myServers release];
    [availableServers release];
    [currentServer release];
    [super dealloc];
}

#pragma mark - Loading functions
/**
 * Loads all the stored data
 */
- (void) load
{
    [self loadAvailableServers];
    [self loadMyServers];
    [self loadMyRequests];
    [self loadStandardUserDefaults];
}

- (void)loadAvailableServers
{
    self.availableServers = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AvailableServers" ofType:@"plist"]];
}

- (void)loadMyServers
{
    NSString *plistPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"MyServers.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        self.myServers = [[NSMutableArray alloc] init];
    }
    else {
        self.myServers = [NSMutableArray arrayWithContentsOfFile:plistPath];
    }
    [self refreshMyServersFromAvailableServers];
}

- (void)loadMyRequests
{
    NSString *plistPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"MyRequests.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        self.myRequests = [[NSMutableArray alloc] init];
    }
    else {
        self.myRequests = [NSMutableArray arrayWithContentsOfFile:plistPath];
    }
}

- (void)loadStandardUserDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.currentServer = [defaults objectForKey:@"currentServer"];
    self.first_name = [defaults objectForKey:@"first_name"] ? [defaults objectForKey:@"first_name"] : @"";
    self.last_name = [defaults objectForKey:@"last_name"] ? [defaults objectForKey:@"last_name"] : @"";
    self.email = [defaults objectForKey:@"email"] ? [defaults objectForKey:@"email"] : @"";
    self.phone = [defaults objectForKey:@"phone"] ? [defaults objectForKey:@"phone"] : @"";
}

/**
 * Get fresh copies of all MyServers 
 *
 * Iterates through all MyServers and replaces each one with a
 * fresh copy of its entry in AvailableServers.
 *
 * This app is going to be updated over time and the defintions
 * in AvailableServers are subject to change.  As we update
 * URLs or api_keys for servers in AvailableServers, we want to
 * make sure those changes get applied to the saved MyServers.
 */
- (void)refreshMyServersFromAvailableServers
{
    for (int i=0; i<[self.myServers count]; i++) {
        NSDictionary *server = [self.myServers objectAtIndex:i];
        NSString *myJurisdiction = [server objectForKey:@"jurisdiction_id"];
        if (myJurisdiction) {
            for (NSDictionary *availableServer in [self.availableServers objectForKey:@"Servers"]) {
                NSString *availableJurisdiction = [availableServer objectForKey:@"jurisdiction_id"];
                if (availableJurisdiction && [myJurisdiction isEqualToString:availableJurisdiction]) {
                    [self.myServers replaceObjectAtIndex:i withObject:availableServer];
                    break;
                }
            }
        }
    }
}



/**
 * Saves all the data we've collected
 *
 * We can ignore Available Servers, because that data should never change
 */
- (void) save
{
    [self.myServers writeToFile:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"MyServers.plist"] atomically:TRUE];
    [self.myRequests writeToFile:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"MyRequests.plist"] atomically:TRUE];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.currentServer forKey:@"currentServer"];
    [defaults setObject:self.first_name forKey:@"first_name"];
    [defaults setObject:self.last_name forKey:@"last_name"];
    [defaults setObject:self.email forKey:@"email"];
    [defaults setObject:self.phone forKey:@"phone"];
    [defaults synchronize];
}

@end
