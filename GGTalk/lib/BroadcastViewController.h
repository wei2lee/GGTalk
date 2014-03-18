//
//  BroadcastViewController.h
//  GGTalk
//
//  Created by lee yee chuan on 3/7/14.
//  Copyright (c) 2014 lee yee chuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BroadcastViewController : UIViewController <UIWebViewDelegate, UITextFieldDelegate, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITextField *jobTitleTF;
@property (weak, nonatomic) IBOutlet UITextField *departTF;
@property (weak, nonatomic) IBOutlet UITextView *descTV;
@property (weak, nonatomic) IBOutlet UILabel *statLbl;
@property (weak, nonatomic) IBOutlet UIButton *startBtn;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mainTopContraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mainBottomContraint;
- (IBAction)backBtnTouchUpInside:(id)sender;
- (IBAction)startBtnTouchUpInside:(id)sender;
- (void)showAlert;
-(void)clear;
@end
