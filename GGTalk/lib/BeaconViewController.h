//
//  BeaconViewController.h
//  GGTalk
//
//  Created by lee yee chuan on 3/7/14.
//  Copyright (c) 2014 lee yee chuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BeaconViewController : UIViewController <UIWebViewDelegate>
- (IBAction)testTapHandle:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UILabel *descLbl;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSString* urlstr;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingInd;
-(void)reload;
@end
