//
//  JAConsumer.h
//  Jasmine
//
//  Created by moli-2017 on 2017/6/9.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JAMedalModel.h"
#import "JAMarkModel.h"

@interface JAConsumer : JABaseModel

@property (nonatomic, copy) NSString *achievementId;    // 成就
@property (nonatomic, copy) NSString *agreeCount;       // 收到的赞
@property (nonatomic, strong) NSString *likeAgreeCount; // 赞过别人的个数
@property (nonatomic, copy) NSString *userConsernCount; // 关注的人数
@property (nonatomic, copy) NSString *concernUserCount; // 粉丝的个数
@property (nonatomic, copy) NSString *replyCount;       // 回复个数
@property (nonatomic, copy) NSString *commentCount;     // 评论个数
@property (nonatomic, copy) NSString *storyCount;       // 故事个数
@property (nonatomic, copy) NSString *address;          // 地址
@property (nonatomic, copy) NSString *age;              // 年龄
@property (nonatomic, strong) NSString *power;  // 权限
@property (nonatomic, strong) NSString *birthdayName;   // 1990-10-10
@property (nonatomic, strong) NSString *friendType;
@property (nonatomic, strong) NSString *inviteStatus;
@property (nonatomic, strong) NSString *channel;
@property (nonatomic, copy) NSString *answerCount;      // 回答问题个数
@property (nonatomic, copy) NSString *collentCount;     // 收藏个数
@property (nonatomic, copy) NSString *constellation;    // 星座
@property (nonatomic, copy) NSString *createTime;       // 创建时间
@property (nonatomic, strong) NSString *expenditureMoney;
@property (nonatomic, copy) NSString *flowerCount;      // 花数
@property (nonatomic, copy) NSString *consumerId;       // 用户id
@property (nonatomic, copy) NSString *userId;           // 用户id
@property (nonatomic, copy) NSString *image;            // 用户头像
@property (nonatomic, copy) NSString *introduce;        // 个人简介
@property (nonatomic, strong) NSString *incomeMoney;
@property (nonatomic, strong) NSString *inviteUuid;
@property (nonatomic, copy) NSString *job;              // 工作
@property (nonatomic, copy) NSString *latitude;         // 纬度
@property (nonatomic, copy) NSString *longitude;        // 经度
@property (nonatomic, copy) NSString *levelId;          // 等级
@property (nonatomic, copy) NSString *moliFlowerCount;
@property (nonatomic, copy) NSString *name;             // 名字
@property (nonatomic, copy) NSString *password;         // 密码
@property (nonatomic, copy) NSString *phone;            // 手机
@property (nonatomic, copy) NSString *phoneType;        // 手机类型
@property (nonatomic, copy) NSString *platformType;     // 三方类型
@property (nonatomic, copy) NSString *platformUid;      // 三方uid
@property (nonatomic, strong) NSString *platformWxUid;
@property (nonatomic, strong) NSString *platformWbUid;
@property (nonatomic, strong) NSString *platformQqUid;
@property (nonatomic, copy) NSString *problemCount;     // 问题个数
@property (nonatomic, copy) NSString *publishCount;     // 文章个数
@property (nonatomic, copy) NSString *score;            // 信用值
@property (nonatomic, copy) NSString *sex;              // 性别(1男2女)
@property (nonatomic, copy) NSString *updateTime;       // 更新时间
@property (nonatomic, copy) NSString *birthday;         // 生日 - 时间戳
@property (nonatomic, copy) NSString *uuid;             // uuid
@property (nonatomic, strong) NSString *version;
@property (nonatomic, copy) NSString *status;           // 用户状态（0正常1封禁2禁言）
@property (nonatomic, copy) NSString *validTime;        // 禁言到期时间
@property (nonatomic, copy) NSString *levelScore;       // 当前经验值
@property (nonatomic, copy) NSString *topScore;         // 下一级经验值
@property (nonatomic, assign) NSInteger accumulativeSignCount;         // 下一级经验值


/// 只适用于个人中心
@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, strong) NSArray *userPhoto;

// v3.0.0
@property (nonatomic, assign) NSInteger isLabel; // 0没有添加标签  1已经添加标签

// v3.1
@property (nonatomic, strong) NSArray *medalList;  // 勋章列表
@property (nonatomic, strong) JAMedalModel *medalConfig;  // 佩戴勋章
@property (nonatomic, strong) JAMarkModel *crown;   // 头衔
@end
