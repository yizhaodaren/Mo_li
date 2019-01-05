//
//  JAActivityFloatModel.h
//  Jasmine
//
//  Created by moli-2017 on 2017/11/16.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JAActivityFloatModel : JABaseModel

@property (nonatomic, strong) NSString *floatId;
@property (nonatomic, assign) NSInteger floatState;  // 弹出状态 默认 0 未弹出  1 已弹出

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *image;
@property (nonatomic, strong) NSString *url;

@property (nonatomic, assign) NSInteger contentType;// 跳转类型
@property (nonatomic, assign) NSInteger sort;  // 权重
@property (nonatomic, assign) NSInteger time;  // 时间间隔

@end
