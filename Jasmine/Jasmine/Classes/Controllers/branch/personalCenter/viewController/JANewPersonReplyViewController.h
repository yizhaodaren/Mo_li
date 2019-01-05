//
//  JANewPersonReplyViewController.h
//  Jasmine
//
//  Created by moli-2017 on 2018/5/30.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JABaseViewController.h"

@interface JANewPersonReplyViewController : JABaseViewController
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, assign) NSInteger sex;   // 1 男  2 女  （其他默认男）
@property (nonatomic, assign) NSInteger enterType;   // 0 个人中心  1 发表页面
@end
