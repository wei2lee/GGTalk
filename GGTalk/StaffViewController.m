//
//  StaffViewController.m
//  GGTalk
//
//  Created by lee yee chuan on 3/7/14.
//  Copyright (c) 2014 lee yee chuan. All rights reserved.
//

#import "StaffViewController.h"

@interface StaffViewController ()

@end

@implementation StaffViewController

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

-(void)reload {
	// Do any additional setup after loading the view.
    NSRange range = [self.urlstr rangeOfString:@"http"];
    NSString* urlstr = self.urlstr;
    if(range.location == NSNotFound || range.location != 0) {
        urlstr = pathForResource(NSBundle.mainBundle, self.urlstr);
    }
    
    NSURL* url = [NSURL URLWithString:urlstr];
    
    //NSURLRequestCachePolicy cachepolicy = NSURLRequestReturnCacheDataElseLoad;
    NSURLRequestCachePolicy cachepolicy = NSURLRequestUseProtocolCachePolicy;
    
    NSURLRequest* req = [NSURLRequest requestWithURL:url cachePolicy:cachepolicy timeoutInterval:10];
    [self.webView loadRequest:req];
    self.webView.delegate = self;
    [self.loadingInd startAnimating];
    
    NSLog(@"Staff load %@", urlstr);
    
    [UIView animateWithDuration:0.2 animations:^{
        self.webView.alpha = 0;
        self.loadingInd.alpha = 1;
    } completion:^(BOOL finished){
    }];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.webView.delegate = nil;
    [self.loadingInd stopAnimating];
    [self.webView stopLoading];
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


#pragma mark - UIAction
- (IBAction)testTapHandle:(id)sender {
    ViewController* contvc = (id)self.parentViewController;
    [contvc onAllOutRange:nil];
}
@end
