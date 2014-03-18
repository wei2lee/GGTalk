//
//  ViewController.m
//  GGTalk
//
//  Created by lee yee chuan on 3/7/14.
//  Copyright (c) 2014 lee yee chuan. All rights reserved.
//

#import "ViewController.h"
#import "geometryUtil.h"
@interface ViewController ()

@property (atomic, strong) ESTBeaconManager* beaconManager;
@property (atomic, strong) NSMutableArray* beacons;
@property (atomic, strong) NSMutableArray* monitorRegions;
@property (atomic, strong) NSMutableArray* rangeRegions;

@property (nonatomic) BOOL beaconsDirty;
@property (nonatomic) int syncBeaconsStat;
@property (nonatomic) int syncBeaconsCnt;
@property (nonatomic) NSDate* syncBeaconLastTime;

@property (nonatomic, strong) Beacon* avgNearestBeacon;
@property (nonatomic, strong) NSMutableArray* nearestBeaconSamples;

@property (atomic, strong) NSMutableDictionary* notificationFires;
@property (atomic, strong) NSMutableDictionary* itemDisplays;
@property (atomic, strong) NSMutableDictionary* cache;

@property (nonatomic, strong) BroadcastViewController* broadcastViewController;

@property (atomic, strong) PFObject* pfApp;
@property (atomic) BOOL queryingPFApp;
@property (nonatomic, strong) NSDate* dataUpdatedAt;
@property (atomic) BOOL checkingBeaconsDirtyData;
@property (nonatomic, strong) NSTimer* checkBeaconsDirtyTimer;

@end

@implementation ViewController
@synthesize stat;

#pragma mark - Helper



-(DataButton*) createBeaconListBtn:(Beacon*) b m:(int)m{
    CGRect frame;
    UIFont* font;
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
        frame = CGRectMake(0, 0 + 47 * (m), 330, 36);
        font = [UIFont systemFontOfSize: 30];
    }else{
        frame = CGRectMake(0, 0 + 32*(m), 228, 20);
        font = [UIFont systemFontOfSize: 15];
    }
    DataButton* beaconListBtn = [DataButton buttonWithType:UIButtonTypeCustom];
    beaconListBtn.frame = frame;
    [beaconListBtn setTitle:[NSString stringWithFormat:@"  %@", b.bitem[@"name"]] forState:UIControlStateNormal];
    [beaconListBtn setImage:[UIImage imageNamed:@"whitecell"] forState:UIControlStateNormal];
    beaconListBtn.titleLabel.textColor = UIColor.whiteColor;
    beaconListBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    beaconListBtn.data[@"beacon"] = b;
    beaconListBtn.titleLabel.font = font;
    [beaconListBtn addTarget:self action:@selector(beaconListBtnTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return beaconListBtn;
}


-(Beacon*)findBeacon:(id)eb{
    for(int i = 0 ; i < self.beacons.count ; i++) {
        Beacon* b = self.beacons[i];
        if([b isEqual:eb]) return b;
    }
    return nil;
}

-(Beacon*)findBeacon:(id)eb type:(NSString*)type{
    for(int i = 0 ; i < self.beacons.count ; i++) {
        Beacon* b = self.beacons[i];
        if(b.item) return b;
    }
    return nil;
}

-(NSArray*)findBeacons:(id)eb{
    NSMutableArray* ret = [NSMutableArray array];
    for(int i = 0 ; i < self.beacons.count ; i++) {
        Beacon* b = self.beacons[i];
        if([b isEqual:eb]) [ret addObject:b];
    }
    return ret;
}

id findNotification(id item, NSString* type) {
    for(id nf in item[@"notifications"]) {
        if([type isEqual:nf[@"type"]]) {
            return nf;
        }
    }
    return nil;
}

- (Beacon*) findBeaconInRange {
    for (Beacon* b in self.beacons) {
        if(b.inRange) return b;
    }
    return nil;
}

- (NSArray*) findBeaconsInRange {
    NSMutableArray* ret = [@[] mutableCopy];
    for (Beacon* b in self.beacons) {
        if(b.inRange) [ret addObject:b];
    }
    return ret;
}

- (Beacon*) findNearestBeaconInRange {
    NSArray* beacons = [self findBeaconsInRange];
    Beacon* nearestBeacon = nil;
    for (Beacon* beacon in beacons) {
        if(nearestBeacon == nil || [nearestBeacon.distance floatValue] >[beacon.distance floatValue]) {
            nearestBeacon = beacon;
        }
    }
    return nearestBeacon;
}

PFObject* jsonToPFBeacon(NSDictionary* jobj, BOOL skipAllObjectId) {
    PFObject* obj = [[PFObject alloc] initWithClassName:@"Beacon"];
    for (NSString* key in jobj.allKeys) {
        if([key isEqual:@"objectId"] && !skipAllObjectId){
            obj.objectId = toObj(jobj[key]);
        }else if([key isEqual:@"item"]) {
            obj[key] = jsonToPFItem(jobj[key], skipAllObjectId);
        }else if([key isEqual:@"staff"]) {
            obj[key] = jsonToPFStaff(jobj[key], skipAllObjectId);
        }else{
            obj[key] = toObj(jobj[key]);
        }
    }
    return obj;
}
PFObject* jsonToPFItem(NSDictionary* jobj, BOOL skipAllObjectId) {
    PFObject* obj = [[PFObject alloc] initWithClassName:@"Item"];
    for (NSString* key in jobj.allKeys) {
        if([key isEqual:@"objectId"] && !skipAllObjectId){
            obj.objectId = toObj(jobj[key]);
        }else if([key isEqual:@"notifications"]) {
            NSArray* jnfs = jobj[key];
            NSMutableArray* nfs = [@[]mutableCopy];
            for (NSDictionary* jnf in jnfs) {
                [nfs addObject:jsonToPFNotification(jnf, skipAllObjectId)];
            }
            obj[key] = nfs;
        }else{
            obj[key] = toObj(jobj[key]);
        }
    }
    return obj;
}
PFObject* jsonToPFStaff(NSDictionary* jobj, BOOL skipAllObjectId) {
    PFObject* obj = [[PFObject alloc] initWithClassName:@"Staff"];
    for (NSString* key in jobj.allKeys) {
        if([key isEqual:@"objectId"] && !skipAllObjectId){
            obj.objectId = toObj(jobj[key]);
        }else if([key isEqual:@"notifications"]) {
            NSArray* jnfs = jobj[key];
            NSMutableArray* nfs = [@[]mutableCopy];
            for (NSDictionary* jnf in jnfs) {
                [nfs addObject:jsonToPFNotification(jnf, skipAllObjectId)];
            }
            obj[key] = nfs;
        }else{
            obj[key] = toObj(jobj[key]);
        }
    }
    return obj;
}
PFObject* jsonToPFNotification(NSDictionary* jobj, BOOL skipAllObjectId) {
    PFObject* beacon = [[PFObject alloc] initWithClassName:@"Notification"];
    for (NSString* key in jobj.allKeys) {
        if([key isEqual:@"objectId"] && !skipAllObjectId){
            beacon.objectId = toObj(jobj[key]);
        }else{
            beacon[key] = toObj(jobj[key]);
        }
    }
    return beacon;
}
NSArray* jsonToPFBeacons(NSArray* jbeacons, BOOL skipAllObjectId) {
    NSMutableArray* beacons = [@[] mutableCopy];
    for (NSDictionary* jbeacon in jbeacons) {
        [beacons addObject:jsonToPFBeacon(jbeacon, skipAllObjectId)];
    }
    return beacons;
}

#pragma mark - View Cycle
-(void)applicationDidBecomeActive {
    BOOL existed = !!self.checkBeaconsDirtyTimer;
    if(!existed) {
        self.checkBeaconsDirtyTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(checkBeaconsDirty:) userInfo:nil repeats:YES];
    }
#ifdef DEBUG_CHECK_DIRTY
    NSLog(@"applicationDidBecomeActive@%@", existed ? @"timer started" : @"start timer");
#endif
}

-(void)checkBeaconsDirty:(NSTimer*)timer {
#ifdef DEBUG_CHECK_DIRTY
    NSLog(@"checkBeaconsDirty@checking=%d, dirty=%d, syncStat=%d", self.checkingBeaconsDirtyData, self.beaconsDirty, self.syncBeaconsStat);
#endif
    if(self.pfApp && !self.checkingBeaconsDirtyData && !self.beaconsDirty && (self.syncBeaconsStat == 100)) {
        self.checkingBeaconsDirtyData = YES;
        [self.pfApp refreshInBackgroundWithBlock:^(PFObject* object, NSError* error){
            if(!error){
                self.pfApp = object;
                NSDate* newDate = self.pfApp[@"dataUpdatedAt"];
                NSDate* oldDate = self.dataUpdatedAt;
                NSComparisonResult cr = [oldDate compare:newDate];
                if (cr == NSOrderedAscending) {
                    self.beaconsDirty = YES;
                    [self syncBeacons:@{@"file":@"data", @"fileType":@"json"}];
                }
#ifdef DEBUG_CHECK_DIRTY
                NSLog(@"pfApp refresh@%@", cr == NSOrderedDescending ? @"set to dirty" : @"dirty remain");
#endif
            }
            self.checkingBeaconsDirtyData = NO;
        }];
    }
}

-(void)applicationDidEnterBackground {
    BOOL existed = !!self.checkBeaconsDirtyTimer;
    if(!existed) {
        [self.checkBeaconsDirtyTimer invalidate];
        self.checkBeaconsDirtyTimer = nil;
    }
#ifdef DEBUG_CHECK_DIRTY
    NSLog(@"applicationDidEnterBackground@%@", existed ? @"stop timer" : @"timer stopped");
#endif
}


- (void) uploadAddReenterNotificationData {
    PFQuery* query = [PFQuery queryWithClassName:@"Item"];
    [query findObjectsInBackgroundWithBlock:^(NSArray* pfitems, NSError* error){
        
        
        for (PFObject* pfitem in pfitems) {
            NSMutableArray* pfnfs = [@[] mutableCopy];
            PFObject* pfnf = [[PFObject alloc] initWithClassName:@"Notification"];
            pfnf[@"deleted"] = @NO;
            pfnf[@"enabled"] = @YES;
            pfnf[@"timeout"] = @10;
            pfnf[@"txt"] = [NSString stringWithFormat:@"%@ is in range (re-enter)", pfitem[@"name"]];
            pfnf[@"type"] = @"reenter";
            pfnf[@"within"] = @3600;
            [pfnfs addObject:pfnf];
            
            pfnf = [[PFObject alloc] initWithClassName:@"Notification"];
            pfnf[@"deleted"] = @NO;
            pfnf[@"enabled"] = @YES;
            pfnf[@"timeout"] = @10;
            pfnf[@"txt"] = [NSString stringWithFormat:@"%@ is in range", pfitem[@"name"]];
            pfnf[@"type"] = @"enter";
            pfnf[@"within"] = @3600;
            [pfnfs addObject:pfnf];
            
            pfnf = [[PFObject alloc] initWithClassName:@"Notification"];
            pfnf[@"deleted"] = @NO;
            pfnf[@"enabled"] = @YES;
            pfnf[@"timeout"] = @10;
            pfnf[@"txt"] = [NSString stringWithFormat:@"%@ is out range", pfitem[@"name"]];
            pfnf[@"type"] = @"exit";
            pfnf[@"within"] = @3600;
            [pfnfs addObject:pfnf];
            
            
            pfitem[@"notifications"] = pfnfs;
        }
        
        [PFObject saveAllInBackground:pfitems];
    }];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.beaconsDirty = YES;
    self.pxNames = @[
                     @"Unk",
                     @"Imm",
                     @"Nea",
                     @"Far"
                     ];
    self.asNames = @[
                     @"Active",
                     @"Inacti",
                     @"Backgr"
                     ];
    self.rsNames = @[
                     @"Unknow",
                     @"Inside",
                     @"Outsid"
                     ];
    
    
	// Do any additional setup after loading the view, typically from a nib.
    for (int i = 0 ; i < self.homebgs.count ; i++) {
        UIImageView* homebg = self.homebgs[i];
        homebg.alpha = (i == 0) ? 1 : 0;
    }
    self.control.alpha = 0;
    self.beaconList.alpha = 0;
    
    
    self.beaconListArrow.backgroundColor = [UIColor clearColor];
    CGRect arrowbound = self.beaconListArrow.bounds;
    CAShapeLayer* arrowlayer = [CAShapeLayer layer];
    arrowlayer.bounds = self.beaconListArrow.bounds;
    arrowlayer.fillColor = self.beaconList.backgroundColor.CGColor;
    arrowlayer.position = CGPointMake(CGRectGetMidX(arrowbound), CGRectGetMidY(arrowbound));
    UIBezierPath* arrowpath = [UIBezierPath bezierPath];
    [arrowpath moveToPoint:CGPointMake(CGRectGetMinX(arrowbound), CGRectGetMinY(arrowbound))];
    [arrowpath addLineToPoint:CGPointMake(CGRectGetMaxX(arrowbound), CGRectGetMinY(arrowbound))];
    [arrowpath addLineToPoint:CGPointMake(CGRectGetMidX(arrowbound), CGRectGetMaxY(arrowbound))];
    arrowlayer.path = arrowpath.CGPath;
    [self.beaconListArrow.layer addSublayer:arrowlayer];
    
    self.gotoLocateBtn.backgroundColor = createColorWithRGBHex(0xf8363c);
    self.gotoActiveBtn.backgroundColor = createColorWithRGBHex(0xf8363c);
    self.backMainBtn1.backgroundColor = createColorWithRGBHex(0xf8363c);
    self.controlBackMainBtn.backgroundColor = createColorWithRGBHex(0xf8363c);
    ViewController* contvc = (id)self;
    UIViewController* newvc = [contvc.storyboard instantiateViewControllerWithIdentifier:@"BroadcastViewController"];
    self.broadcastViewController = (id)newvc;
    [contvc addChildViewController:newvc];
    [contvc.broadcastContentView addSubview:newvc.view];

    
    
    self.stat = @"landing";
    newvc.view.alpha = 0;
    self.broadcastContentView.userInteractionEnabled=NO;
    self.gotoActiveBtn.alpha = 1;
    self.gotoLocateBtn.alpha = 1;
    self.backMainBtn1.alpha = 0;
    self.locatingLbl.alpha = 0;
    UIView* homebg = self.homebgs[0];
    homebg.alpha = 1;
    
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
        //Device is ipad
    }else{
        //Device is iphone
    }
    [self syncBeacons:@{@"file":@"data", @"fileType":@"json"}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -
- (void) syncBeacons:(id)data {
    if(self.syncBeaconsStat != 0 && self.syncBeaconsStat != 100 && self.beaconsDirty) return;
    
    if(!self.pfApp && !self.queryingPFApp) {
        self.queryingPFApp = YES;
        PFQuery* query2 = [PFQuery queryWithClassName:@"App"];
        [query2 selectKeys:@[@"dataUpdatedAt"]];
        [query2 findObjectsInBackgroundWithBlock:^(NSArray* objects, NSError* error) {
            if(!error){
                self.pfApp = objects[0];
                self.dataUpdatedAt = self.pfApp[@"dataUpdatedAt"];
            }
            self.queryingPFApp = NO;
        }];
    }
    
    
    if(!self.beaconManager) {
        self.beaconManager = [[ESTBeaconManager alloc] init];
        self.beaconManager.delegate = self;
        self.beaconManager.avoidUnknownStateBeacons = NO;
    }
    self.beaconManager.delegate = nil;
    //TO DO
    //add lastTime, timeout, isUserInit to consider skip initBeacon
    
    NSString* file = data[@"file"];
    NSString* fileType = data[@"fileType"];
    BOOL isUserInit = [data[@"isUserInit"] boolValue];
    
    self.syncBeaconsStat = 1;
    PFQuery* query = [PFQuery queryWithClassName:@"Beacon"];
    [query includeKey:@"item"];
    [query includeKey:@"item.notifications"];
    [query includeKey:@"staff"];
    [query includeKey:@"staff.notifications"];
    [query whereKey:@"deleted" equalTo:@NO];
    [query findObjectsInBackgroundWithBlock:^(NSArray* objects, NSError* error) {
        self.syncBeaconsStat = 2;
        if(error){
        //if(YES){
            if(self.syncBeaconsCnt == 0) {
                NSString* jfile = [[NSBundle mainBundle] pathForResource:file ofType:fileType];
                NSData* jdata = [NSData dataWithContentsOfFile:jfile];
                if(jdata) {
                    NSDictionary* json = [NSJSONSerialization
                                          JSONObjectWithData:jdata
                                          options:kNilOptions
                                          error:nil];
                    [self onBeaconsLoaded:@{@"beacons":jsonToPFBeacons(json[@"results"], NO)} option:data];
                }
            }else if(self.syncBeaconsCnt > 0 && isUserInit){
                NSUserDefaults* ud = NSUserDefaults.standardUserDefaults;
                if([ud boolForKey:(INIT_BEACON_FAILED_ALERT_VIEW_DONT_SHOW_AGAIN)]) {
                    [[UIAlertView showWithTitle:@"Unable to update"
                                        message:@"Please make sure internet connection is on and try again."
                              cancelButtonTitle:@"Close"
                              otherButtonTitles:@[@"Don't Show Again"]
                                       tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                           if (buttonIndex == 1) {
                                               [ud setBool:YES forKey:(INIT_BEACON_FAILED_ALERT_VIEW_DONT_SHOW_AGAIN)];
                                           }
                                       }] show];
                }
            }
        }else{
            [self onBeaconsLoaded:@{@"beacons":objects} option:data];
        }
        self.syncBeaconsCnt++;
        self.syncBeaconLastTime = [NSDate date];
    }];
}


- (void) addBeacon:(Beacon*) b {
    if(!b)return;
    if(!b.bitem)return;
    
    [self.beacons addObject:b];
    
#ifdef DEBUG_OBSERVING_CRASH
    NSLog(@"addBeacon@(%@,%@,%@,%@)", b.proximityUUID, b.major, b.minor, b.name);
#endif
    /*
    [b addObserver:self
        forKeyPath:@"avgProximity"
           options:(NSKeyValueObservingOptionNew |
                    NSKeyValueObservingOptionOld)
           context:(void*)b];
    [b addObserver:self
        forKeyPath:@"inRange"
           options:(NSKeyValueObservingOptionNew |
                    NSKeyValueObservingOptionOld)
           context:(void*)b];
    //*/
    b.beaconDelegate = self;
    
    ESTBeaconRegion* region;
    //region = b.monitorRegion = createRegionWithMajorAndMinor(b, b.objectId);
    region = b.monitorRegion = createRegion(b, b.objectId);
    if(self.monitorRegions.count == 0) {
        [self.beaconManager startMonitoringForRegion:region];
    }
    [self.monitorRegions addObject:region];

    
    region = b.rangeRegion = createRegion(b, b.objectId);
    if(self.rangeRegions.count == 0) {
        [self.beaconManager startRangingBeaconsInRegion:region];
    }
    [self.rangeRegions addObject:region];
}

- (void) removeBeacon:(Beacon*) b {
    if(!b)return;
    if(!b.bitem)return;
    if(![self.beacons containsObject:b])return;
    
#ifdef DEBUG_OBSERVING_CRASH
    NSLog(@"removeBeacon@(%@,%@,%@,%@)", b.proximityUUID, b.major, b.minor, b.name);
#endif
    /*
    [b removeObserver:self forKeyPath:@"avgProximity" context:(void*)b];
    [b removeObserver:self forKeyPath:@"inRange" context:(void*)b];
    //*/
    b.beaconDelegate = nil;
    
    
    ESTBeaconRegion* region;
    
    region = b.monitorRegion;
    if(self.monitorRegions.count == 1){
        [self.beaconManager stopMonitoringForRegion:region];
    }
    [self.monitorRegions removeObject:b.monitorRegion];
    
    region = b.rangeRegion;
    if(self.rangeRegions.count == 1) {
        [self.beaconManager stopRangingBeaconsInRegion:region];
    }
    [self.rangeRegions removeObject:region];
    
    [self.beacons removeObject:b];
}

- (void) onBeaconsLoaded:(NSDictionary*)data option:(id)option {
    NSLog(@"onBeaconsLoaded");
    [self destroyBeacons:nil];
    
    NSArray* beacons = data[@"beacons"];
    for (int i = 0 ; i < beacons.count ; i++) {
        id beacon = beacons[i];
        Beacon* b = createBeaconWithData(beacon);
        [self addBeacon:b];
    }
    self.beaconManager.delegate = self;
    for (UIViewController* child in self.childViewControllers) {
        if([child respondsToSelector:@selector(reload)]){
            //[child performSelector:@selector(reload)];
        }
    }
}

- (void) destroyBeacons:(id)data {
    [self.beaconManager stopAdvertising];
    NSArray* tempbeacons = [self.beacons copy];
    for (Beacon* tb in tempbeacons) {
        [self removeBeacon:tb];
    }
    
    self.nearestBeaconSamples = [@[]mutableCopy];
    self.beacons = [@[] mutableCopy];
    self.monitorRegions = [@[] mutableCopy];
    self.rangeRegions = [@[] mutableCopy];
    
    //_avgNearestBeacon = nil;
}

//#define DEBUG_OBSERVING_VALUE

-(void)valueChangedForKeyPath:(NSString*)keyPath ofObjects:(id)object changeFrom:(id)oldval to:(id)newval delegate:(id)d {
    int pxdUnknown = getPxDist(CLProximityUnknown);
    if([keyPath isEqualToString:@"avgProximity"]) {
        Beacon* b = object;
        
        int npxd = getPxDist([newval intValue]);
        int opxd = getPxDist([oldval intValue]);
        if(npxd == opxd) return;
#ifdef DEBUG_OBSERVING_VALUE
        NSLog(@"%@{%@}.avgpx changed from %d to %d", b.name, b.minor, opxd, npxd);
#endif
        if(b.bitem) {
            if(npxd >= pxdUnknown && opxd < pxdUnknown) {
                b.inRange = NO;
                int farcnt = 0;
                for (Beacon* b in self.beacons) {
                    if(getPxDist(b.avgProximity) >= pxdUnknown) farcnt++;
                }
                if(farcnt == self.beacons.count) {
                    [self onAllOutRange:nil];
                }
            }else if(npxd < pxdUnknown && opxd >= pxdUnknown) {
                b.inRange = YES;
            }
        }
    }else if([keyPath isEqualToString:@"inRange"]) {
        Beacon* b = object;
        int nir = [newval boolValue];
        int oir = [oldval boolValue];
        if(nir == oir) return;
        if(b.bitem) {
#ifdef DEBUG_OBSERVING_VALUE
            NSLog(@"%@{%@} range %@", b.name, b.minor, nir?@"in":@"out");
#endif
            if(nir) {
                b.lastInRangeTime = [[NSDate date] timeIntervalSince1970];
            }
            if(nir)
                [self onInRange:@{@"beacon":b}];
            else
                [self onOutRange:@{@"beacon":b}];
        }
    }
}


-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context {
    //NSLog(@"observeValueForKeyPath %@", keyPath);
    //double now = CACurrentMediaTime();
    int pxdUnknown = getPxDist(CLProximityUnknown);
    //int pxdFar = getPxDist(CLProximityFar);
    //int pxdNear = getPxDist(CLProximityNear);
    //int pxdImm = getPxDist(CLProximityImmediate);
    
    if([keyPath isEqualToString:@"avgProximity"]) {
        Beacon* b = object;
        
        int npxd = getPxDist([change[NSKeyValueChangeNewKey] intValue]);
        int opxd = getPxDist([change[NSKeyValueChangeOldKey] intValue]);
        if(npxd == opxd) return;
#ifdef DEBUG_OBSERVING_VALUE
        NSLog(@"%@{%@}.avgpx changed from %d to %d", b.name, b.minor, opxd, npxd);
#endif
        if(b.bitem) {
            if(npxd >= pxdUnknown && opxd < pxdUnknown) {
                b.inRange = NO;
                int farcnt = 0;
                for (Beacon* b in self.beacons) {
                    if(getPxDist(b.avgProximity) >= pxdUnknown) farcnt++;
                }
                if(farcnt == self.beacons.count) {
                    [self onAllOutRange:nil];
                }
            }else if(npxd < pxdUnknown && opxd >= pxdUnknown) {
                b.inRange = YES;
            }
        }
    }else if([keyPath isEqualToString:@"inRange"]) {
        Beacon* b = object;
        int nir = [change[NSKeyValueChangeNewKey] boolValue];
        int oir = [change[NSKeyValueChangeOldKey] boolValue];
        if(nir == oir) return;
        if(b.bitem) {
#ifdef DEBUG_OBSERVING_VALUE
            NSLog(@"%@{%@} range %@", b.name, b.minor, nir?@"in":@"out");
#endif
            if(nir)
                [self onInRange:@{@"beacon":b}];
            else
                [self onOutRange:@{@"beacon":b}];
        }
    }else if([keyPath isEqualToString:@"avgNearestBeacon"]) {
        /*
        BeaconState* nv = change[NSKeyValueChangeNewKey];
        BeaconState* ov = change[NSKeyValueChangeOldKey];
        if(!isNull(nv) && ![nv isEqual:ov]) {
            if(getPxDist(nv.proximity) <= pxdNear) {
                //Beacon* b = [self findBeacon:nv];
                //if(b){
                //[self displayItem:b.item data2:b.itemImg1 option:nil];
                //NSLog(@"avgNearestBeacon changed to %@", b.name);
                //}
            }
        }//*/
    }
}


- (void) onAllOutRange:(id)data {
    if([self.stat isEqualToString:@"content"]) {
        self.stat = @"locating";
        ViewController* contvc = (id)self;
        
        
        UIViewController* oldvc = contvc.childViewControllers.count>1?contvc.childViewControllers[1]:nil;
        
        [UIView animateWithDuration:0.2 animations:^{
            for (UIView* homebg in self.homebgs) {
                homebg.alpha = 1;
                break;
            }
            self.homelogo.alpha = 1;
            oldvc.view.alpha = 0;
            self.control.alpha = 0;
            self.beaconList.alpha = 0;
            
            self.backMainBtn1.alpha = 1;
            self.locatingLbl.alpha = 1;
            
        } completion:^(BOOL finished){
            [oldvc removeFromParentViewController];
            [oldvc.view removeFromSuperview];
        }];
    }
}

- (void) onInRange:(id)data{
    
    
    NSArray* identifiers = @[@"BeaconWebViewController", @"StaffWebViewController"];
    NSString* identifier;
    Beacon* b = toObj(data[@"beacon"]);
    id bitem = b.bitem;
    identifier = b.item ? identifiers[0] : identifiers[1];
    if(([self.stat isEqualToString:@"content"] || [self.stat isEqualToString:@"locating"]) && self.syncBeaconsStat == 100) {
        self.stat = @"content";
        if(self.contentView.subviews.count == 0) {
            
            ViewController* contvc = (id)self;
            
            UIViewController* oldvc = contvc.childViewControllers.count>1?contvc.childViewControllers[1]:nil;
            [oldvc removeFromParentViewController];
            [oldvc.view removeFromSuperview];
            
            UIViewController* newvc = [contvc.storyboard instantiateViewControllerWithIdentifier:identifier];
            [newvc performSelector:@selector(setUrlstr:) withObject:bitem[@"url"]];
            [contvc addChildViewController:newvc];
            [contvc.contentView addSubview:newvc.view];
            newvc.view.alpha = 0;
            
            [UIView animateWithDuration:0.4 animations:^{
                for (UIView* homebg in self.homebgs) {
                    homebg.alpha = 0;
                }
                self.homelogo.alpha = 0;
                self.gotoLocateBtn.alpha = 0;
                self.gotoActiveBtn.alpha = 0;
                
                self.backMainBtn1.alpha = 0;
                self.locatingLbl.alpha = 0;
                
                self.control.alpha = 1.0;
                newvc.view.alpha = 1;
            }];
        }
    }
    
    
    double now = [[NSDate date] timeIntervalSince1970];
    id reenterNF = findNotification(b.bitem, @"reenter");
    id enterNF = findNotification(b.bitem, @"enter");
    if(reenterNF) {
        if(b.lastInRangeTime != 0 || now - b.lastInRangeTime < [reenterNF[@"within"] doubleValue]) {
            [self fireNotification:reenterNF];
        }else if(enterNF) {
            [self fireNotification:enterNF];
        }
    }else if(enterNF) {
        [self fireNotification:enterNF];
    }
    [self relayoutBeaconList];
}

- (void) onOutRange:(id)data{
    Beacon* b = toObj(data[@"beacon"]);
    id exitNF = findNotification(b.bitem, @"exit");
    [self fireNotification:exitNF];
    [self relayoutBeaconList];
}

- (void) relayoutBeaconList {
    for (DataButton* btn in self.beaconListScrollView.subviews) {
        [btn removeFromSuperview];
    }
    int m = 0;
    int inrangecnt = 0;
    for(Beacon* b in self.beacons){
        if(b.inRange){
            DataButton* beaconListBtn = [self createBeaconListBtn:b m:m++];
            [self.beaconListScrollView addSubview:beaconListBtn];
            self.beaconListScrollView.contentSize = CGSizeMake(self.beaconListScrollView.bounds.size.width, CGRectGetMaxY(beaconListBtn.frame) + 5);
            inrangecnt++;
        }
    }
    self.broadcastStatNumLbl.text = [NSString stringWithFormat:@"%d", inrangecnt];
}

- (void) fireNotification:(id)data{
    if(isNull(data)) {
        return;
    }
    UIApplicationState as = [UIApplication sharedApplication].applicationState;
    if(as != UIApplicationStateBackground) {
        //NSLog(@"fireNotification@ignore, is not Background(%@)", self.asNames[as]);
        return;
    }
    if(!data){
        //NSLog(@"fireNotification@ignore, sender=nil");
        return;
    }
    if(![data[@"enabled"] boolValue]){
        //NSLog(@"fireNotification@ignore, enabled=true");
        return;
    }
    double now = CACurrentMediaTime();
    NSString* oid = getObjectId(data);
    NSMutableDictionary* nf = self.notificationFires[oid];
    if(!nf) self.notificationFires[oid] = nf = [@{} mutableCopy];
    double lastTime = [nf[@"lastTime"] doubleValue];
    double timeout = [data[@"timeout"] doubleValue];
    if(lastTime == 0 || now - lastTime >= timeout) {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.alertBody = data[@"txt"];
        notification.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        nf[@"lastTime"] = @(CACurrentMediaTime());
    }else{
        NSLog(@"fireNotification@ignore, timeout");
    }
}

- (BOOL) presentingContentViewController {
    if(self.childViewControllers.count < 1) return NO;
    else return YES;
}

#pragma mark - <ESTBeaconManagerDelegate>
-(void)beaconManager:(ESTBeaconManager *)manager
monitoringDidFailForRegion:(ESTBeaconRegion *)region
           withError:(NSError *)error {
    NSLog(@"monitoringDidFailForRegion@region=%@, error=%@", region, error);
}

-(void)beaconManager:(ESTBeaconManager *)manager
rangingBeaconsDidFailForRegion:(ESTBeaconRegion *)region
           withError:(NSError *)error {
    NSLog(@"rangingBeaconsDidFailForRegion@region=%@, error=%@", region, error);
}

-(void)beaconManager:(ESTBeaconManager *)manager
   didDetermineState:(CLRegionState)state
           forRegion:(ESTBeaconRegion *)region
{
    //UIApplicationState as = [UIApplication sharedApplication].applicationState;
    NSArray* bs = [self findBeacons:region];
    //NSLog(@"didDetermineState@as=%@, state=%@, uuid=%@ mj=%@ mn=%@", self.asNames[as], self.rsNames[state], region.proximityUUID, region.major, region.minor);
    for (Beacon* b in bs) {
        b.inRange = state == CLRegionStateInside;
    }
}

-(void)beaconManager:(ESTBeaconManager *)manager
      didEnterRegion:(ESTBeaconRegion *)region
{
    UIApplicationState as = [UIApplication sharedApplication].applicationState;
    NSLog(@"didEnterRegion@as=%@", self.asNames[as]);
}

-(void)beaconManager:(ESTBeaconManager *)manager
       didExitRegion:(ESTBeaconRegion *)region
{
    UIApplicationState as = [UIApplication sharedApplication].applicationState;
    NSLog(@"didExitRegion@as=%@", self.asNames[as]);
}

-(void)beaconManager:(ESTBeaconManager *)manager
     didRangeBeacons:(NSArray *)beacons
            inRegion:(ESTBeaconRegion *)region {
    ///////////////////
    
    double now = CACurrentMediaTime();
    
    
    if(beacons.count > 0) {
        for (ESTBeacon* eb in beacons) {
            Beacon* b = [self findBeacon:eb type:@"item"];
            if(b) {
                [self addNearestBeaconSample:eb t:now];
                break;
            }
        }
    }//*/
    
    
    
    for (Beacon* b in self.beacons) {
        BOOL cotinueOuter = NO;
        for (ESTBeacon* eb in beacons) {
            if([b isEqual:eb]) {
                [b addSample:eb t:now];
                [b set:eb t:now];
                cotinueOuter = YES;
                
                break;
            }
        }
        if(cotinueOuter) continue;
        
        BeaconState* bs = [[BeaconState alloc] init];
        [bs set:b t:now];
        bs.proximity = CLProximityUnknown;
        bs.distance = @(-1.0);
        
        [b addSample:bs t:now];
        [b set:bs t:now];
    }
#ifdef DEBUG_DID_RANGE
    NSString* msg = @"";
    NSString* msg2 = @"";
    NSString* bmsg = @"";
    for(int i = 0 ; i < beacons.count ; i++){
        ESTBeacon* eb = beacons[i];
        Beacon* b = [self findBeacon:eb];
        if(b){
            bmsg = [NSString stringWithFormat:@"{{%@}, d:%.2f, px:%@(%@)(%.2f)},", eb.minor, [eb.distance floatValue], self.pxNames[eb.proximity], self.pxNames[b.avgProximity], b.nearestWeight];
            msg = [NSString stringWithFormat:@"%@ %@", msg, bmsg];
        }else{
            bmsg = [NSString stringWithFormat:@"{{%@}, d:%.2f, px:%@},", eb.minor, [eb.distance floatValue], self.pxNames[eb.proximity]];
            msg = [NSString stringWithFormat:@"%@ %@", msg, bmsg];
        }
    }
    for (Beacon* b in self.beacons) {
        bmsg = [NSString stringWithFormat:@"{{%@,%@,%@}, d:%.2f, px:%@(%@)(%.2f)},", b.name, b.major, b.minor, [b.distance floatValue], self.pxNames[b.proximity], self.pxNames[b.avgProximity], b.nearestWeight];
        msg2 = [NSString stringWithFormat:@"%@%@\n", msg2, bmsg];
    }
    
    
    NSLog(@"@(%lu,%lu) %@", (unsigned long)beacons.count, (unsigned long)self.beacons.count, msg);
#endif
}

- (void) addNearestBeaconSample:(id) b t:(double)t{
    if(!b)return;
    
    id scfs = @[
                @{@"d":@3, @"w":@0.8},
                @{@"d":@3, @"w":@0.8}
                ];
    id scf = scfs[0];
    
    
    BeaconState* bs = [[BeaconState alloc] init];
    [bs set:b t:t];
    [self.nearestBeaconSamples addObject:bs];
    
    float total = 0;
    float sum = 0;
    BeaconState* fbs = [self.nearestBeaconSamples firstObject];
    BeaconState* lbs = [self.nearestBeaconSamples lastObject];
    
    if(lbs.t - fbs.t <= [scfs[1][@"d"] doubleValue]) {
        scf = scfs[1];
        if(self.syncBeaconsStat < 10) {
            self.syncBeaconsStat = 10;
        }
    }else{
        if(self.syncBeaconsStat <= 10) {
            self.syncBeaconsStat = 100;
            self.beaconsDirty = NO;
            self.dataUpdatedAt = self.pfApp[@"dataUpdatedAt"];
            
            Beacon* nearestBeaconInRange = [self findNearestBeaconInRange];
            if(nearestBeaconInRange && [self.stat isEqualToString:@"locating"]) {
                self.stat = @"content";
                [UIView animateWithDuration:0.2 animations:^{
                    self.gotoActiveBtn.alpha = 0;
                    self.gotoLocateBtn.alpha = 0;
                    self.locatingLbl.alpha = 0;
                    self.backMainBtn1.alpha = 0;
                }];
                [self onInRange:@{@"beacon":nearestBeaconInRange}];
            }
        }
    }
    for (int i = 0 ; i < self.beacons.count ; i++) {
        Beacon* b = self.beacons[i];
        sum = total = 0;
        for (int i = 0 ; i < self.nearestBeaconSamples.count ; i++) {
            BeaconState* ibs = self.nearestBeaconSamples[i];
            if(lbs.t - ibs.t <= [scf[@"d"] doubleValue]) {
                if([ibs isEqual:b]) {
                    sum++;
                }
                total++;
            }
        }
        if(total == 0) b.nearestWeight = 0;
        else b.nearestWeight = sum / total;
    }
    
    if(lbs.t - fbs.t <= [scf[@"d"] doubleValue]) {
        if(self.avgNearestBeacon != nil)
            self.avgNearestBeacon = nil;
    }else{
        
        Beacon* nb = nil;
        float maxnw = -1;
        for (int i = 0 ; i < self.beacons.count ; i++) {
            Beacon* b = self.beacons[i];
            if(b.nearestWeight > maxnw && b.nearestWeight > [scf[@"w"] doubleValue]) {
                maxnw = b.nearestWeight;
                nb = b;
            }
        }
        if(nb) {
            //NSLog(@"lbs.t(%f) - fbs.t(%f) <= d(%f)", lbs.t, fbs.t, [scf[@"d"] doubleValue]);
            self.avgNearestBeacon = nb;
        }//*/
        
    }
}


#pragma mark - UIAction
- (IBAction)gotoLocateBtnTouchUpInside:(id)sender {
    //NSLog(@"syncBeaconsStat=%d", self.syncBeaconsStat);
    if([self.stat isEqualToString:@"landing"]) {
        self.stat = @"locating";
        if(self.syncBeaconsStat != 100) {
            [UIView animateWithDuration:0.2 animations:^{
                self.gotoActiveBtn.alpha = 0;
                self.gotoLocateBtn.alpha = 0;
                self.locatingLbl.alpha = 1;
                self.backMainBtn1.alpha = 1;
            }];
        }else{
            Beacon* nearestBeaconInRange = [self findNearestBeaconInRange];
            if(nearestBeaconInRange) {
                [UIView animateWithDuration:0.2 animations:^{
                    self.gotoActiveBtn.alpha = 0;
                    self.gotoLocateBtn.alpha = 0;
                    self.locatingLbl.alpha = 0;
                    self.backMainBtn1.alpha = 0;
                } completion:^(BOOL finished){
                    [self onInRange:@{@"beacon":nearestBeaconInRange}];
                }];
            }
        }
        
    }
}

- (IBAction)gotoActiveBtnTouchUpInside:(id)sender {
    if([self.stat isEqualToString:@"landing"]) {
        self.stat = @"active";
        UIView* view = self.broadcastContentView.subviews[0];
        self.broadcastContentView.userInteractionEnabled=YES;
        [UIView animateWithDuration:0.2 animations:^{
            view.alpha = 1;
            self.gotoActiveBtn.alpha = 0;
            self.gotoLocateBtn.alpha = 0;
            self.locatingLbl.alpha = 0;
            self.backMainBtn1.alpha = 0;
        } completion:^(BOOL finished){
            [self.broadcastViewController showAlert];
        }];
        
        
        
    }
}


- (IBAction)controlTapHandle:(id)sender {
    [UIView animateWithDuration:0.2 delay:0.0 options:0 animations:^{
        self.beaconList.alpha = self.beaconList.alpha == 0 ? 1 : 0;
    } completion:nil];
}


- (IBAction)testTapHandle:(id)sender {
}


- (IBAction)beaconListBtnTouchUpInside:(id)sender {
    DataButton* btn = sender;
    
    NSArray* identifiers = @[@"BeaconWebViewController", @"StaffWebViewController"];
    NSString* identifier;
    Beacon* b = toObj(btn.data[@"beacon"]);
    id bitem = b.bitem;
    identifier = !isNull(b.item) ? identifiers[0] : identifiers[1];
    
    ViewController* contvc = (id)self;
    UIViewController* oldvc = contvc.childViewControllers.count>1?contvc.childViewControllers[1]:nil;
    
    UIViewController* newvc = [contvc.storyboard instantiateViewControllerWithIdentifier:identifier];

    [newvc performSelector:@selector(setUrlstr:) withObject:bitem[@"url"]];
    
    [contvc addChildViewController:newvc];
    [contvc.contentView addSubview:newvc.view];
    newvc.view.alpha = 0;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.beaconList.alpha = 0;
    }];
    [UIView animateWithDuration:0.2 animations:^{
        newvc.view.alpha = 1;
    } completion:^(BOOL finished){
        [oldvc removeFromParentViewController];
        [oldvc.view removeFromSuperview];
    }];
    
}
- (IBAction)backMainBtnTouchUpInside:(id)sender {
    self.stat = @"landing";
    
    ViewController* contvc = (id)self;
    UIViewController* oldvc = contvc.childViewControllers.count>1?contvc.childViewControllers[1]:nil;
    [UIView animateWithDuration:0.2 animations:^{
        self.beaconList.alpha = 0;
        self.control.alpha = 0;
        oldvc.view.alpha = 0;
        
        self.backMainBtn1.alpha = 0;
        self.locatingLbl.alpha = 0;
        
        self.gotoLocateBtn.alpha = 1;
        self.gotoActiveBtn.alpha = 1;
        
        UIView* homebg = self.homebgs[0];
        homebg.alpha = 1;
        self.homelogo.alpha = 1;
    } completion:^(BOOL finished){
        [oldvc removeFromParentViewController];
        [oldvc.view removeFromSuperview];
    }];
}

- (IBAction)controlBackMainBtnTouchUpInside:(id)sender {
    self.stat = @"landing";
    
    ViewController* contvc = (id)self;
    UIViewController* oldvc = contvc.childViewControllers.count>1?contvc.childViewControllers[1]:nil;
    [UIView animateWithDuration:0.2 animations:^{
        self.beaconList.alpha = 0;
        self.control.alpha = 0;
        oldvc.view.alpha = 0;
        
        self.backMainBtn1.alpha = 0;
        self.locatingLbl.alpha = 0;
        
        self.gotoLocateBtn.alpha = 1;
        self.gotoActiveBtn.alpha = 1;
        
        UIView* homebg = self.homebgs[0];
        homebg.alpha = 1;
        self.homelogo.alpha = 1;
    } completion:^(BOOL finished){
        [oldvc removeFromParentViewController];
        [oldvc.view removeFromSuperview];
    }];
}
@end
