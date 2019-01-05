//
//  JATopicNetRequest.m
//  Jasmine
//
//  Created by moli-2017 on 2018/6/5.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JATopicNetRequest.h"

@interface JATopicNetRequest ()
@property (nonatomic, strong) NSDictionary *parameter;
@end

@implementation JATopicNetRequest

/// 话题帖子列表
- (instancetype)initRequest_topicListWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _parameter = parameter;
    }
    
    return self;
}

- (Class)modelClass
{
    return [JANewVoiceGroupModel class];
}

- (id)requestArgument
{
    return _parameter;
}

- (NSString *)requestUrl
{
    NSString *url = @"/moli_audio_consumer/v3/topic/stories";
    return url;
}
@end
