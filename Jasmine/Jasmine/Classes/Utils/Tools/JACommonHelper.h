//
//  JACommonHelper.h
//  Jasmine
//
//  Created by xujin on 2018/6/14.
//  Copyright © 2018 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JACommonHelper : NSObject

+ (CGSize)getListImageSize:(CGSize)originalSize;
+ (CGSize)reSize:(CGSize)originalSize maxSize:(CGSize)maxSize;

@end
