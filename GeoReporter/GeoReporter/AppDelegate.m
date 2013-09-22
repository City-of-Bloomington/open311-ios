/**
 * @copyright 2013 City of Bloomington, Indiana. All Rights Reserved
 * @author Cliff Ingham <inghamn@bloomington.in.gov>
 * @license http://www.gnu.org/licenses/gpl.txt GNU/GPLv3, see LICENSE.txt
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */

#import "AppDelegate.h"
#import <UIKit/UIKit.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    if (isRunningiOS7()) {
        [self applyTheme];
    }
    return YES;
}


static BOOL isRunningiOS7() {
    #if defined(__IPHONE_7_0) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0)
    // compiled with >= iOS 7 SDK
    // flat when compiled with >= iOS 7 SDK and running on >= iOS 7:
    return (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_7_0);
    #else
    // compiled with < iOS 7 SDK; we're never in Flat Mode
    return NO;
    #endif
}
-(void)applyTheme
{
    NSDictionary *barButtonTitleTextAttributes = @{
                                                  UITextAttributeFont:[UIFont systemFontOfSize:13.f],
                                                  UITextAttributeTextColor: [UIColor orangeColor],
                                                  UITextAttributeTextShadowColor: [UIColor colorWithWhite:0.0f alpha:0.5f],
                                                  UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 0.0f)]
                                                  };
    UIBarButtonItem *barButton = [UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil];
	[barButton setTitleTextAttributes:barButtonTitleTextAttributes forState:UIControlStateNormal];
    
	[barButton setTitleTextAttributes:barButtonTitleTextAttributes forState:UIControlStateHighlighted];
    
    

}

@end
