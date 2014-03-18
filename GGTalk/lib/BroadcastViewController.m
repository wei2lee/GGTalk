//
//  BroadcastViewController.m
//  GGTalk
//
//  Created by lee yee chuan on 3/7/14.
//  Copyright (c) 2014 lee yee chuan. All rights reserved.
//

#import "BroadcastViewController.h"
#import "NSUserDefaults+StandardUserDefaults.h"
#import "NSUserDefaults+Utility.h"

@interface BroadcastViewController ()
@property (atomic, strong) ESTBeaconManager* beaconManager;
@property (nonatomic, strong) Beacon* beacon;
@property (nonatomic) BOOL broadcasting;
@property (nonatomic) BOOL shownBroadcastMustForegroundAlertView;
@end

#define STAFF_BEACON_MAJOR (38899)
#define STAFF_BEACON_START_MINOR (49493)


@implementation BroadcastViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)showAlert
{
    if(!self.shownBroadcastMustForegroundAlertView){
        NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
        if([ud boolForKey:(WARN_BROADCAST_MUST_FOREGROUND_ALERT_VIEW_DONT_SHOW_AGAIN) orFallback:YES]) {
            [[UIAlertView showWithTitle:@"Info"
                                message:@"Broadcasting only work while app is active."
                      cancelButtonTitle:@"Close"
                      otherButtonTitles:@[@"Don't Show Again"]
                               tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                   if (buttonIndex == 1) {
                                       [ud setBool:YES forKey:(INIT_BEACON_FAILED_ALERT_VIEW_DONT_SHOW_AGAIN)];
                                   }
                                   self.shownBroadcastMustForegroundAlertView = YES;
                               }] show];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.nameTF.delegate = self;
    self.nameTF.layer.borderColor = createColorWithRGBHex(0xcccccc).CGColor;
    self.nameTF.layer.borderWidth = 1;
    self.nameTF.backgroundColor = [UIColor whiteColor];
    
    self.departTF.delegate = self;
    self.departTF.layer.borderColor = createColorWithRGBHex(0xcccccc).CGColor;
    self.departTF.layer.borderWidth = 1;
    self.departTF.backgroundColor = [UIColor whiteColor];
    
    self.jobTitleTF.delegate = self;
    self.jobTitleTF.layer.borderColor = createColorWithRGBHex(0xcccccc).CGColor;
    self.jobTitleTF.layer.borderWidth = 1;
    self.jobTitleTF.backgroundColor = [UIColor whiteColor];
    
    self.descTV.backgroundColor = [UIColor whiteColor];
    self.descTV.layer.borderColor = createColorWithRGBHex(0xcccccc).CGColor;
    self.descTV.layer.borderWidth = 1;
    self.descTV.delegate = self;
    GCPlaceholderTextView* gcDescTV = (id)self.descTV;
    gcDescTV.placeholder = @"description";
    
    self.startBtn.backgroundColor = createColorWithRGBHex(0xf8363c);
    self.backBtn.backgroundColor = createColorWithRGBHex(0xf8363c);
    
    self.statLbl.alpha = 0;
    self.statLbl.text = @"";
}

-(void)clear {
    self.nameTF.text = @"";
    self.jobTitleTF.text = @"";
    self.departTF.text = @"";
    self.descTV.text = @"";
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    // register for keyboard notifications
    /*
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];//*/
    
    if(self.view.bounds.size.height <= 480) {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChangeFrame:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];//*/
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    // unregister for keyboard notifications while not visible.
    /*
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];//*/
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Keyboard
-(void)keyboardWillChangeFrame:(NSNotification*)notification
{
    NSLog(@"keyboardWillChangeFrame");
    NSDictionary * userInfo = notification.userInfo;
    UIViewAnimationCurve animationCurve  = [userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue];
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // convert the keyboard's CGRect from screen coords to view coords
    CGRect kbEndFrame = [self.view convertRect:[[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue]
                                      fromView:self.view.window];
    CGRect kbBeginFrame = [self.view convertRect:[[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue]
                                        fromView:self.view.window];
    CGFloat deltaKeyBoardOrigin = kbEndFrame.origin.y - kbBeginFrame.origin.y;
    int sign = deltaKeyBoardOrigin > 0 ? 1 : -1;
    
    deltaKeyBoardOrigin = 200 * sign;
    // update the constant factor of the constraint governing your tracking view
    //self.bottomVerticalSpacerConstraint.constant -= deltaKeyBoardOrigin;
    self.mainTopContraint.constant += deltaKeyBoardOrigin/2;
    self.mainBottomContraint.constant -= deltaKeyBoardOrigin/2;
    // tell the constraint solver it needs to re-solve other constraints.
    [self.view setNeedsUpdateConstraints];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:animationCurve];
    [UIView setAnimationBeginsFromCurrentState:YES];
    // within this animation block, force the layout engine to apply
    // the new layout changes immediately, so that we
    // animate to that new layout. We need to use old-style
    // UIView animations to pass the curve type.
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    //NSLog(@"text=%@, (%d)", text, [text characterAtIndex:0]);
    if(text.length>0 && [text characterAtIndex:0]==10){
        [textView resignFirstResponder];
    }
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView {
    //NSLog(@"textViewDidBeginEditing");
}
-(void)textViewDidEndEditing:(UITextView *)sender
{
    //NSLog(@"textViewDidEndEditing");
    [sender resignFirstResponder];
}
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    //NSLog(@"textFieldDidBeginEditing");
}
-(void)textFieldDidEndEditing:(UITextField *)textField {
    //NSLog(@"textFieldDidEndEditing");
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //NSLog(@"textFieldShouldReturn");
    [textField resignFirstResponder];
    return NO;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //NSLog(@"touchesBegan");
    [self.nameTF resignFirstResponder];
    [self.jobTitleTF resignFirstResponder];
    [self.departTF resignFirstResponder];
    [self.descTV resignFirstResponder];
}


#pragma mark -
- (void) startBroadcast:(id)sender {
    
    if(!self.beaconManager) {
        self.beaconManager = [[ESTBeaconManager alloc] init];
        self.beaconManager.avoidUnknownStateBeacons = YES;
    }
    self.startBtn.enabled = NO;
    self.startBtn.alpha = 0.5;
    
    self.statLbl.text = @"Starting...";
    [UIView animateWithDuration:0.2 animations:^{
        self.statLbl.alpha = 1;
        self.backBtn.alpha = 0;
    }];
    
    NSURL* url = [NSURL URLWithString:@"http://ggtalk.parseapp.com/requestNewStaffBeacon"];
    [NSData dataWithContentsOfURL:url completionBlock:^(NSData* data, NSError* error){
        if(error){
            NSUserDefaults* ud = NSUserDefaults.standardUserDefaults;
            if([ud boolForKey:(INIT_BEACON_FAILED_ALERT_VIEW_DONT_SHOW_AGAIN) orFallback:YES]) {
                [[UIAlertView showWithTitle:@"Unable to request unique identifier for broadcasting"
                                    message:@"Please make sure internet connection is on and try again."
                          cancelButtonTitle:@"Close"
                          otherButtonTitles:@[@"Don't Show Again"]
                                   tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                       if (buttonIndex == 1) {
                                           [ud setBool:YES forKey:(INIT_BEACON_FAILED_ALERT_VIEW_DONT_SHOW_AGAIN)];
                                       }
                                   }] show];
            }
            self.startBtn.enabled = YES;
            self.startBtn.alpha = 1.0;
            
            [UIView animateWithDuration:0.2 animations:^{
                self.statLbl.alpha = 0;
            }];
        }else{
            NSDictionary* json = [NSJSONSerialization
                                  JSONObjectWithData:data
                                  options:kNilOptions
                                  error:nil];

            //PFObject* pfBeacon = [PFObject objectWithoutDataWithClassName:@"Beacon" objectId:json[@"beacon"][@"objectId"]];
            
            NSMutableDictionary* mjbeacon = [json[@"beacon"] mutableCopy];
            NSString* objectId = mjbeacon[@"objectId"];
            [mjbeacon removeObjectForKey:@"objectId"];
            [mjbeacon removeObjectForKey:@"createdAt"];
            [mjbeacon removeObjectForKey:@"updatedAt"];
            [mjbeacon setObject:[NSNull null] forKey:@"item"];
            PFObject* pfBeacon = [PFObject objectWithClassName:@"Beacon" dictionary:mjbeacon];
            pfBeacon.objectId = objectId;
            
            //pfBeacon[@"proximityUUID"] = json[@"beacon"][@"proximityUUID"];
            //pfBeacon[@"major"] = json[@"beacon"][@"major"];
            //pfBeacon[@"minor"] = json[@"beacon"][@"minor"];
            //pfBeacon[@"item"] = [NSNull null];
            //[pfBeacon setObject:[NSNull null] forKey:@"item"];
            
            PFObject* pfStaff = [[PFObject alloc] initWithClassName:@"Staff"];
            pfStaff[@"name"] = self.nameTF.text;
            pfStaff[@"jobTitle"] = self.jobTitleTF.text;
            pfStaff[@"department"] = self.departTF.text;
            pfStaff[@"description"] = self.descTV.text;
            pfStaff[@"timeout"] = @10;
            pfStaff[@"deleted"] = @NO;
            pfBeacon[@"staff"] = pfStaff;

            
            [pfBeacon saveInBackgroundWithBlock:^(BOOL success, NSError* error){
                if(success) {
                    self.beacon = createBeaconWithData(pfBeacon);
                    [self.beaconManager startAdvertisingWithProximityUUID:self.beacon.proximityUUID
                                                                    major:[self.beacon.major intValue]
                                                                    minor:[self.beacon.minor intValue]
                                                               identifier:getObjectId(self.beacon.data)];
                    [self updateBroadcastingUI:YES];
                    
                    
                    ViewController* pvc = (id)self.parentViewController;
                    [pvc addBeacon:self.beacon];
                }else{
                    [UIView animateWithDuration:0.2 animations:^{
                        self.statLbl.alpha = 0;
                    }];
                }
                self.startBtn.enabled = YES;
                self.startBtn.alpha = 1.0;
            }];
        }
    }];
    //*/
}
int updatebroadcastcnt = 0;
- (void) updateBroadcastingUI:(BOOL) b {
    if(b) {
        updatebroadcastcnt++;
        self.broadcasting = YES;
        [UIView animateWithDuration:0.3 animations:^{
            self.statLbl.alpha = 1;
            self.statLbl.text = @"Broadcasting...";
            
            self.nameTF.enabled = NO;
            self.jobTitleTF.enabled = NO;
            self.departTF.enabled = NO;
            self.descTV.userInteractionEnabled = NO;
            
            self.backBtn.alpha = 0;
            
            [self.startBtn setTitle:@"Cancel" forState:UIControlStateNormal];
        }];
    }else{
        updatebroadcastcnt++;
        self.broadcasting = NO;
        
        [UIView animateWithDuration:0.3 animations:^{
            self.statLbl.alpha = 0;
            //self.statLbl.text = @"";
            
            self.nameTF.enabled = YES;
            self.jobTitleTF.enabled = YES;
            self.departTF.enabled = YES;
            self.descTV.userInteractionEnabled = YES;

            self.backBtn.alpha = 1;
            [self.startBtn setTitle:@"active as iBeacon" forState:UIControlStateNormal];
        }];
    }
}

- (BOOL) validate {
    NSString* errorMsg = nil;
    NSString* errorTitle = nil;
    if([self.nameTF.text isEqualToString:@""] ||
       [self.jobTitleTF.text isEqualToString:@""] ||
       [self.departTF.text isEqualToString:@""] ||
       [self.descTV.text isEqualToString:@""]) {
        errorMsg = @"All text field must contains no empty string";
        errorTitle = @"Input is not completed";
    }
    if(errorMsg != nil){
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:errorTitle
                                                        message:errorMsg
                                                       delegate:nil
                                              cancelButtonTitle:@"Close"
                                              otherButtonTitles:nil];
        [alert show];
    }
    return errorMsg == nil;
}

- (void) beaconManagerDidStartAdvertising:(ESTBeaconManager *)manager error:(NSError *)error {
    if(!error) return;
    if(error.code == 9) return;
    NSUserDefaults* ud = NSUserDefaults.standardUserDefaults;
    if([ud boolForKey:(ADVERTISING_BEACON_FAILED_ALERT_VIEW_DONT_SHOW_AGAIN) orFallback:YES]) {
        [[UIAlertView showWithTitle:@"Unable to broadcast"
                            message:@"Please make sure bluetooth is on and try again."
                  cancelButtonTitle:@"Close"
                  otherButtonTitles:@[@"Don't Show Again"]
                           tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                               if (buttonIndex == 1) {
                                   [ud setBool:YES forKey:(ADVERTISING_BEACON_FAILED_ALERT_VIEW_DONT_SHOW_AGAIN)];
                               }
                           }] show];
    }
    if(self.broadcasting)
        [self updateBroadcastingUI:NO];//*/
}


#pragma mark - UIAction


- (IBAction)backBtnTouchUpInside:(id)sender {
    ViewController* pvc = (id)self.parentViewController;
    pvc.stat = @"landing";
    self.view.superview.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.view.alpha = 0;
        
        pvc.beaconList.alpha = 0;
        pvc.control.alpha = 0;
        
        pvc.backMainBtn1.alpha = 0;
        pvc.locatingLbl.alpha = 0;
        
        pvc.gotoLocateBtn.alpha = 1;
        pvc.gotoActiveBtn.alpha = 1;
        
        UIView* homebg = pvc.homebgs[0];
        homebg.alpha = 1;
        pvc.homelogo.alpha = 1;
    }];
    
    [self clear];
}

- (IBAction)startBtnTouchUpInside:(id)sender {
    if(![self validate])return;
    if(!self.broadcasting) {
        self.startBtn.enabled = NO;
        self.startBtn.alpha = 0.5;
        [self startBroadcast:nil];
    }else{
        [self.beaconManager stopAdvertising];
        self.statLbl.text = @"Cancelling...";
        self.startBtn.enabled = NO;
        [UIView animateWithDuration:0.2 animations:^{
            self.startBtn.alpha = 0.5;
        }];
        [PFObject deleteAllInBackground:@[self.beacon.data, self.beacon.data[@"staff"]] block:^(BOOL success, NSError* error){
            if(!success) {
                NSUserDefaults* ud = NSUserDefaults.standardUserDefaults;
                if([ud boolForKey:(DELETE_BEACON_FAILED_ALERT_VIEW_DONT_SHOW_AGAIN) orFallback:YES]) {
                    [[UIAlertView showWithTitle:@"Unable to clear server record"
                                        message:@"Please make sure internet connection is on and try again."
                              cancelButtonTitle:@"Close"
                              otherButtonTitles:@[@"Don't Show Again"]
                                       tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                           if (buttonIndex == 1) {
                                               [ud setBool:YES forKey:(DELETE_BEACON_FAILED_ALERT_VIEW_DONT_SHOW_AGAIN)];
                                           }
                                       }] show];
                }
            }
            ViewController* pvc = (id)self.parentViewController;
            [pvc removeBeacon:self.beacon];
            
            
            self.beacon.data = nil;
            [self updateBroadcastingUI:NO];
            
            self.startBtn.enabled = YES;
            [UIView animateWithDuration:0.2 animations:^{
                self.startBtn.alpha = 1;
            }];
        }];
    }
}



@end
