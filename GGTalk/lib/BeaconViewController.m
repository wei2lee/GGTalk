//
//  BeaconViewController.m
//  GGTalk
//
//  Created by lee yee chuan on 3/7/14.
//  Copyright (c) 2014 lee yee chuan. All rights reserved.
//

#import "BeaconViewController.h"

@interface BeaconViewController ()

@end

@implementation BeaconViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.webView.alpha = 0;
    self.webView.opaque=NO;
    self.webView.backgroundColor=UIColor.clearColor;
    [self reload];
}

- (void) reload {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSRange range = [self.urlstr rangeOfString:@"http"];
    NSString* urlstr = self.urlstr;
    if(range.location == NSNotFound || range.location != 0) {
        urlstr = pathForResource(NSBundle.mainBundle, self.urlstr);
    }
    NSURL* url = [NSURL URLWithString:urlstr];
    
    BOOL cacheExisted = NO;
    
    if([[NSURLCache sharedURLCache] cachedResponseForRequest:[NSURLRequest requestWithURL:url]]){
        cacheExisted = YES;
    }
    BOOL cacheExisted2 = NO;
    if([NSURLCache.sharedURLCache cachedResponseForRequest:[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:10]]){
        cacheExisted2 = YES;
    }
    
    //NSURLRequestCachePolicy cachepolicy = NSURLRequestReturnCacheDataElseLoad;
    NSURLRequestCachePolicy cachepolicy = NSURLRequestUseProtocolCachePolicy;
    
    NSURLRequest* req = [NSURLRequest requestWithURL:url cachePolicy:cachepolicy timeoutInterval:10];
    [self.webView loadRequest:req];
    self.webView.delegate = self;
    [self.loadingInd startAnimating];
    NSLog(@"beacon load %@", urlstr);
    [UIView animateWithDuration:0.2 animations:^{
        self.webView.alpha = 0;
        self.loadingInd.alpha = 1;
    } completion:^(BOOL finished){
    }];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.webView.delegate = nil;
    [self.webView stopLoading];
    [self.loadingInd stopAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - <UIWebViewDelegate>
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.loadingInd stopAnimating];
    [UIView animateWithDuration:0.2 animations:^{
        self.webView.alpha = 1;
        self.webView.delegate = nil;
        self.loadingInd.alpha = 0;
    } completion:^(BOOL finished){
    }];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
/*
 NSURLRequestUseProtocolCachePolicy = 0,
 
 NSURLRequestReloadIgnoringLocalCacheData = 1,
 NSURLRequestReloadIgnoringLocalAndRemoteCacheData = 4, // Unimplemented
 NSURLRequestReloadIgnoringCacheData = NSURLRequestReloadIgnoringLocalCacheData,
 
 NSURLRequestReturnCacheDataElseLoad = 2,
 NSURLRequestReturnCacheDataDontLoad = 3,
 
 NSURLRequestReloadRevalidatingCacheData = 5, // Unimplemented
//*/
NSLog(@"load %@, cachePolicy=%lu", request, (unsigned long)request.cachePolicy);
    
    
    return YES;
}


#pragma mark - UIAction
- (IBAction)testTapHandle:(id)sender {
    ViewController* contvc = (id)self.parentViewController;
    [contvc onAllOutRange:nil];
}
@end
