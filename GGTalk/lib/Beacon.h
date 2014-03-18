//
//  ABeacon.h
//  NotificationDemo
//
//  Created by lee yee chuan on 2/20/14.
//  Copyright (c) 2014 Estimote. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESTBeacon.h"
#import "ESTBeaconRegion.h"
#import <Parse/Parse.h>
#import "Util.h"

@protocol BeaconDelegate <NSObject>

-(void)valueChangedForKeyPath:(NSString*)keyPath ofObjects:(id)object changeFrom:(id)oldval to:(id)newval delegate:(id)d;

@end



@class Beacon;

@interface BeaconState : ESTBeacon
@property (nonatomic) NSString* name;
@property (nonatomic) double t;
- (BOOL) isEqual:(id)r;
- (void) set:(id)eb t:(double)t;
@end

@interface Beacon : ESTBeacon
@property (nonatomic, readonly) NSString* objectId;
@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) NSString* type;
@property (nonatomic, readonly) BOOL displayEnabled;
@property (nonatomic, readonly) id item;
@property (nonatomic, readonly) id staff;
@property (nonatomic, readonly) id bitem;
@property (nonatomic, readonly) BOOL notificationEnabled;
@property (nonatomic, readonly) NSArray* notifications;
@property (nonatomic, weak) id<BeaconDelegate> beaconDelegate;

@property (nonatomic, strong) PFObject* data;

@property (nonatomic) double t;
@property (nonatomic) double nearestWeight;
@property (nonatomic) CLProximity avgProximity;
@property (nonatomic, strong) NSMutableArray* samples;
@property (nonatomic) double lastInRangeTime;
@property (nonatomic) UIImage* itemImg1;
@property (nonatomic) int bcStatViewTag;
@property (nonatomic) BOOL inRange;
@property (nonatomic) ESTBeaconRegion* monitorRegion;
@property (nonatomic) ESTBeaconRegion* rangeRegion;
- (BOOL) isEqual:(id)r;
- (void) set:(id)eb t:(double)t;
- (void) addSample:(id) eb t:(double)t;


- (id) getNotification:(NSString*) type;
@end

int getPxDist(CLProximity px);
Beacon* createBeacon();
Beacon* createBeaconWithData(id data);
ESTBeaconRegion* createRegionWithMajorAndMinor(Beacon* b, NSString* identifier);
ESTBeaconRegion* createRegion(Beacon* b, NSString* identifier);
