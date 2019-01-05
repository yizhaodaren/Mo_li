//
//  JAMedalNetRequest.m
//  Jasmine
//
//  Created by 王树超 on 2018/7/14.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAMedalNetRequest.h"
#import "JAMedalGroupModel.h"

typedef NS_ENUM(NSUInteger, JAMedalNetRequestType) {
    JAMedalNetRequestType_medalList,
    JAMedalNetRequestType_useMedal,
    JAMedalNetRequestType_medalInfo,

};

@interface JAMedalNetRequest ()

@property (nonatomic, assign) JAMedalNetRequestType type;
@property (nonatomic, strong) NSDictionary *parameter;

@property (nonatomic, copy) NSString *medalId;//勋章ID
@property (nonatomic, copy) NSString *userId;//用户ID
@property (nonatomic, copy) NSString *use;//佩戴

@end

@implementation JAMedalNetRequest
//获取勋章列表
- (instancetype)initRequest_getMedalListWithParameter:(NSDictionary *)parameter userID:(NSString *)userID{
        self = [super init];
        if (self) {
            _type = JAMedalNetRequestType_medalList;
            _parameter = parameter;
            _userId = userID;
        }
        return self;
}
//勋章详情
- (instancetype)initRequest_MedalInfoWithParameter:(NSDictionary *)parameter MedalID:(NSString *)medalId WithUserID:(NSString *)userId{
    self = [super init];
    if (self) {
        _type = JAMedalNetRequestType_medalInfo;
        _parameter = parameter;
        _userId = userId;
        _medalId = medalId;
    }
    return self;
}
//佩戴勋章
- (instancetype)initRequest_adornMedalWithParameter:(NSDictionary *)parameter MedalID:(NSString *)medalId WithUse:(NSString *)use{
    self = [super init];
    if (self) {
        _type = JAMedalNetRequestType_useMedal;
        _parameter = parameter;
        _medalId = medalId;
        _use = use;
    }
    return self;
}

- (id)requestArgument
{
    return _parameter;
}

- (Class)modelClass
{
    if (_type == JAMedalNetRequestType_medalList) {
          return [JAMedalGroupModel class];
    }else  if (_type == JAMedalNetRequestType_medalInfo) {
        return [JAMedalModel class];
    }else {
        return [JANetBaseModel class];
    }
}
- (YTKRequestMethod)requestMethod
{
//    if (_type == JALabelSelectNetRequestType_labelList) {
//        return YTKRequestMethodGET;
//    }
    return YTKRequestMethodPOST;
}

- (NSString *)requestUrl
{
    NSString *url = @"";
    switch (_type) {
        case JAMedalNetRequestType_medalList:
        {
            NSString *url = @"/moli_audio_consumer/v3/medal/{userId}/medals";
            url = [url stringByReplacingOccurrencesOfString:@"{userId}" withString:self.userId];
            return url;
        }
            break;
        case JAMedalNetRequestType_useMedal:
        {
            NSString *url = @"/moli_audio_consumer/v3/medal/{medalId}/{use}";
            url = [url stringByReplacingOccurrencesOfString:@"{medalId}" withString:self.medalId];
            url = [url stringByReplacingOccurrencesOfString:@"{use}" withString:self.use];
            return url;
            
        }
            break;
        case JAMedalNetRequestType_medalInfo:
        {
            
            NSString *url = @"/moli_audio_consumer/v3/medal/{medalId}/medalInfo?userId={userId}";
            url = [url stringByReplacingOccurrencesOfString:@"{medalId}" withString:self.medalId];
                url = [url stringByReplacingOccurrencesOfString:@"{userId}" withString:self.userId];
            return url;
          
        }
            break;
        default:
            break;
    }
    return url;
}
//用户ID
-(NSString *)userId{
    if (!_userId.length) {
        return @"";
    }
    return _userId;
}
//勋章ID
-(NSString *)medalId{
    if (!_medalId.length) {
        return @"";
    }
    return _medalId;
}
//佩戴？
-(NSString *)use{
    if (!_use.length) {
        return @"";
    }
    return _use;
}
@end


