//
//  JACheckNetRequest.m
//  Jasmine
//
//  Created by moli-2017 on 2018/6/6.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JACheckNetRequest.h"
typedef NS_ENUM(NSUInteger, JACheckNetRequestType) {
    JACheckNetRequestType_top,
    JACheckNetRequestType_essence,
    JACheckNetRequestType_shen,
    JACheckNetRequestType_hidden,
};

@interface JACheckNetRequest ()
@property (nonatomic, assign) JACheckNetRequestType type;
@property (nonatomic, strong) NSDictionary *parameter;
@property (nonatomic, strong) NSString *actionId;
@end
@implementation JACheckNetRequest

// 置顶
- (instancetype)initRequest_circleTopWithParameter:(NSDictionary *)parameter storyId:(NSString *)storyId
{
    self = [super init];
    if (self) {
        _type = JACheckNetRequestType_top;
        _parameter = parameter;
        _actionId = storyId;
    }
    
    return self;
}

// 加精华
- (instancetype)initRequest_essenceStoryWithParameter:(NSDictionary *)parameter storyId:(NSString *)storyId
{
    self = [super init];
    if (self) {
        _type = JACheckNetRequestType_essence;
        _parameter = parameter;
        _actionId = storyId;
    }
    
    return self;
}

- (Class)modelClass
{
    return [JANetBaseModel class];
}

- (id)requestArgument
{
    return _parameter;
}

- (YTKRequestMethod)requestMethod
{
    return YTKRequestMethodGET;
}

- (NSString *)requestUrl
{
    switch (_type) {
        case JACheckNetRequestType_top:
        {
            NSString *url = @"/moli_audio_consumer/v3/circle/top/${storyId}";
            url = [url stringByReplacingOccurrencesOfString:@"${storyId}" withString:self.actionId];
            return url;
        }
            break;
        case JACheckNetRequestType_essence:
        {
            NSString *url = @"/moli_audio_consumer/v3/essence/${storyId}";
            url = [url stringByReplacingOccurrencesOfString:@"${storyId}" withString:self.actionId];
            return url;
        }
            break;
        case JACheckNetRequestType_shen:
        {
            NSString *url = @"";
            return url;
        }
            break;
        case JACheckNetRequestType_hidden:
        {
            NSString *url = @"";
            return url;
        }
            break;
        default:
            return @"";
            break;
    }
}

- (NSString *)actionId {
    if (!_actionId.length) {
        return @"";
    }
    return _actionId;
}

@end
