//
//  JAPersonalNavBarView.h
//  Jasmine
//
//  Created by moli-2017 on 2017/6/1.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAPersonalNavBarView : UIView

@property (nonatomic, weak) UIButton *backButton;
@property (nonatomic, weak) UIButton *rightButton;
@property (nonatomic, weak) UIButton *followButton;  // 关注按钮

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) BOOL isMe;
@property (nonatomic, assign) CGFloat alphaValue;
@property (nonatomic, assign) BOOL hiddenRight;
@property (nonatomic, assign) BOOL hiddenOffic;
@property (nonatomic, assign) BOOL hiddenFollow;

- (void)PersonalNavBarView_changeInfoButtonToEdge:(BOOL)isEdge;

@end
