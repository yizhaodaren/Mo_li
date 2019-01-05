//
//  JAAllChannelViewController.h
//  Jasmine
//
//  Created by moli-2017 on 2017/8/29.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JABaseViewController.h"
#import "JAChannelModel.h"

@interface JAAllChannelViewController : JABaseViewController

@property (nonatomic, copy) void (^selectedChannel)(JAChannelModel *selectedModel);

@end
