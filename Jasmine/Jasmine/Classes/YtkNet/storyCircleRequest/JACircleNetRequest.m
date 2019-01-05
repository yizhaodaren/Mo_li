//
//  JACircleNetRequest.m
//  Jasmine
//
//  Created by moli-2017 on 2018/5/25.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JACircleNetRequest.h"

typedef NS_ENUM(NSUInteger, JACircleNetRequestType) {
    JACircleNetRequestType_focusCircle,
    JACircleNetRequestType_allCircle,
    JACircleNetRequestType_circleInfo,
    JACircleNetRequestType_circleStickPost,
    JACircleNetRequestType_circleVoice,
    JACircleNetRequestType_focus,
    JACircleNetRequestType_circleAdim,
    JACircleNetRequestType_circleBigAndSmallAdmin,
    JACircleNetRequestType_circleSign,
};

@interface JACircleNetRequest ()
@property (nonatomic, assign) JACircleNetRequestType type;
@property (nonatomic, strong) NSDictionary *parameter;
@property (nonatomic, strong) NSString *circleId;
@end

@implementation JACircleNetRequest

/// 关注圈子列表
- (instancetype)initRequest_focusCircleListWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _type = JACircleNetRequestType_focusCircle;
        _parameter = parameter;
    }
    
    return self;
}

/// 推荐（全部）圈子列表
- (instancetype)initRequest_allCircleListWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _type = JACircleNetRequestType_allCircle;
        _parameter = parameter;
    }
    
    return self;
}

/// 圈子详情 - 基本信息
- (instancetype)initRequest_circleInfoWithParameter:(NSDictionary *)parameter circleId:(NSString *)circleId
{
    self = [super init];
    if (self) {
        _type = JACircleNetRequestType_circleInfo;
        _parameter = parameter;
        _circleId = circleId;
    }
    
    return self;
}

/// 圈子详情 - 置顶帖
- (instancetype)initRequest_circleStickPostWithParameter:(NSDictionary *)parameter circleId:(NSString *)circleId
{
    self = [super init];
    if (self) {
        _type = JACircleNetRequestType_circleStickPost;
        _parameter = parameter;
        _circleId = circleId;
    }
    
    return self;
}

/// 圈子详情 - 帖子列表
- (instancetype)initRequest_circleVoiceListWithParameter:(NSDictionary *)parameter circleId:(NSString *)circleId
{
    self = [super init];
    if (self) {
        _type = JACircleNetRequestType_circleVoice;
        _parameter = parameter;
        _circleId = circleId;
    }
    
    return self;
}


/// 关注圈子
- (instancetype)initRequest_focusCircleWithParameter:(NSDictionary *)parameter circleId:(NSString *)circleId
{
    self = [super init];
    if (self) {
        _type = JACircleNetRequestType_focus;
        _parameter = parameter;
        _circleId = circleId;
    }
    
    return self;
}

/// 圈子圈主
- (instancetype)initRequest_circleAdminWithParameter:(NSDictionary *)parameter circleId:(NSString *)circleId
{
    self = [super init];
    if (self) {
        _type = JACircleNetRequestType_circleAdim;
        _parameter = parameter;
        _circleId = circleId;
    }
    
    return self;
}

/// 3.0.2圈子圈主
- (instancetype)initRequest_circleBigAndSmallAdminWithParameter:(NSDictionary *)parameter circleId:(NSString *)circleId
{
    self = [super init];
    if (self) {
        _type = JACircleNetRequestType_circleBigAndSmallAdmin;
        _parameter = parameter;
        _circleId = circleId;
    }
    
    return self;
}

/// 圈子签到
- (instancetype)initRequest_circleSignWithParameter:(NSDictionary *)parameter circleId:(NSString *)circleId
{
    self = [super init];
    if (self) {
        _type = JACircleNetRequestType_circleSign;
        _parameter = parameter;
        _circleId = circleId;
    }
    
    return self;
}

- (Class)modelClass
{
    if (_type == JACircleNetRequestType_focusCircle) {
        return [JACircleGroupModel class];
    }else if (_type == JACircleNetRequestType_allCircle) {
        return [JACircleGroupModel class];
    }else if (_type == JACircleNetRequestType_circleInfo) {
        return [JACircleModel class];
    }else if (_type == JACircleNetRequestType_circleStickPost) {
        return [JANewVoiceGroupModel class];
    }else if (_type == JACircleNetRequestType_circleVoice) {
        return [JANewVoiceGroupModel class];
    }else if (_type == JACircleNetRequestType_focus) {
        return [JANetBaseModel class];
    }else if (_type == JACircleNetRequestType_circleAdim) {
        return [JALightUserGroupModel class];
    }else if (_type == JACircleNetRequestType_circleBigAndSmallAdmin) {
        return [JACircleAdminGroupModel class];
    }else if (_type == JACircleNetRequestType_circleSign) {
        return [JANetBaseModel class];
    }else {
        return [JANetBaseModel class];
    }
}

- (id)requestArgument
{
    return _parameter;
}

- (YTKRequestMethod)requestMethod
{
    if (_type == JACircleNetRequestType_circleInfo || _type == JACircleNetRequestType_circleAdim || _type == JACircleNetRequestType_circleBigAndSmallAdmin) {
        return YTKRequestMethodGET;
    }
    return YTKRequestMethodPOST;
}

- (NSString *)requestUrl
{
    switch (_type) {
        case JACircleNetRequestType_focusCircle:
        {
            NSString *url = @"/moli_audio_consumer/v3/follow/circles";
            return url;
        }
            break;
        case JACircleNetRequestType_allCircle:
        {
            NSString *url = @"/moli_audio_consumer/v3/recommend/circles";
            
            return url;
        }
            break;
        case JACircleNetRequestType_circleInfo:
        {
            NSString *url = @"/moli_audio_consumer/v3/circle/${circleId}";
            url = [url stringByReplacingOccurrencesOfString:@"${circleId}" withString:self.circleId];
            return url;
        }
            break;
        case JACircleNetRequestType_circleStickPost:
        {
            NSString *url = @"/moli_audio_consumer/v3/circle/${circleId}/top/stories";
            url = [url stringByReplacingOccurrencesOfString:@"${circleId}" withString:self.circleId];
            return url;
        }
            break;
        case JACircleNetRequestType_circleVoice:
        {
            NSString *url = @"/moli_audio_consumer/v3/circle/${circleId}/stories";
            url = [url stringByReplacingOccurrencesOfString:@"${circleId}" withString:self.circleId];
            return url;
        }
            break;
        case JACircleNetRequestType_focus:
        {
            NSString *url = @"/moli_audio_consumer/v3/follow/circle/${circleId}";
            url = [url stringByReplacingOccurrencesOfString:@"${circleId}" withString:self.circleId];
            return url;
        }
            break;
        case JACircleNetRequestType_circleAdim:
        {
            NSString *url = @"/moli_audio_consumer/v3/circle/${circleId}/users";
            url = [url stringByReplacingOccurrencesOfString:@"${circleId}" withString:self.circleId];
            return url;
        }
            break;
        case JACircleNetRequestType_circleBigAndSmallAdmin:
        {
            NSString *url = @"/moli_audio_consumer/v3.1/circle/${circleId}/users";
            url = [url stringByReplacingOccurrencesOfString:@"${circleId}" withString:self.circleId];
            return url;
        }
            break;
        case JACircleNetRequestType_circleSign:
        {
            NSString *url = @"/moli_audio_consumer/v3/circle/${circleId}/sign";
            url = [url stringByReplacingOccurrencesOfString:@"${circleId}" withString:self.circleId];
            return url;
        }
            break;
        default:
            return @"";
            break;
    }
}

- (NSString *)circleId {
    if (!_circleId.length) {
        return @"";
    }
    return _circleId;
}

@end
