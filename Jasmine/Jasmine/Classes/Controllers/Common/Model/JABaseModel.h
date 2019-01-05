//
//  JABaseModel.h
//  Jasmine
//
//  Created by xujin on 09/06/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JAFocusPersonInfo.h"

@interface JAActionModel : NSObject

@property (nonatomic, copy) NSString *actionId;

@end

@interface JAActionStateMsg : NSObject

/**
 *点赞状态id
 */
@property (nonatomic, copy) NSString *agreeState;

/**
 *踩状态id
 */
@property (nonatomic, copy) NSString *opposeState;

/**
 *没有帮助状态id
 */
@property (nonatomic, copy) NSString *nohelpState;

/**
 *感谢状态id
 */
@property (nonatomic, copy) NSString *thankState;

/**
 *内容关注状态
 */
@property (nonatomic, copy) NSString *contentState;

/**
 *用户关注状态
 */
@property (nonatomic, copy) NSString *userState;

/**
 *回答状态
 */
@property (nonatomic, copy) NSString *answerState;

/**
 *收藏状态
 */
@property (nonatomic, copy) NSString *collentState;

/**
 * 擅长的话题
 */
@property (nonatomic, copy) NSString *adeptTopic;

@end

typedef NS_ENUM(NSUInteger, VoicePlayState) {
    VoicePlayStateNone = 0,
    VoicePlayStateBegin,
    VoicePlayStateFinish,
};

@interface JABaseModel : NSObject

@property (nonatomic, strong) JAActionStateMsg *actionStateMsg;
@property (nonatomic, strong) JAFocusPersonInfo *userMsg;
//@property (nonatomic, copy) NSString *shareUrl;

@end
