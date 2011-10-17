//
//  Settings.m
//  open311
//
//  Created by Cliff Ingham on 8/31/11.
//  Copyright 2011 City of Bloomington. All rights reserved.
//

#import "Settings.h"
#import "SynthesizeSingleton.h"
#import "Open311.h"

@implementation Settings
SYNTHESIZE_SINGLETON_FOR_CLASS(Settings);

@synthesize availableServers,myServers,myRequests;
@synthesize currentServer;
@synthesize first_name, last_name, email, phone;


- (id) init
{
    self = [super init];
    if (self) {
        [self load];
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

/**
 * Resets Open311 to point to a different server
 *
 * Open311 needs to load the discovery and services for the new server
 * The list of servers is stored in AvailableServers.plist
 * The user will choose one, and we'll take it's dictionary and put it
 * into self.currentServer
 *
 * @param NSDictionary server Server should have keys for name and url
 */
- (void)switchToServer:(NSDictionary *)server
{
    Open311 *open311 = [Open311 sharedOpen311];
    DLog(@"Switching to server: %@",[server objectForKey:@"URL"]);
    [open311 reload:[NSURL URLWithString:[server objectForKey:@"URL"]]];
    self.currentServer = server;
}
@end
