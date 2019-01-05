//
//  EDRequestUrlManager.m
//  Jasmine
//
//  Created by moli-2017 on 2017/7/21.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "EDRequestUrlManager.h"

@implementation EDRequestUrlManager


/// 获取评论的回复Url
+ (NSString *)url_reply
{
    return @"/moli_explore_consumer/reply/v1/selectAllReplyByPage";
}

/// 删除回复url
+ (NSString *)url_replyDelete
{
    return @"/moli_explore_consumer/reply/v1/updateByPrimaryKeyDeleted";
}

/// 添加回复url
+ (NSString *)url_replyInsert
{
    return @"/moli_explore_consumer/reply/v1/insertSelective";
}

@end
