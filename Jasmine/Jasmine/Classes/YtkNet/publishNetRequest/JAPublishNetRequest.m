//
//  JAPublishNetRequest.m
//  Jasmine
//
//  Created by moli-2017 on 2018/6/1.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAPublishNetRequest.h"
typedef NS_ENUM(NSUInteger, JAPublishNetRequestType) {
    JAPublishNetRequestType_story,
    JAPublishNetRequestType_comment,
    JAPublishNetRequestType_reply,
};

@interface JAPublishNetRequest ()
@property (nonatomic, assign) JAPublishNetRequestType type;
@property (nonatomic, strong) NSDictionary *parameter;
@end

@implementation JAPublishNetRequest

/// 发布 帖子
- (instancetype)initRequest_publishStoryWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _type = JAPublishNetRequestType_story;
        _parameter = parameter;
        
    }
    
    return self;
}

/// 发布 评论
- (instancetype)initRequest_publishCommentWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _type = JAPublishNetRequestType_comment;
        _parameter = parameter;
        
    }
    
    return self;
}

/// 发布 回复
- (instancetype)initRequest_publishReplyWithParameter:(NSDictionary *)parameter;
{
    self = [super init];
    if (self) {
        _type = JAPublishNetRequestType_reply;
        _parameter = parameter;
        
    }
    
    return self;
}

- (Class)modelClass
{
    if (_type == JAPublishNetRequestType_story) {
        return [JANewVoiceModel class];
    }else if (_type == JAPublishNetRequestType_comment){
        return [JANewCommentModel class];
    }else if (_type == JAPublishNetRequestType_reply){
        return [JANewReplyModel class];
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
    return YTKRequestMethodPOST;
}

- (NSString *)requestUrl
{
    switch (_type) {
        case JAPublishNetRequestType_story:
        {
            NSString *url = @"/moli_audio_consumer/v3/story/publish";
            
            return url;
        }
            break;
        case JAPublishNetRequestType_comment:
        {
            NSString *url = @"/moli_audio_consumer/v3/comment/publish";
            
            return url;
        }
            break;
        case JAPublishNetRequestType_reply:
        {
            NSString *url = @"/moli_audio_consumer/v3/reply/publish";
            return url;
        }
            break;
        default:
            return @"";
            break;
    }
}
@end
