//
//  AboutViewController.m
//  open311
//
//  Created by Cliff Ingham on 11/3/11.
//  Copyright (c) 2011 City of Bloomington. All rights reserved.
//

#import "AboutViewController.h"

@implementation AboutViewController
@synthesize aboutView;

- (void)dealloc {
    [aboutView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.navigationItem setTitle:@"About"];
    [self.aboutView loadRequest:[NSURLRequest requestWithURL:[[NSBundle mainBundle] URLForResource:@"about" withExtension:@"html"]]];
}

- (void)viewDidUnload
{
    [self setAboutView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - Web View Handlers

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    return YES;
}

@end
