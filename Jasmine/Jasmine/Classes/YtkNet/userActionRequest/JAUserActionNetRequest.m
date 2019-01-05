//
//  JAUserActionNetRequest.m
//  Jasmine
//
//  Created by moli-2017 on 2018/6/6.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAUserActionNetRequest.h"
typedef NS_ENUM(NSUInteger, JAUserActionNetRequestType) {
    JAUserActionNetRequest_like,
    JAUserActionNetRequest_focus,
    JAUserActionNetRequest_collect,
    JAUserActionNetRequest_noInterest,
    JAUserActionNetRequest_report,
    JAUserActionNetRequest_delete,
};

@interface JAUserActionNetRequest ()
@property (nonatomic, assign) JAUserActionNetRequestType type;
@property (nonatomic, strong) NSDictionary *parameter;
@property (nonatomic, strong) NSString *actionId;
@end

@implementation JAUserActionNetRequest


// 点赞
- (instancetype)initRequest_userLikeWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _type = JAUserActionNetRequest_like;
        _parameter = parameter;
    }
    
    return self;
}

// 关注
- (instancetype)initRequest_userFocusWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _type = JAUserActionNetRequest_focus;
        _parameter = parameter;
    }
    
    return self;
}

// 收藏
- (instancetype)initRequest_userCollectWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _type = JAUserActionNetRequest_collect;
        _parameter = parameter;
    }
    
    return self;
}

// 不感兴趣
- (instancetype)initRequest_userNoInterestWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _type = JAUserActionNetRequest_noInterest;
        _parameter = parameter;
    }
    
    return self;
}

// 举报
- (instancetype)initRequest_userReportWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _type = JAUserActionNetRequest_delete;
        _parameter = parameter;
    }
    
    return self;
}

// 删除
- (instancetype)initRequest_userDeleteWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _type = JAUserActionNetRequest_collect;
        _parameter = parameter;
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

- (NSString *)requestUrl
{
    switch (_type) {
        case JAUserActionNetRequest_like:
        {
            NSString *url = @"";
            return url;
        }
            break;
        case JAUserActionNetRequest_focus:
        {
            NSString *url = @"";
            return url;
        }
            break;
        case JAUserActionNetRequest_collect:
        {
            NSString *url = @"/moli_audio_consumer/v3/collect/upset";
            return url;
        }
            break;
        case JAUserActionNetRequest_noInterest:
        {
            NSString *url = @"";
            return url;
        }
            break;
        case JAUserActionNetRequest_report:
        {
            NSString *url = @"";
            return url;
        }
            break;
        case JAUserActionNetRequest_delete:
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
@end
