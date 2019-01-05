//
//  JACircleModel.h
//  Jasmine
//
//  Created by moli-2017 on 2018/5/25.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JANetBaseModel.h"

@interface JACircleModel : JANetBaseModel

@property (nonatomic, strong) NSString *circleDesc;   // 圈子描述
@property (nonatomic, strong) NSString *circleId;     // 圈子id
@property (nonatomic, strong) NSString *circleName;   // 圈子名字
@property (nonatomic, strong) NSString *circleThumb;  // 圈子图片
@property (nonatomic, strong) NSString *followCount;  // 圈子被关注数
@property (nonatomic, strong) NSString *storyCount;   // 圈子收藏帖子数
@property (nonatomic, assign) BOOL isConcern;         // 是否关注了圈子
@property (nonatomic, strong) NSString *createTime;   // 圈子创建时间

@property (nonatomic, assign) NSInteger showAll;     // 自用字段  0 不展示  1 展示全部按钮 2 收起全部按钮
@property (nonatomic, assign) NSInteger storyNewCount;     // 自用字段

/// 3.0.2
@property (nonatomic, assign) BOOL hasSign;   // 是否签到 0 1
@property (nonatomic, strong) NSString *signNum;   // 天数
@property (nonatomic, strong) NSString *exp;   // 经验
@property (nonatomic, strong) NSString *level;   // 等级
@end
