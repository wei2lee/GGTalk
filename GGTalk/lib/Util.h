//
//  Util.h
//  NotificationDemo
//
//  Created by lee yee chuan on 3/6/14.
//  Copyright (c) 2014 Estimote. All rights reserved.
//

#import <Foundation/Foundation.h>




NSString* getDeviceUUID();
NSString* getIndent(int level);
void debugView(UIView* view, int level, int maxlevel);
id toObj(id obj);
BOOL isNull(id obj);
NSString* getObjectId(id obj);
CABasicAnimation* animTo(CALayer* layer, NSString* keyPath, id toValue, float duration);
UIColor* createColorWithRGBHex(unsigned int hex);
UIColor* createColorWithRGBHexStr(NSString* hexStr);
unsigned int convertHexStrToInt(NSString* hexStr);
BOOL inRange(double val, double min, double max);


NSMutableDictionary* getNotification(NSMutableArray* notifications, NSString* type);
UIView* createStaffView(UIView* view);UIImageView* getStaffImageView(UIView* view);
UILabel* getStaffLabel(UIView* view);
UIView* createView(UIView* view);
UIButton* createButton(UIButton* btn, id target);
UIImageView* createItemImage(UIImageView* img);

NSString* pathForResource(NSBundle* bundle, NSString* filename) ;

@interface Util : NSObject

@end

