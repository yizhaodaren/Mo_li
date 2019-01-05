//
//  UIFont+JACategory.m
//  Jasmine
//
//  Created by xujin on 06/07/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "UIFont+JACategory.h"

@implementation UIFont (JACategory)

+ (UIFont *)ja_systemFontOfSize:(CGFloat)fontSize weight:(CGFloat)weight {
    NSString *currentVersion = [UIDevice currentDevice].systemVersion;
    if ([currentVersion compare:@"8.2"] == NSOrderedDescending) {
        return [UIFont systemFontOfSize:fontSize];
    }
    return [UIFont systemFontOfSize:fontSize weight:weight];
}

@end
