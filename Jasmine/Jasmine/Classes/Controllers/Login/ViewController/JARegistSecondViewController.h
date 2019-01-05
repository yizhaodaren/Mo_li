//
//  JARegistSecondViewController.h
//  Jasmine
//
//  Created by 刘宏亮 on 2017/12/6.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JABaseViewController.h"

@interface JARegistSecondViewController : JABaseViewController
@property (nonatomic, strong) NSString *phoneString;
@property (nonatomic, assign) NSInteger timeNum;

@property (nonatomic, strong) void (^againGetCode)();
@end
