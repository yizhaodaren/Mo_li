//
//  JAContributeViewController.h
//  Jasmine
//
//  Created by xujin on 2018/4/9.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JABaseViewController.h"

@interface JAContributeViewController : JABaseViewController

@property (nonatomic, assign) CGFloat time;// 音频时长
@property (nonatomic, strong) NSMutableArray *allPeakLevelQueue;// 采样集合

@end
