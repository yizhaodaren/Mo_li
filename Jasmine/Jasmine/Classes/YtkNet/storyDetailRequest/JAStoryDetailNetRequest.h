//
//  JAStoryDetailNetRequest.h
//  Jasmine
//
//  Created by moli-2017 on 2018/5/29.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JANetRequest.h"
#import "JANewVoiceModel.h"
#import "JANewCommentGroupModel.h"
#import "JANewCommentModel.h"
#import "JANewReplyGroupModel.h"
#import "JANewReplyModel.h"

@interface JAStoryDetailNetRequest : JANetRequest

/// 帖子 - 帖子详情信息
- (instancetype)initRequest_storyInfoWithParameter:(NSDictionary *)parameter storyId:(NSString *)storyId;

/// 帖子 - 评论列表
- (instancetype)initRequest_commentListWithParameter:(NSDictionary *)parameter storyId:(NSString *)storyId;


/// 评论 - 评论详情
- (instancetype)initRequest_commentInfoWithParameter:(NSDictionary *)parameter commentId:(NSString *)commentId;

/// 评论 - 回复列表
- (instancetype)initRequest_replyListWithParameter:(NSDictionary *)parameter commentId:(NSString *)commentId;
@end
