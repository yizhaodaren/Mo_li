//
//  JAInputHideButton.m
//  Jasmine
//
//  Created by moli-2017 on 2018/3/17.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAInputHideButton.h"

@implementation JAInputHideButton

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event
{
    self.touchPoint = point;
//    
//    if (CGRectContainsPoint(CGRectMake(45, 0, 40, 50), point)) {
//        return NO;
//    }
//    
    return [super pointInside:point withEvent:event];
}

@end
