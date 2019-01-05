//
//  JAPersonHeaderView.h
//  Jasmine
//
//  Created by 刘宏亮 on 2017/12/4.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAPersonalInfoView.h"
#import "JANewPersonalInfoView.h"

@interface JAPersonHeaderView : UIView

// 头部
@property (nonatomic, weak) JANewPersonalInfoView *topInfoView;

@property (nonatomic, assign) CGFloat topOffY;  // 顶部偏移
@property (nonatomic, assign) BOOL hasPhoto;    // 是否有个人相册  （自己的时候总是展示）
@property (nonatomic, strong) JAConsumer *personModel;  // 个人信息
@property (nonatomic, strong) NSArray *personPhoneArray;     // 个人相册

@property (nonatomic, strong) void(^clickPersomalIconImageBlock)(UIImage *image,UIImageView *imageView);   // 点击头像
@property (nonatomic, strong) void(^clickPersomalFocusAndFansBlock)();   // 点击关注粉丝

@property (nonatomic, strong) void(^clickPersonalEditAction)();   // 点击编辑
@property (nonatomic, strong) void(^clickPersonalFollowAction)(UIButton *btn);   // 点击关注
@property (nonatomic, strong) void(^clickPersonalContributeAction)();   // 点击投稿须知
@property (nonatomic, strong) void(^clickPersonalMessageAction)();   // 点击私信
@property (nonatomic, strong) void(^clickPersonalMedalAction)();   // 点击勋章

@property (nonatomic, assign) NSInteger relationType; // 好友关系
//@property (nonatomic, strong) NSString *ruleContribute;

@property (nonatomic, weak) UIButton *locationButton;
/*
 JAUserRelationFocus = 0,                // 我是否关注了该人
 JAUserRelationFriend = 1,                   // 我和他是否是好友
 JAUserRelationNone = 2,                     // 没有关系
 JAUserRelationBlack = 3                    // 黑名单
 */
@end
