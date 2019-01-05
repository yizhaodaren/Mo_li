//
//  JARecommendNetRequest.m
//  Jasmine
//
//  Created by xujin on 2018/5/25.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JARecommendNetRequest.h"

typedef NS_ENUM(NSUInteger, JARecommendNetRequestType) {
    JARecommendNetRequestType_albumList,
    JARecommendNetRequestType_storyList,
    JARecommendNetRequestType_followList,
    JARecommendNetRequestType_peopleList,
    JARecommendNetRequestType_newList,
};

@interface JARecommendNetRequest ()

@property (nonatomic, assign) JARecommendNetRequestType type;
@property (nonatomic, strong) NSDictionary *parameter;
@property (nonatomic, strong) NSString *subjectId;

@end

@implementation JARecommendNetRequest

- (instancetype)initRequest_albumListWithParameter:(NSDictionary *)parameter {
    self = [super init];
    if (self) {
        _type = JARecommendNetRequestType_albumList;
        _parameter = parameter;
    }
    return self;
}

- (instancetype)initRequest_storyListWithParameter:(NSDictionary *)parameter {
    self = [super init];
    if (self) {
        _type = JARecommendNetRequestType_storyList;
        _parameter = parameter;
    }
    return self;
}

- (instancetype)initRequest_newStoryListWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _type = JARecommendNetRequestType_newList;
        _parameter = parameter;
    }
    return self;
}

- (instancetype)initRequest_followListWithParameter:(NSDictionary *)parameter {
    self = [super init];
    if (self) {
        _type = JARecommendNetRequestType_followList;
        _parameter = parameter;
    }
    return self;
}

- (instancetype)initRequest_peopleListWithParameter:(NSDictionary *)parameter {
    self = [super init];
    if (self) {
        _type = JARecommendNetRequestType_peopleList;
        _parameter = parameter;
    }
    return self;
}


- (id)requestArgument
{
    return _parameter;
}

- (Class)modelClass
{
    if (_type == JARecommendNetRequestType_albumList) {
        return [JAAlbumGroupModel class];
    } else if (_type == JARecommendNetRequestType_storyList) {
        return [JANewVoiceGroupModel class];
    } else if (_type == JARecommendNetRequestType_followList) {
        return [JANewVoiceGroupModel class];
    } else if (_type == JARecommendNetRequestType_peopleList) {
        return [JAVoiceFollowGroupModel class];
    } else if (_type == JARecommendNetRequestType_newList) {
        return [JANewVoiceGroupModel class];
    } else {
        return [JANetBaseModel class];
    }
}

- (NSString *)requestUrl
{
    NSString *url = @"";
    switch (_type) {
        case JARecommendNetRequestType_albumList:
        {
            url = @"/moli_audio_consumer/v3/recommend/subjects";
        }
            break;
        case JARecommendNetRequestType_storyList:
        {
            url = @"/moli_audio_consumer/v3/recommend/circle/stories";
        }
            break;
        case JARecommendNetRequestType_followList:
        {
            url = @"/moli_audio_consumer/v3/user/follow/stories";
        }
            break;
        case JARecommendNetRequestType_peopleList:
        {
            url = @"/moli_audio_consumer/v3/user/recomment/users";
        }
            break;
        case JARecommendNetRequestType_newList:
        {
            url = @"/moli_audio_consumer/v3/story/newStories";
        }
            break;
        default:
            break;
    }
    return url;
}

@end

