//
//  JAVoiceNotiTypeView.h
//  Jasmine
//
//  Created by moli-2017 on 2017/8/30.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JAMessageRedButton;
@interface JAVoiceNotiTypeView : UIView

@property (nonatomic, weak) UIView *boardView;  // 边框view

@property (nonatomic, strong) void(^replyClickBlock)(JAMessageRedButton *btn);
@property (nonatomic, strong) void(^agreeClickBlock)(JAMessageRedButton *btn);
@property (nonatomic, strong) void(^inviteClickBlock)(JAMessageRedButton *btn);
@property (nonatomic, strong) void(^focusClickBlock)(JAMessageRedButton *btn);

@property (nonatomic, assign) BOOL replyState;
@property (nonatomic, assign) BOOL agreeState;
@property (nonatomic, assign) BOOL focusState;
@property (nonatomic, assign) BOOL invitationState;

@property (nonatomic, assign) NSInteger tagType;
@end
