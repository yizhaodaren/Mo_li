//
//  JAPersonCenterNetRequest.m
//  Jasmine
//
//  Created by moli-2017 on 2018/5/30.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAPersonCenterNetRequest.h"

typedef NS_ENUM(NSUInteger, JAPersonCenterNetRequestType) {
    JAPersonCenterNetRequestType_storyList,
    JAPersonCenterNetRequestType_commentList,
    JAPersonCenterNetRequestType_collectList,
    JAPersonCenterNetRequestType_contribute,
    JAPersonCenterNetRequestType_mark,
};

@interface JAPersonCenterNetRequest ()
@property (nonatomic, assign) JAPersonCenterNetRequestType type;
@property (nonatomic, strong) NSDictionary *parameter;
@property (nonatomic, strong) NSString *userId;
@end

@implementation JAPersonCenterNetRequest

/// 个人中心 帖子列表
- (instancetype)initRequest_personStoryListStoryListWithParameter:(NSDictionary *)parameter userId:(NSString *)userId
{
    self = [super init];
    if (self) {
        _type = JAPersonCenterNetRequestType_storyList;
        _parameter = parameter;
        _userId = userId;
    }
    
    return self;
}

/// 个人中心 评论列表
- (instancetype)initRequest_personCommentListWithParameter:(NSDictionary *)parameter userId:(NSString *)userId
{
    self = [super init];
    if (self) {
        _type = JAPersonCenterNetRequestType_commentList;
        _parameter = parameter;
        _userId = userId;
    }
    
    return self;
}

/// 个人中心 收藏列表
- (instancetype)initRequest_personCollectListWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _type = JAPersonCenterNetRequestType_collectList;
        _parameter = parameter;
    }
    
    return self;
}

/// 个人中心 我的投稿
- (instancetype)initRequest_personContributeListWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _type = JAPersonCenterNetRequestType_contribute;
        _parameter = parameter;
    }
    
    return self;
}


/// 个人中心 头衔
- (instancetype)initRequest_personMarkWithParameter:(NSDictionary *)parameter userId:(NSString *)userId
{
    self = [super init];
    if (self) {
        _type = JAPersonCenterNetRequestType_mark;
        _parameter = parameter;
        _userId = userId;
    }
    
    return self;
}

- (Class)modelClass
{
    if (_type == JAPersonCenterNetRequestType_storyList) {
        return [JANewVoiceGroupModel class];
    }else if (_type == JAPersonCenterNetRequestType_commentList){
        return [JANewCommentGroupModel class];
    }else if (_type == JAPersonCenterNetRequestType_collectList){
        return [JANewVoiceGroupModel class];
    }else if (_type == JAPersonCenterNetRequestType_contribute){
        return [JANewVoiceGroupModel class];
    }else if (_type == JAPersonCenterNetRequestType_mark){
        return [JAMarkGroupModel class];
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
    if (_type == JAPersonCenterNetRequestType_mark) {
        return YTKRequestMethodGET;
    }
    return YTKRequestMethodPOST;
}

- (NSString *)requestUrl
{
    switch (_type) {
        case JAPersonCenterNetRequestType_storyList:
        {
            NSString *url = @"/moli_audio_consumer/v3/user/${toUserId}/stories";
            url = [url stringByReplacingOccurrencesOfString:@"${toUserId}" withString:self.userId];
            return url;
        }
            break;
        case JAPersonCenterNetRequestType_commentList:
        {
            NSString *url = @"/moli_audio_consumer/v3/user/${toUserId}/comments";
            url = [url stringByReplacingOccurrencesOfString:@"${toUserId}" withString:self.userId];
            return url;
        }
            break;
        case JAPersonCenterNetRequestType_collectList:
        {
            NSString *url = @"/moli_audio_consumer/v3/collect/stories";
            return url;
        }
            break;
        case JAPersonCenterNetRequestType_contribute:
        {
            NSString *url = @"/moli_audio_consumer/v3/contribute/contributes";
            return url;
        }
            break;
        case JAPersonCenterNetRequestType_mark:
        {
            NSString *url = @"/moli_audio_consumer/v3/crown/${userId}/crownList";
            url = [url stringByReplacingOccurrencesOfString:@"${userId}" withString:self.userId];
            return url;
        }
            break;
        default:
            return @"";
            break;
    }
}

- (NSString *)userId {
    if (!_userId.length) {
        return @"";
    }
    return _userId;
}

@end
