//
//  geometryUtil.h
//  NotificationDemo
//
//  Created by lee yee chuan on 2/27/14.
//  Copyright (c) 2014 Estimote. All rights reserved.
//

#ifndef NotificationDemo_geometryUtil_h
#define NotificationDemo_geometryUtil_h

CGPoint inline cpp0() {
    return CGPointZero;
}

CGPoint inline cppX0(float x) {
    return CGPointMake(x, 0);
}

CGPoint inline cpp0Y(float y) {
    return CGPointMake(0, y);
}

CGPoint inline cpp(float x, float y){
    return CGPointMake(x, y);
}

CGPoint inline cppX(CGPoint p, float x) {
    return CGPointMake((x),(p).y);
}

CGPoint inline cppY(CGPoint p, float y) {
    return CGPointMake((p).x,(y));
}

CGPoint inline cppAddX(CGPoint p, float x) {
    return CGPointMake(p.x + x, p.y);
}

CGPoint inline cppAddY(CGPoint p, float y) {
    return CGPointMake(p.x, y + p.y);
}

CGPoint inline cppAddXY(CGPoint p, float x, float y) {
    return CGPointMake(p.x + x, p.y + y);
}

CGPoint inline cppAdd(CGPoint p, CGPoint p1) {
    return CGPointMake(p.x + p1.x, p.y + p1.y);
}

#define cszAddXY(p1, _x, _y) CGSizeMake((p1).width+(_x),(p1).height+(_y))

#define cvt(x,y) CGVectorMake((x),(y))
#define cvtX(x) CGVectorMake((x),0)
#define cvtY(y) CGVectorMake(0,(y))


CGPoint inline cppMidMinRect(CGRect r) {
    return CGPointMake((r).origin.x, (r).origin.y);
}

CGPoint inline cppMidMaxRect(CGRect r) {
    return CGPointMake((r).origin.x + (r).size.width/2, (r).origin.y + (r).size.height);
}

CGPoint inline cppMinMidRect(CGRect r) {
    return CGPointMake((r).origin.x, (r).origin.y + (r).size.height/2);
}

CGPoint inline cppMaxMidRect(CGRect r) {
    return CGPointMake((r).origin.x + (r).size.width, (r).origin.y + (r).size.height/2);
}

CGPoint inline cppMidRect(CGRect r) {
    return CGPointMake((r).origin.x + (r).size.width/2, (r).origin.y + (r).size.height/2);
}

CGPoint inline cppMinMinRect(CGRect r) {
    return CGPointMake((r).origin.x, (r).origin.y);
}

CGPoint inline cppMinMaxRect(CGRect r) {
    return CGPointMake((r).origin.x, (r).origin.y + (r).size.height);
}

CGPoint inline cppMaxMinRect(CGRect r) {
    return CGPointMake((r).origin.x + (r).size.width, (r).origin.y);
}

CGPoint inline cppMaxMaxRect(CGRect r) {
    return CGPointMake((r).origin.x + (r).size.width, (r).origin.y + (r).size.height);
}

CGRect inline crect(float x,float y,float w,float h) {
    return CGRectMake(x,y,w,h);
}

CGRect inline crecto(float x,float y,float w,float h) {
    return CGRectMake(x+w/2,y+h/2,w,h);
}

CGRect inline crectX(CGRect r, float x) {
    return CGRectMake((x), (r).origin.y, (r).size.width, (r).size.height);
}

CGRect inline crectY(CGRect r, float y) {
    return CGRectMake((r).origin.x, (y), (r).size.width, (r).size.height);
}

CGRect inline crectXY(CGRect r, float x, float y) {
    return CGRectMake((x), (y), (r).size.width, (r).size.height);
}

CGRect inline crectW(CGRect r, float w) {
    return CGRectMake((r).origin.x, (r).origin.y, w, (r).size.height);
}

CGRect inline crectH(CGRect r, float h) {
    return CGRectMake((r).origin.x, (r).origin.y, (r).size.width, h);
}

CGRect inline crectAddX(CGRect r, float x) {
    return CGRectMake((r).origin.x+(x), (r).origin.y, (r).size.width, (r).size.height);
}

CGRect inline crectAddY(CGRect r, float y) {
    return CGRectMake((r).origin.x, (r).origin.y+(y), (r).size.width, (r).size.height);
}

CGRect inline crectAddW(CGRect r, float w) {
    return CGRectMake((r).origin.x, (r).origin.y, (r).size.width + w, (r).size.height);
}

CGRect inline crectAddH(CGRect r, float h) {
    return CGRectMake((r).origin.x, (r).origin.y, (r).size.width, (r).size.height + h);
}


#endif
