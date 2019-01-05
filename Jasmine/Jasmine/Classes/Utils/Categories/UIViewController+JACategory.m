//
//  UIViewController+JACategory.m
//  Jasmine
//
//  Created by xujin on 24/06/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "UIViewController+JACategory.h"

@implementation UIViewController (JACategory)

- (BOOL)ja_prefersNavigationBarHidden
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setJa_prefersNavigationBarHidden:(BOOL)hidden
{
    objc_setAssociatedObject(self, @selector(ja_prefersNavigationBarHidden), @(hidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
