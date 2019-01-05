//
//  JASlider.m
//  Jasmine
//
//  Created by moli-2017 on 2018/6/3.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JASlider.h"

@implementation JASlider

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value
{
    rect.origin.x = rect.origin.x - 8;
    rect.size.width = rect.size.width + 16;
    return CGRectInset ([super thumbRectForBounds:bounds trackRect:rect value:value], 10 , 10);
}


@end
