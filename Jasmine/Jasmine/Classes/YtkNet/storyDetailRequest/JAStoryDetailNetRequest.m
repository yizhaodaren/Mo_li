//
//  JAStoryDetailNetRequest.m
//  Jasmine
//
//  Created by moli-2017 on 2018/5/29.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAStoryDetailNetRequest.h"

typedef NS_ENUM(NSUInteger, JAStoryDetailNetRequestType) {
    JAStoryDetailNetRequestType_storyInfo,
    JAStoryDetailNetRequestType_commentList,
    JAStoryDetailNetRequestType_commentInfo,
    JAStoryDetailNetRequestType_replyList,
};

@interface JAStoryDetailNetRequest ()
@property (nonatomic, assign) JAStoryDetailNetRequestType type;
@property (nonatomic, strong) NSDictionary *parameter;
@property (nonatomic, strong) NSString *story_commentId;
@end

@implementation JAStoryDetailNetRequest

/// 帖子详情信息
- (instancetype)initRequest_storyInfoWithParameter:(NSDictionary *)parameter storyId:(NSString *)storyId
{
    self = [super init];
    if (self) {
        _type = JAStoryDetailNetRequestType_storyInfo;
        _parameter = parameter;
        _story_commentId = storyId;
    }
    
    return self;
}

/// 评论列表
- (instancetype)initRequest_commentListWithParameter:(NSDictionary *)parameter storyId:(NSString *)storyId
{
    self = [super init];
    if (self) {
        _type = JAStoryDetailNetRequestType_commentList;
        _parameter = parameter;
        _story_commentId = storyId;
    }
    
    return self;
}

/// 评论 - 评论详情
- (instancetype)initRequest_commentInfoWithParameter:(NSDictionary *)parameter commentId:(NSString *)commentId
{
    self = [super init];
    if (self) {
        _type = JAStoryDetailNetRequestType_commentInfo;
        _parameter = parameter;
        _story_commentId = commentId;
    }
    
    return self;
}

/// 评论 - 回复列表
- (instancetype)initRequest_replyListWithParameter:(NSDictionary *)parameter commentId:(NSString *)commentId
{
    self = [super init];
    if (self) {
        _type = JAStoryDetailNetRequestType_replyList;
        _parameter = parameter;
        _story_commentId = commentId;
    }
    
    return self;
}

- (Class)modelClass
{
    if (_type == JAStoryDetailNetRequestType_storyInfo) {
        return [JANewVoiceModel class];
    }else if (_type == JAStoryDetailNetRequestType_commentList){
        return [JANewCommentGroupModel class];
    }else if (_type == JAStoryDetailNetRequestType_commentInfo){
        return [JANewCommentModel class];
    }else if (_type == JAStoryDetailNetRequestType_replyList){
        return [JANewReplyGroupModel class];
    }else{
        return [JANetBaseModel class];
    }
}

- (id)requestArgument
{
    return _parameter;
}

- (YTKRequestMethod)requestMethod
{
    if (_type == JAStoryDetailNetRequestType_storyInfo
        || _type == JAStoryDetailNetRequestType_commentInfo) {
        return YTKRequestMethodGET;
    }
    return YTKRequestMethodPOST;
}

- (NSString *)requestUrl
{
    switch (_type) {
        case JAStoryDetailNetRequestType_storyInfo:
        {
            NSString *url = @"/moli_audio_consumer/v3/story/${storyId}";
            url = [url stringByReplacingOccurrencesOfString:@"${storyId}" withString:self.story_commentId];
            return url;
        }
            break;
        case JAStoryDetailNetRequestType_commentList:
        {
            NSString *url = @"/moli_audio_consumer/v3/story/${storyId}/comments";
            url = [url stringByReplacingOccurrencesOfString:@"${storyId}" withString:self.story_commentId];
            return url;
        }
            break;
        case JAStoryDetailNetRequestType_commentInfo:
        {
            NSString *url = @"/moli_audio_consumer/v3/comment/${commentId}";
            url = [url stringByReplacingOccurrencesOfString:@"${commentId}" withString:self.story_commentId];
            return url;
        }
            break;
        case JAStoryDetailNetRequestType_replyList:
        {
            NSString *url = @"/moli_audio_consumer/v3/comment/${commentId}/replies";
            url = [url stringByReplacingOccurrencesOfString:@"${commentId}" withString:self.story_commentId];
            return url;
        }
            break;
        default:
            return @"";
            break;
    }
}

- (NSString *)story_commentId {
    if (!_story_commentId.length) {
        return @"";
    }
    return _story_commentId;
}

@end
