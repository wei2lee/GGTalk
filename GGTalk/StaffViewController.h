//
//  StaffViewController.h
//  GGTalk
//
//  Created by lee yee chuan on 3/7/14.
//  Copyright (c) 2014 lee yee chuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StaffViewController : UIViewController <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSString* urlstr;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingInd;
-(void)reload;
#pragma mark - UIAction

@end
