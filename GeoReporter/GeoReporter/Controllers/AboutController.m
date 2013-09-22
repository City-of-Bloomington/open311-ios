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

#import "AboutController.h"
#import "Strings.h"

@interface AboutController ()

@end

@implementation AboutController

- (void)viewDidLoad
{
	[super viewDidLoad];
	//make view controller start below navigation bar; this wrks in iOS 7
	if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
		self.edgesForExtendedLayout = UIRectEdgeNone;
	
	self.navigationItem.title = NSLocalizedString(kUI_About, nil);
	
	[self.webView loadRequest:[NSURLRequest requestWithURL:[[NSBundle mainBundle] URLForResource:@"about" withExtension:@"html"]]];
	[self removeScrollBackground:self.webView];
	
}

- (void)removeScrollBackground:(UIWebView *)webView
{
	webView.backgroundColor = [UIColor whiteColor];
	for (UIView* subView in [webView subviews])
	{
		if ([subView isKindOfClass:[UIScrollView class]]) {
			for (UIView* shadowView in [subView subviews])
			{
				if ([shadowView isKindOfClass:[UIImageView class]]) {
					[shadowView setHidden:YES];
				}
			}
		}
	}
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
