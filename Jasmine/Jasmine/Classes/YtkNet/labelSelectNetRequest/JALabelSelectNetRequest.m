//
//  JALabelSelectNetRequest.m
//  Jasmine
//
//  Created by xujin on 2018/5/28.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JALabelSelectNetRequest.h"

typedef NS_ENUM(NSUInteger, JALabelSelectNetRequestType) {
    JALabelSelectNetRequestType_labelList,
    JALabelSelectNetRequestType_saveLabel,
    JALabelSelectNetRequestType_syncLabel,
};

@interface JALabelSelectNetRequest ()

@property (nonatomic, assign) JALabelSelectNetRequestType type;
@property (nonatomic, strong) NSDictionary *parameter;
@property (nonatomic, strong) NSString *subjectId;

@end

@implementation JALabelSelectNetRequest

- (instancetype)initRequest_labelsWithParameter:(NSDictionary *)parameter {
    self = [super init];
    if (self) {
        _type = JALabelSelectNetRequestType_labelList;
        _parameter = parameter;
    }
    return self;
}

- (instancetype)initRequest_saveLabelsWithParameter:(NSDictionary *)parameter {
    self = [super init];
    if (self) {
        _type = JALabelSelectNetRequestType_saveLabel;
        _parameter = parameter;
    }
    return self;
}

- (instancetype)initRequest_syncLabelsWithParameter:(NSDictionary *)parameter {
    self = [super init];
    if (self) {
        _type = JALabelSelectNetRequestType_syncLabel;
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
    if (_type == JALabelSelectNetRequestType_labelList) {
        return [JALabelSelectGroupModel class];
    }else {
        return [JANetBaseModel class];
    }
    

}

- (YTKRequestMethod)requestMethod
{
    if (_type == JALabelSelectNetRequestType_labelList) {
        return YTKRequestMethodGET;
    }
    return YTKRequestMethodPOST;
}

- (NSString *)requestUrl
{
    NSString *url = @"";
    switch (_type) {
        case JALabelSelectNetRequestType_labelList:
        {
            url = @"/moli_audio_consumer/v3/global/labels";
        }
            break;
        case JALabelSelectNetRequestType_saveLabel:
        {
            url = @"/moli_audio_consumer/v3/user/labels/save";
        }
            break;
        case JALabelSelectNetRequestType_syncLabel:
        {
            url = @"/moli_audio_consumer/v3/userTemp/labels/synch";
        }
            break;
        default:
            break;
    }
    return url;
}

@end
