//
//  DataButton.m
//  GGTalk
//
//  Created by lee yee chuan on 3/11/14.
//  Copyright (c) 2014 lee yee chuan. All rights reserved.
//

#import "DataButton.h"

@implementation DataButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _data = [NSMutableDictionary dictionary];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        _data = [NSMutableDictionary dictionary];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
