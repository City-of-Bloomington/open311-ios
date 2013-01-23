//
//  AboutViewController.m
//  GeoReporter
//
//  Created by Cliff Ingham on 1/23/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import "AboutViewController.h"
#import "Strings.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (id)init
{
    self = [super initWithNibName:@"AboutView" bundle:nil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setTitle:NSLocalizedString(kUI_About, nil)];
    [_aboutView loadRequest:[NSURLRequest requestWithURL:[[NSBundle mainBundle] URLForResource:@"about" withExtension:@"html"]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Web View Handlers

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *script = [NSString stringWithFormat:@"document.getElementById('version').innerHTML='v%@'", version];
    [webView stringByEvaluatingJavaScriptFromString:script];
}

@end
