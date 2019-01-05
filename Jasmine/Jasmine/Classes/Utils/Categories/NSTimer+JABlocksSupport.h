//
//  NSTimer+JABlocksSupport.h
//  Jasmine
//
//  Created by moli-2017 on 2017/5/22.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (JABlocksSupport)

+ (NSTimer *)ja_scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)())block;

@end
