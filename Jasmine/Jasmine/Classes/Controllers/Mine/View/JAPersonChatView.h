//
//  JAPersonChatView.h
//  Jasmine
//
//  Created by moli-2017 on 2017/7/9.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>
//style
typedef NS_ENUM(int, JAUserRelation) {
    JAUserRelationFocus = 0,                // 我是否关注了该人
    JAUserRelationFriend,                   // 我和他是否是好友
    JAUserRelationNone,                     // 没有关系
    JAUserRelationBlack                    // 黑名单
};

@interface JAPersonChatView : UIView
@property (nonatomic, weak) UIButton *chatButton;
@property (nonatomic, weak) UIButton *focusButton;

@property (nonatomic, strong) NSString *userId;    // 关注人的uid   ---- 新个人中心没用
@property (nonatomic, assign) JAUserRelation relationType; // 好友关系
@end
