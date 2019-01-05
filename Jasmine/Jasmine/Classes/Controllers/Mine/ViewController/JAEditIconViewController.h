//
//  JAEditIconViewController.h
//  Jasmine
//
//  Created by moli-2017 on 2017/6/6.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JABaseViewController.h"

@interface JAEditIconViewController : JABaseViewController
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) void(^imageChangeBlock)(UIImage *image);
@end
