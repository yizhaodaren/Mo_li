//
//  JAStoryViewController.h
//  Jasmine
//
//  Created by xujin on 2018/5/24.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JABaseViewController.h"
#import "JAChannelModel.h"

@class JACenterDrawerViewController;
@interface JAStoryViewController : JABaseViewController

@property (nonatomic, strong) JAChannelModel *model;
@property (nonatomic, weak) JACenterDrawerViewController *centerVc;
// v2.6.4
@property (nonatomic, copy) NSMutableArray *channels;

- (void)needRefreshFocusVC;
- (void)voiceViewVCscrollTop;

@end
