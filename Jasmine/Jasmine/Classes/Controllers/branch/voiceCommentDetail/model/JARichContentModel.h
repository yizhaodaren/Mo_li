//
//  JARichContentModel.h
//  Jasmine
//
//  Created by xujin on 2018/6/9.
//  Copyright © 2018 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JARichContentModel : NSObject

@property (nonatomic, assign) NSInteger type; // 0文本1图片
@property (nonatomic, copy) NSString* text;
@property (nonatomic, assign) CGFloat width; // 图片宽
@property (nonatomic, assign) CGFloat height; // 图片高

@end
