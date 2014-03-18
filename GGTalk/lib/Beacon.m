//
//  ABeacon.m
//  NotificationDemo
//
//  Created by lee yee chuan on 2/20/14.
//  Copyright (c) 2014 Estimote. All rights reserved.
//

#import "Beacon.h"

@implementation BeaconState
- (void) set:(id)eb t:(double)t {
    //Beacon* b = eb;
    //BeaconState* bs = eb;
    if([eb respondsToSelector:@selector(name)]) {
        self.name = [eb name];
    }
    self.proximityUUID = [eb proximityUUID];
    self.major = [eb major];
    self.minor = [eb minor];
    self.proximity = [eb proximity];
    self.rssi = [eb rssi];
    self.distance = [eb distance];
    self.t = t;
}
- (BOOL) isEqual:(id)r {
    if(r == nil || r == NULL || [[NSNull null] isEqual:r]) return NO;
    /*
    if(![r respondsToSelector:@selector(proximityUUID)] ||
       ![r respondsToSelector:@selector(major)] ||
       ![r respondsToSelector:@selector(minor)])return NO;//*/
    return [self.proximityUUID isEqual:[r proximityUUID]] &&
    [self.major isEqual:[r major]] &&
    [self.minor isEqual:[r minor]];
}
@end

@implementation Beacon
@synthesize avgProximity;
@synthesize inRange;

- (void) setAvgProximity:(CLProximity)ap {
    CLProximity oldval = avgProximity;
    CLProximity newval = ap;
    avgProximity = newval;
    if([self.beaconDelegate respondsToSelector:@selector(valueChangedForKeyPath:ofObjects:changeFrom:to:delegate:)]) {
        [self.beaconDelegate valueChangedForKeyPath:@"avgProximity" ofObjects:self changeFrom:@(oldval) to:@(newval) delegate:self.beaconDelegate];
    }
}
- (void) setInRange:(BOOL)ir {
    BOOL oldval = inRange;
    BOOL newval = ir;
    inRange = newval;
    if([self.beaconDelegate respondsToSelector:@selector(valueChangedForKeyPath:ofObjects:changeFrom:to:delegate:)]) {
        [self.beaconDelegate valueChangedForKeyPath:@"inRange" ofObjects:self changeFrom:@(oldval) to:@(newval) delegate:self.beaconDelegate];
    }
}


- (id)init{
    self=[super init];
    if(self){
        _data=[@{} mutableCopy];
        _samples=[@[] mutableCopy];
    }
    return self;
}
- (BOOL) isEqual:(id)r {
    if(r == nil || r == NULL || [[NSNull null] isEqual:r]) return NO;
    /*
    if(![r respondsToSelector:@selector(proximityUUID)] ||
       ![r respondsToSelector:@selector(major)] ||
       ![r respondsToSelector:@selector(minor)])return NO;//*/
    return [self.proximityUUID isEqual:[r proximityUUID]] &&
    [self.major isEqual:[r major]] &&
    [self.minor isEqual:[r minor]];
}
- (void) set:(id)eb t:(double)t{
    if(!eb)return;
    self.proximityUUID = [eb proximityUUID];
    self.major = [eb major];
    self.minor = [eb minor];
    self.proximity = [eb proximity];
    self.rssi = [eb rssi];
    self.distance = [eb distance];
    self.t = t;
}

-(NSString*) type { return self.data[@"type"]; }
-(NSString*) objectId { return getObjectId(self.data); }
-(NSString*) name { return self.data[@"name"]; }
-(BOOL) displayEnabled { return [self.data[@"displayEnabled"] boolValue]; }
-(id) item {
    if(isNull(self.data[@"item"]))return nil;
    return self.data[@"item"];
}
-(id) staff {
    if(isNull(self.data[@"staff"]))return nil;
    return self.data[@"staff"];
}
-(id) bitem {
    if(!isNull(self.item)) return self.item;
    if(!isNull(self.staff)) return self.staff;
    return nil;
}
-(BOOL) notificationEnabled { return [self.data[@"notificationEnabled"] boolValue]; }
-(NSArray*) notifications { return self.data[@"notifications"]; }
- (id) getNotification:(NSString*) type {
    for (id notification in self.notifications) {
        if([notification[@"type"] isEqual:type])
            return notification;
    }
    return nil;
}

int pxtotals[4];
- (void) addSample:(id) eb t:(double)t{
    BeaconState* bs = [[BeaconState alloc] init];
    if(eb) {
        [bs set:eb t:t];
    }else{
        [bs set:self t:t];
        bs.proximity = CLProximityUnknown;
        bs.distance = @(-1.0);
    }

    [self.samples addObject:bs];
    if(self.samples.count > 100) [self.samples removeObjectAtIndex:0];
    
    double now = CACurrentMediaTime();
    float total = 0;
    //////////// average proximity
    id scfs = @[
                @{@"d":@3, @"w":@0.8},
                @{@"d":@3, @"w":@0.8}
                ];
    id scf = scfs[0];
    
    
    for (int i = 0 ; i < 4 ; i++) {
        pxtotals[i] = 0;
    }
    
    BeaconState* fbs = [self.samples firstObject];
    BeaconState* lbs = [self.samples lastObject];
    if(lbs.t - fbs.t <= [scfs[1][@"d"] doubleValue]) {
        scf = scfs[1];
    }
    if(lbs.t - fbs.t < [scf[@"d"] doubleValue]) {
        if(self.avgProximity != CLProximityUnknown)
            self.avgProximity = CLProximityUnknown;
    }else{
        for (int i = 0 ; i < self.samples.count ; i++) {
            BeaconState* bs = self.samples[i];
            if(now - bs.t <= [scf[@"d"] doubleValue]) {
                pxtotals[bs.proximity]++;
                total++;
            }
        }
        if(total > 0) {
            int px = -1;
            for (int i = 0 ; i < 4 ; i++) {
                if((px == -1 || pxtotals[i] > pxtotals[px]) && pxtotals[i]/total > [scf[@"w"] doubleValue]) px = i;
            }
            if(px != -1){
                self.avgProximity = px;
            }
        }
    }
    
    
}

Beacon* createBeacon() {
    Beacon* b = [[Beacon alloc] init];
    return b;
}
Beacon* createBeaconWithData(id data) {
    Beacon* b = [[Beacon alloc] init];    
    b.data = data;
    b.proximityUUID = [[NSUUID alloc] initWithUUIDString:data[@"proximityUUID"]];
    b.major = data[@"major"];
    b.minor = data[@"minor"];
    return b;
}
ESTBeaconRegion* createRegionWithMajorAndMinor(Beacon* b, NSString* identifier) {
    ESTBeaconRegion* region = [[ESTBeaconRegion alloc] initWithProximityUUID:b.proximityUUID
                                                                       major:[b.major unsignedShortValue]
                                                                       minor:[b.minor unsignedShortValue]
                                                                  identifier: identifier];
    NSLog(@"region=%@", region);
    region.notifyEntryStateOnDisplay = YES;
    region.notifyOnEntry = YES;
    region.notifyOnExit = YES;
    return region;
}
ESTBeaconRegion* createRegion(Beacon* b, NSString* identifier){
    ESTBeaconRegion* region = [[ESTBeaconRegion alloc] initWithProximityUUID:b.proximityUUID
                                                                  identifier:identifier];
    region.notifyEntryStateOnDisplay = YES;
    region.notifyOnEntry = YES;
    region.notifyOnExit = YES;
    return region;
}
int getPxDist(CLProximity px) {
    if(px == CLProximityUnknown) return 3;
    if(px == CLProximityImmediate) return 0;
    if(px == CLProximityNear) return 1;
    if(px == CLProximityFar) return 2;
    return 4;
}

@end
