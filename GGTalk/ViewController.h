//
//  ViewController.h
//  GGTalk
//
//  Created by lee yee chuan on 3/7/14.
//  Copyright (c) 2014 lee yee chuan. All rights reserved.
//

#import <UIKit/UIKit.h>

#define UUID @"7C918F2A-91AC-48D9-85F1-D08A3833702C"
//#define DEBUG_DID_RANGE
//#define DEBUG_OBSERVING_VALUE
//#define DEBUG_CHECK_DIRTY
//#define DEBUG_OBSERVING_CRASH

@interface ViewController : UIViewController <ESTBeaconManagerDelegate, BeaconDelegate>
@property (nonatomic, strong) NSArray*     pxNames;
@property (nonatomic, strong) NSArray*     asNames;
@property (nonatomic, strong) NSArray*     rsNames;

@property (weak, nonatomic) IBOutlet UIView *control;
@property (weak, nonatomic) IBOutlet UIImageView *homelogo;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *homebgs;
@property (weak, nonatomic) IBOutlet UIView *broadcastStat;
@property (weak, nonatomic) IBOutlet UILabel *broadcastStatNumLbl;
@property (weak, nonatomic) IBOutlet UIView *beaconListArrow;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *broadcastContentView;
@property (weak, nonatomic) IBOutlet UIView *beaconList;
@property (weak, nonatomic) IBOutlet UIScrollView *beaconListScrollView;
@property (weak, nonatomic) IBOutlet UIButton *gotoLocateBtn;
@property (weak, nonatomic) IBOutlet UIButton *gotoActiveBtn;
@property (weak, nonatomic) IBOutlet UIButton *controlBackMainBtn;
@property (strong, nonatomic) NSString* stat;

@property (readonly, nonatomic) BOOL presentingContentViewController;

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *testTap;
- (IBAction)controlTapHandle:(id)sender;
- (IBAction)testTapHandle:(id)sender;
- (IBAction)beaconListBtnTouchUpInside:(id)sender;
- (void) onAllOutRange:(id)data;
- (void) syncBeacons:(id)data;
- (void) addBeacon:(Beacon*) b;
- (void) removeBeacon:(Beacon*) b;


- (IBAction)gotoLocateBtnTouchUpInside:(id)sender;
- (IBAction)gotoActiveBtnTouchUpInside:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *backMainBtn1;
@property (weak, nonatomic) IBOutlet UILabel *locatingLbl;
- (IBAction)backMainBtnTouchUpInside:(id)sender;
- (IBAction)controlBackMainBtnTouchUpInside:(id)sender;

-(void)applicationDidBecomeActive;
-(void)applicationDidEnterBackground;

@end
