//
//  JAVoiceFollowView.h
//  Jasmine
//
//  Created by xujin on 15/09/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAStoryViewController.h"

@interface JAVoiceFollowView : UIView

@property (nonatomic, weak) JAStoryViewController *vc;
@property (nonatomic, strong) NSMutableArray *follows;
@property (nonatomic, copy) void(^followSuccess)(void);
- (void)getFollowData;

@end
