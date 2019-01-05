//
//  JAAlbumNetRequest.m
//  Jasmine
//
//  Created by moli-2017 on 2018/5/23.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAAlbumNetRequest.h"

typedef NS_ENUM(NSUInteger, JAAlbumNetRequestType) {
    JAAlbumNetRequestType_list,
    JAAlbumNetRequestType_detail,
    JAAlbumNetRequestType_storyList,
    JAAlbumNetRequestType_collectList,   // 收藏专辑
};

@interface JAAlbumNetRequest ()
@property (nonatomic, assign) JAAlbumNetRequestType type;
@property (nonatomic, strong) NSDictionary *parameter;
@property (nonatomic, strong) NSString *subjectId;
@end

@implementation JAAlbumNetRequest


- (instancetype)initRequest_albumListWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _type = JAAlbumNetRequestType_list;
        _parameter = parameter;
    }
    
    return self;
}

- (instancetype)initRequest_albumInfoWithParameter:(NSDictionary *)parameter subjectId:(NSString *)subjectId
{
    self = [super init];
    if (self) {
        _type = JAAlbumNetRequestType_detail;
        _parameter = parameter;
        _subjectId = subjectId;
    }
    
    return self;
}

- (instancetype)initRequest_albumStoryListWithParameter:(NSDictionary *)parameter subjectId:(NSString *)subjectId
{
    self = [super init];
    if (self) {
        _type = JAAlbumNetRequestType_storyList;
        _parameter = parameter;
        _subjectId = subjectId;
    }
    
    return self;
}

- (instancetype)initRequest_collectAlbumListWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _type = JAAlbumNetRequestType_collectList;
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
    if (_type == JAAlbumNetRequestType_list) {
        return [JAAlbumGroupModel class];
    }else if (_type == JAAlbumNetRequestType_detail) {
        return [JAAlbumModel class];
    }else if (_type == JAAlbumNetRequestType_storyList) {
        return [JANewVoiceGroupModel class];
    }else if (_type == JAAlbumNetRequestType_collectList) {
        return [JAAlbumGroupModel class];
    }else {
        return [JANetBaseModel class];
    }
}

- (YTKRequestMethod)requestMethod
{
    if (_type == JAAlbumNetRequestType_detail) {
        return YTKRequestMethodGET;
    }
    return YTKRequestMethodPOST;
}

- (NSString *)requestUrl
{
    switch (_type) {
        case JAAlbumNetRequestType_list:
        {
            NSString *url = @"/moli_audio_consumer/v3/subjects";
            return url;
        }
            break;
        case JAAlbumNetRequestType_detail:
        {
            NSString *url = @"/moli_audio_consumer/v3/subject/${subjectId}";
            url = [url stringByReplacingOccurrencesOfString:@"${subjectId}" withString:self.subjectId];
            return url;
        }
            break;
        case JAAlbumNetRequestType_storyList:
        {
            NSString *url = @"/moli_audio_consumer/v3/subject/${subjectId}/stories";
            url = [url stringByReplacingOccurrencesOfString:@"${subjectId}" withString:self.subjectId];
            return url;
        }
            break;
        case JAAlbumNetRequestType_collectList:
        {
            NSString *url = @"/moli_audio_consumer/v3/collect/subjects";
            return url;
        }
            break;
        default:
            return @"";
            break;
    }
}

- (NSString *)subjectId {
    if (!_subjectId.length) {
        return @"";
    }
    return _subjectId;
}

@end
