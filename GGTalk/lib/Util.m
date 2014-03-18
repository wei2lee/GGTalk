//
//  Util.m
//  NotificationDemo
//
//  Created by lee yee chuan on 3/6/14.
//  Copyright (c) 2014 Estimote. All rights reserved.
//

#import "Util.h"

@implementation Util

@end

NSString* getDeviceUUID() {
    NSString* identifier = nil;
    if( [UIDevice instancesRespondToSelector:@selector(identifierForVendor)] ) {
        // iOS 6+
        identifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    } else {
        // before iOS 6, so just generate an identifier and store it
        identifier = [[NSUserDefaults standardUserDefaults] objectForKey:@"identiferForVendor"];
        if( !identifier ) {
            CFUUIDRef uuid = CFUUIDCreate(NULL);
            identifier = (__bridge_transfer NSString*)CFUUIDCreateString(NULL, uuid);
            CFRelease(uuid);
            [[NSUserDefaults standardUserDefaults] setObject:identifier forKey:@"identifierForVendor"];
        }
    }
    return identifier;
}

NSMutableArray* indents;
NSString* getIndent(int level) {
    if(!indents) {
        indents = [NSMutableArray arrayWithCapacity:100];
        NSString* indent = @"";
        for (int i = 0 ; i < 100 ; i++) {
            [indents addObject:indent];
            indent = [NSString stringWithFormat:@"%@ ", indent];
        }
    }
    return indents[level];
}

void debugView(UIView* view, int level, int maxlevel) {
    NSString* indent = getIndent(level);
    NSLog(@"%@%@ frame=%@ alpha=%.2f, hidden=%d background=%@", indent, view.class, NSStringFromCGRect(view.frame), view.alpha, view.hidden, view.backgroundColor);
    if(maxlevel != -1 && level <= maxlevel) {
        for (int i = 0 ; i < view.subviews.count ; i++) {
            debugView(view.subviews[i], level+1, maxlevel);
        }
    }
}

id toObj(id obj) {
    if(isNull(obj)) return nil;
    else return obj;
}

BOOL isNull(id obj) {
    /*
    if([obj isKindOfClass:[NSString class]]) {
        if([obj respondsToSelector:@selector(isEqualToString:)]) {
            if([@"" isEqualToString:obj])return YES;
        }
    }//*/
    if([[NSNull null] isEqual:obj])return YES;
    if(obj == nil)return YES;
    return NO;
}



NSString* getObjectId(id obj) {
    if([obj respondsToSelector:@selector(objectId)]) {
        return [obj performSelector:@selector(objectId)];
    }else return obj[@"objectId"];
}

CABasicAnimation* animTo(CALayer* layer, NSString* keyPath, id toValue, float duration) {
    CABasicAnimation* a = [CABasicAnimation animationWithKeyPath:keyPath];
    a.toValue = toValue;
    a.fromValue = [layer.presentationLayer valueForKeyPath:a.keyPath];
    a.duration = duration;
    [layer removeAnimationForKey:a.keyPath];
    [layer addAnimation:a forKey:a.keyPath];
    [layer setValue:a.toValue forKeyPath:a.keyPath];
    return a;
}


UIColor* createColorWithRGBHex(unsigned int hex) {
    unsigned int r = (hex >> 16) & 0xff;
    unsigned int g = (hex >> 8) & 0xff;
    unsigned int b = (hex >> 0) & 0xff;
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0];
}

UIColor* createColorWithRGBHexStr(NSString* hexStr) {
    unsigned int hex = convertHexStrToInt(hexStr);
    unsigned int r = (hex >> 16) & 0xff;
    unsigned int g = (hex >> 8) & 0xff;
    unsigned int b = (hex >> 0) & 0xff;
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0];
}

unsigned int convertHexStrToInt(NSString* hexStr) {
    unsigned int result = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexStr];
    [scanner scanHexInt:&result];
    return result;
}

BOOL inRange(double val, double min, double max) {
    return val >= min && val <= max;
}


NSString* pathForResource(NSBundle* bundle, NSString* filename) {
    NSRange range = [filename rangeOfString:@"."];
    NSString* file = @"";
    NSString* type = @"";
    if(range.location != NSNotFound) {
        file = [filename substringToIndex:range.location];
        type = [filename substringFromIndex:range.location + 1];
    }else{
        file = filename;
        type = @"";
    }
    return [bundle pathForResource:file ofType:type];
}

