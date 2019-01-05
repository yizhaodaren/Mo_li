//
//  UIScrollView+touch.m
//  Jasmine
//
//  Created by 王树超 on 2018/7/12.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "UIScrollView+touch.h"

@implementation UIScrollView (touch)
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [[self nextResponder] touchesBegan:touches withEvent:event];
    
    [super touchesBegan:touches withEvent:event];
}
@end
