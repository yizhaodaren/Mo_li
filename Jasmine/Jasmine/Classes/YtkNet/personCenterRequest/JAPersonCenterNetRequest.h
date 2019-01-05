//
//  JAPersonCenterNetRequest.h
//  Jasmine
//
//  Created by moli-2017 on 2018/5/30.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JANetRequest.h"
#import "JANewVoiceGroupModel.h"
#import "JANewCommentGroupModel.h"
#import "JAMarkGroupModel.h"

@interface JAPersonCenterNetRequest : JANetRequest

/// 个人中心 帖子列表
- (instancetype)initRequest_personStoryListStoryListWithParameter:(NSDictionary *)parameter userId:(NSString *)userId;

/// 个人中心 评论列表
- (instancetype)initRequest_personCommentListWithParameter:(NSDictionary *)parameter userId:(NSString *)userId;

/// 个人中心 收藏列表
- (instancetype)initRequest_personCollectListWithParameter:(NSDictionary *)parameter;

/// 个人中心 我的投稿
- (instancetype)initRequest_personContributeListWithParameter:(NSDictionary *)parameter;

/// 个人中心 头衔
- (instancetype)initRequest_personMarkWithParameter:(NSDictionary *)parameter userId:(NSString *)userId;
@end
