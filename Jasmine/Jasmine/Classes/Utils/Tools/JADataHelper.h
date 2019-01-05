//
//  JADataHelper.h
//  Jasmine
//
//  Created by xujin on 29/03/2018.
//  Copyright © 2018 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JAConsumer.h"

@interface JADataHelper : NSObject

// @信息查找
+ (JAConsumer *)getConsumer:(NSString *)userName atList:(NSArray *)atList;

// @正则匹配
+ (NSArray *)getRangesForUserHandles:(NSString *)text;

// #正则匹配
+ (NSArray *)getRangesForHashtags:(NSString *)text;

+ (NSMutableArray *)getAtListWithContent:(NSString *)content atPersonArray:(NSArray *)atPersonArray;

// ❀正则匹配
+ (NSArray *)getRangesForFlowers:(NSString *)text;

@end
