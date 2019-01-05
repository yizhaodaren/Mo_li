//
//  JAPublishNetRequest.h
//  Jasmine
//
//  Created by moli-2017 on 2018/6/1.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JANetRequest.h"
#import "JANewVoiceModel.h"
#import "JANewCommentModel.h"
#import "JANewReplyModel.h"

@interface JAPublishNetRequest : JANetRequest
/// 发布 帖子
- (instancetype)initRequest_publishStoryWithParameter:(NSDictionary *)parameter;

/// 发布 评论
- (instancetype)initRequest_publishCommentWithParameter:(NSDictionary *)parameter;

/// 发布 回复
- (instancetype)initRequest_publishReplyWithParameter:(NSDictionary *)parameter;
@end
