//
//  JAUserActionNetRequest.h
//  Jasmine
//
//  Created by moli-2017 on 2018/6/6.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JANetRequest.h"

@interface JAUserActionNetRequest : JANetRequest

// 点赞
- (instancetype)initRequest_userLikeWithParameter:(NSDictionary *)parameter;

// 关注
- (instancetype)initRequest_userFocusWithParameter:(NSDictionary *)parameter;

// 收藏
- (instancetype)initRequest_userCollectWithParameter:(NSDictionary *)parameter;

// 不感兴趣
- (instancetype)initRequest_userNoInterestWithParameter:(NSDictionary *)parameter;

// 举报
- (instancetype)initRequest_userReportWithParameter:(NSDictionary *)parameter;

// 删除
- (instancetype)initRequest_userDeleteWithParameter:(NSDictionary *)parameter;

@end
