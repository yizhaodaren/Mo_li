//
//  JAPostDraftModel.h
//  Jasmine
//
//  Created by xujin on 19/01/2018.
//  Copyright © 2018 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JACircleModel.h"
#import "JARichTitleModel.h"

typedef NS_ENUM(NSInteger, JAUploadState)
{
    JAUploadNormalState = 0,
    JAUploadUploadingState,
    JAUploadSuccessState,
    JAUploadFailState,
};

@interface JAPostDraftModel : NSObject

@property (nonatomic, copy) NSString *draftId;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *localAudioUrl; // 本地语音地址，判断为空表示上传成功
@property (nonatomic, copy) NSString *audioUrl; // 发送成功后，根据这个字段
@property (nonatomic, copy) NSString *time; //录音时间00:30
@property (nonatomic, copy) NSString *content; // 描述
@property (nonatomic, copy) NSString *longitude;
@property (nonatomic, copy) NSString *latitude;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *isAnonymous;
@property (nonatomic, copy) NSString *sampleZip;
/*
 {
 localimage:"url", //本地图片地址
 image:"url", //远程地址
 status:"0", //0未上传，1上传成功
 index:"0", //图片下标
 }
 */
@property (nonatomic, strong) NSMutableArray *imageInfoArray;
@property (nonatomic, assign) BOOL isAllUploadSuccess;
@property (nonatomic, strong) NSDate *createTime;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) JAUploadState uploadState;
@property (nonatomic, assign) NSInteger playState; // 0初始化1播放中2暂停

// v2.5.5
@property (nonatomic, assign) NSInteger dataType; // 0发布失败的数据1手动保存草稿箱数据2因发布内容敏感词导致的失败

// v2.6.0
/*
 {
 userId:"", //用户id
 userName:"", //用户名
 }
 */
@property (nonatomic, strong) NSMutableArray *atPersonInfoArray;

// v2.6.4
@property (nonatomic, assign) BOOL isRead; // 数目背景色：未读为红色，已读为灰色

// v3.0.0
@property (nonatomic, assign) NSInteger storyType; // 0语音帖1图文帖
@property (nonatomic, strong) JACircleModel *circle;
@property (nonatomic, strong) JARichTitleModel* titleModel;
@property (nonatomic, strong) NSMutableArray *richContentModels; // 图文帖内容数组

@end
