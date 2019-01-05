//
//  NSMutableArray+Queue.m
//  Jasmine
//
//  Created by xujin on 25/07/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "NSMutableArray+Queue.h"

@implementation NSMutableArray (Queue)

- (void)enqueue:(id)item {
    [self addObject:item];
}

- (void)enqueue:(id)item maxCount:(int)count
{
    if ([self count] >= count) {
        [self dequeue];
    }
    [self enqueue:item];
}

- (id)dequeue {
    id item = nil;
    if ([self count] != 0) {
        item = [self objectAtIndex:0];
        [self removeObjectAtIndex:0];
    }
    return item;
}

- (id)peek {
    id item = nil;
    if ([self count] != 0) {
        item = [self objectAtIndex:0];
    }
    return item;
}

@end
