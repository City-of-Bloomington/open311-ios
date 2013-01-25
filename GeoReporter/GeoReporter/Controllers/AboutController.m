//
//  AboutController.m
//  GeoReporter
//
//  Created by Cliff Ingham on 1/25/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import "AboutController.h"

@interface AboutController ()

@end

@implementation AboutController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.webView loadRequest:[NSURLRequest requestWithURL:[[NSBundle mainBundle] URLForResource:@"about" withExtension:@"html"]]];
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

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *script = [NSString stringWithFormat:@"document.getElementById('version').innerHTML='v%@'", version];
    [webView stringByEvaluatingJavaScriptFromString:script];
}

@end
