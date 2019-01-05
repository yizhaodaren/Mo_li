//
//  NSMutableArray+Queue.h
//  Jasmine
//
//  Created by xujin on 25/07/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (Queue)

- (void)enqueue:(id)item;
- (void)enqueue:(id)item maxCount:(int)count;
- (id)dequeue;
- (id)peek;

@end
