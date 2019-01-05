//
//  NSTimer+JABlocksSupport.m
//  Jasmine
//
//  Created by moli-2017 on 2017/5/22.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "NSTimer+JABlocksSupport.h"

@implementation NSTimer (JABlocksSupport)

+ (NSTimer *)ja_scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)())block{
    return [self scheduledTimerWithTimeInterval:interval target:self selector:@selector(ja_blockInvoke:) userInfo:[block copy] repeats:repeats];
}

+ (void)ja_blockInvoke:(NSTimer *)timer{
    void (^block)() = timer.userInfo;
    if (block) {
        block();
    }
}

@end
