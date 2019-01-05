//
//  JAReleasePostManager.m
//  Jasmine
//
//  Created by xujin on 19/01/2018.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JAReleasePostManager.h"
#import "JAUserApiRequest.h"
#import "JAVoiceApi.h"
#import "JAReleaseStoryCountModel.h"
#import "JAPublishNetRequest.h"
#import "JANewVoiceModel.h"
#import "JARichTextModel.h"
#import "JARichImageModel.h"
#import "JARichContentUtil.h"

@interface JAReleasePostManager()

//@property (nonatomic, assign) NSUInteger totalSendByte; //已上传文件大小
@property (nonatomic, assign) NSUInteger totalDataLength; //待上传文件大小
@property (nonatomic, strong) NSMutableArray *drafts; //待上传文件大小
@property (nonatomic, assign) NSUInteger voiceSendByte; //语音已上传文件大小
@property (nonatomic, assign) NSUInteger image1SendByte; //图片1已上传文件大小
@property (nonatomic, assign) NSUInteger image2SendByte; //图片2已上传文件大小
@property (nonatomic, assign) NSUInteger image3SendByte; //图片3已上传文件大小

@end

@implementation JAReleasePostManager

+ (JAReleasePostManager *)shareInstance
{
    static JAReleasePostManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil)
        {
            instance = [[JAReleasePostManager alloc] init];
//            instance.drafts = [NSMutableArray ]
        }
    });
    return instance;
}

- (NSArray *)getPostInDraft {
    NSArray *posts = [JAPostDraftModel searchWithWhere:nil orderBy:@"createTime Desc" offset:0 count:1000];
    return posts;
}

- (void)removeDraft:(JAPostDraftModel *)model {
    BOOL isNeed = NO;
    if (self.postDraftModel.rowid == model.rowid) {
        // 如果在草稿箱删除的数据，正好是首页的那条数据，首页显示的失败状态需要隐藏
        isNeed = YES;
    }
    [self handleRemoveDraft:model needUpdateUploadState:isNeed];
}

- (NSUInteger)getAllFileDataLength:(JAPostDraftModel *)draftModel {
    __block NSUInteger dataLength = 0;
    if (draftModel.storyType == 0) {
        NSString *localVoiceFilePath = [NSHomeDirectory() stringByAppendingPathComponent:draftModel.localAudioUrl];
        NSData *mp3Data = [NSData dataWithContentsOfFile:localVoiceFilePath];
        if (!draftModel.audioUrl.length && mp3Data.length) {
            // 未上传成功的文件
            dataLength += mp3Data.length;
        }
        [draftModel.imageInfoArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[JARichImageModel class]]) {
                JARichImageModel *model = (JARichImageModel *)obj;
                if (!model.remoteImageUrlString.length) {
                    NSString *localFilePath = [NSString ja_getUploadImageFilePath:model.localImageName];
                    UIImage *img = [[UIImage alloc] initWithContentsOfFile:localFilePath];
                    if (img) {
                        NSData *resizeData = [NSData reSizeImageData:img maxImageSize:JA_SCREEN_HEIGHT maxSizeWithKB:300];
                        // 未上传成功的文件
                        dataLength += resizeData.length;
                    }
                }
            }
        }];
    } else if (draftModel.storyType == 1) {
        [self.postDraftModel.richContentModels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[JARichImageModel class]]) {
                JARichImageModel *model = (JARichImageModel *)obj;
                if (!model.remoteImageUrlString.length) {
                    NSString *localFilePath = [NSString ja_getUploadImageFilePath:model.localImageName];
                    UIImage *img = [[UIImage alloc] initWithContentsOfFile:localFilePath];
                    if (img) {
                        NSData *resizeData = [NSData reSizeImageData:img maxImageSize:JA_SCREEN_HEIGHT maxSizeWithKB:300];
                        // 未上传成功的文件
                        dataLength += resizeData.length;
                    }
                }
            }
        }];
    }
    return dataLength;
}

- (void)postCurrentProgress {
    dispatch_async(dispatch_get_main_queue(), ^{
        __block NSUInteger totalSendByte = 0;
        if (self.postDraftModel.storyType == 0) {
            totalSendByte = self.voiceSendByte+self.image1SendByte+self.image2SendByte+self.image3SendByte;
        } else if (self.postDraftModel.storyType == 1) {
            [self.postDraftModel.richContentModels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[JARichImageModel class]]) {
                    JARichImageModel *model = (JARichImageModel *)obj;
                    totalSendByte += model.imageSendByte;
                }
            }];
        }
        CGFloat progress = totalSendByte/(self.totalDataLength*1.0);
        self.postDraftModel.progress = progress;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"JAUploadProgress" object:nil];
    });
}

- (void)asyncReleasePost:(JAPostDraftModel *)draftModel method:(NSInteger)method {
    if (draftModel) {
        self.postDraftModel = draftModel;
    }
    if (!self.postDraftModel) {
        return;
    }
    // 发布重置已发送大小
    self.voiceSendByte = 0;
    self.image1SendByte = 0;
    self.image2SendByte = 0;
    self.image3SendByte = 0;
    [self postCurrentProgress];

    // 发送前只读一次即可
    self.totalDataLength = [self getAllFileDataLength:self.postDraftModel];
    // 上传语音和图片
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    if (self.postDraftModel.storyType == 0) {
        if (!self.postDraftModel.audioUrl.length) {
            // 语音未上传成功
            dispatch_group_enter(group);
            dispatch_async(queue, ^{
                NSString *localVoiceFilePath = [NSHomeDirectory() stringByAppendingPathComponent:self.postDraftModel.localAudioUrl];
                NSData *mp3Data = [NSData dataWithContentsOfFile:localVoiceFilePath];
                if (mp3Data.length) {
                    if (self.postDraftModel.uploadState != JAUploadUploadingState) {
                        self.postDraftModel.uploadState = JAUploadUploadingState;
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"JAUploadState" object:nil];
                    }
                    [[JAUserApiRequest shareInstance] ali_upLoadData:mp3Data fileType:@"mp3" progress:^(NSUInteger totalByteSent) {
                        self.voiceSendByte = totalByteSent;
                        [self postCurrentProgress];
                    } finish:^(NSString *filePath) {
                        if (filePath.length) {
                            self.postDraftModel.audioUrl = filePath;
                        }
                        dispatch_group_leave(group);
                    }];
                } else {
                    dispatch_group_leave(group);
                }
            });
        }
        [self.postDraftModel.imageInfoArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[JARichImageModel class]]) {
                JARichImageModel *model = (JARichImageModel *)obj;
                if (!model.remoteImageUrlString.length) {
                    dispatch_group_enter(group);
                    dispatch_async(queue, ^{
                        NSString *localFilePath = [NSString ja_getUploadImageFilePath:model.localImageName];
                        UIImage *img = [[UIImage alloc] initWithContentsOfFile:localFilePath];
                        NSData *resizeData = [NSData reSizeImageData:img maxImageSize:JA_SCREEN_HEIGHT maxSizeWithKB:300];
                        if (resizeData.length) {
                            if (self.postDraftModel.uploadState != JAUploadUploadingState) {
                                self.postDraftModel.uploadState = JAUploadUploadingState;
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"JAUploadState" object:nil];
                            }
                            [[JAUserApiRequest shareInstance] ali_upLoadData:resizeData fileType:@"jpg" progress:^(NSUInteger totalByteSent) {
                                model.imageSendByte = totalByteSent;
                                [self postCurrentProgress];
                            } finish:^(NSString *filePath) {
                                if (filePath.length) {
                                    model.remoteImageUrlString = filePath;
                                }
                                dispatch_group_leave(group);
                            }];
                        } else {
                            dispatch_group_leave(group);
                        }
                    });
                }
            }
        }];
    } else if (self.postDraftModel.storyType == 1) {
        [self.postDraftModel.richContentModels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[JARichImageModel class]]) {
                JARichImageModel *model = (JARichImageModel *)obj;
                if (!model.remoteImageUrlString.length) {
                    dispatch_group_enter(group);
                    dispatch_async(queue, ^{
                        NSString *localFilePath = [NSString ja_getUploadImageFilePath:model.localImageName];
                        UIImage *img = [[UIImage alloc] initWithContentsOfFile:localFilePath];
                        NSData *resizeData = [NSData reSizeImageData:img maxImageSize:JA_SCREEN_HEIGHT maxSizeWithKB:300];
                        if (resizeData.length) {
                            if (self.postDraftModel.uploadState != JAUploadUploadingState) {
                                self.postDraftModel.uploadState = JAUploadUploadingState;
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"JAUploadState" object:nil];
                            }
                            [[JAUserApiRequest shareInstance] ali_upLoadData:resizeData fileType:@"jpg" progress:^(NSUInteger totalByteSent) {
                                model.imageSendByte = totalByteSent;
                                [self postCurrentProgress];
                            } finish:^(NSString *filePath) {
                                if (filePath.length) {
                                    model.remoteImageUrlString = filePath;
                                }
                                dispatch_group_leave(group);
                            }];
                        } else {
                            dispatch_group_leave(group);
                        }
                    });
                }
            }
        }];
    }
    
    dispatch_group_notify(group, queue, ^{
        if (self.postDraftModel.storyType == 0) {
            NSString *localVoiceFilePath = [NSHomeDirectory() stringByAppendingPathComponent:self.postDraftModel.localAudioUrl];
            NSData *mp3Data = [NSData dataWithContentsOfFile:localVoiceFilePath];
            if (!mp3Data.length) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication].delegate.window ja_makeToast:@"本地文件丢失重新录制！"];
                    [self handleRemoveDraft:self.postDraftModel needUpdateUploadState:YES];
                });
                return;
            }
            self.postDraftModel.isAllUploadSuccess = (self.postDraftModel.audioUrl.length && [self validateImageAllUploadSuccess]);
        } else if (self.postDraftModel.storyType == 1) {
            self.postDraftModel.isAllUploadSuccess =  [self validateImageAllUploadSuccess];
        }
       
        // 检查文件是否上传成功
        if (self.postDraftModel.isAllUploadSuccess) {
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            if (self.postDraftModel.city.length) {
                params[@"longitude"] = self.postDraftModel.longitude;
                params[@"latitude"] = self.postDraftModel.latitude;
                params[@"city"] = self.postDraftModel.city;
            }
            params[@"isAnonymous"] = self.postDraftModel.isAnonymous;
            // v2.6.0
            if (self.postDraftModel.atPersonInfoArray.count) {
                params[@"atList"] = [@{@"atList":self.postDraftModel.atPersonInfoArray} mj_JSONString];
            }
            // v3.0.0
            params[@"storyType"] = @(self.postDraftModel.storyType);
            params[@"circleId"] = self.postDraftModel.circle.circleId; // 兼容老数据设置为默认圈子
            if (self.postDraftModel.storyType == 0) {
                params[@"audioUrl"] = self.postDraftModel.audioUrl;
                params[@"time"] = self.postDraftModel.time;
                params[@"content"] = self.postDraftModel.content;// 声音描述
                params[@"sampleZip"] = self.postDraftModel.sampleZip;
                if (self.postDraftModel.imageInfoArray.count) {
                    NSMutableArray *photos = [NSMutableArray new];
                    [self.postDraftModel.imageInfoArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        if ([obj isKindOfClass:[JARichImageModel class]]) {
                            JARichImageModel *model = (JARichImageModel *)obj;
                            if (model.remoteImageUrlString.length) {
                                if (photos.count<3) {
                                    // 列表展示的图片最多3张
                                    [photos addObject:@{
                                                        @"src":model.remoteImageUrlString,
                                                        @"width":@(model.imageSize.width),
                                                        @"height":@(model.imageSize.height)}];
                                }
                            }
                        }
                    }];
                    if (photos.count) {
                        params[@"photos"] = photos;
                    }
                }
            } else if (self.postDraftModel.storyType == 1) {
                NSString *inputTitle = [self.postDraftModel.titleModel.textContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if (inputTitle.length) {
                    params[@"title"] = inputTitle;
                }
                // 拼接图文参数
                NSMutableArray *imageText = [NSMutableArray new];
                [self.postDraftModel.richContentModels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    if ([obj isKindOfClass:[JARichTextModel class]]) {
                        JARichTextModel *model = (JARichTextModel *)obj;
                        if (model.textContent.length) {
                            [imageText addObject:@{
                                                   @"type":@"0",
                                                   @"text":model.textContent}];
                        }
                    } else if ([obj isKindOfClass:[JARichImageModel class]]) {
                        JARichImageModel *model = (JARichImageModel *)obj;
                        if (model.remoteImageUrlString.length) {
                            [imageText addObject:@{
                                                   @"type":@"1",
                                                   @"text":model.remoteImageUrlString,
                                                   @"width":@(model.imageSize.width),
                                                   @"height":@(model.imageSize.height)}];
                        }
                    }
                }];
                if (imageText.count) {
                    params[@"imageText"] = imageText;
                }
            }
            JAPublishNetRequest *r = [[JAPublishNetRequest alloc] initRequest_publishStoryWithParameter:params];
            [r baseNetwork_startRequestWithcompletion:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
                [MBProgressHUD hideHUD];
                JANewVoiceModel *voiceModel = (JANewVoiceModel *)responseModel;
                if (voiceModel.code != 10000) {
                    if (voiceModel.code == 200015) {
                        [self handleReleaseFailWithMethod:method];
                    }
                    [[UIApplication sharedApplication].delegate.window ja_makeToast:voiceModel.message];
                    return;
                }
                [self handleReleaseSuccessWithModel:voiceModel method:method];
            } failure:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
                // 网络原因导致发布失败
                [self handleReleaseFailWithMethod:method];
            }];
        } else {
            // 附件未完全上传成功，导致失败
            [self handleReleaseFailWithMethod:method];
        }
    });
}

- (BOOL)validateImageAllUploadSuccess {
    __block BOOL success = YES;
    if (self.postDraftModel.storyType == 0) {
        [self.postDraftModel.imageInfoArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[JARichImageModel class]]) {
                JARichImageModel *model = (JARichImageModel *)obj;
                if (!model.remoteImageUrlString.length) {
                    success = NO;
                    *stop = YES;
                }
            }
        }];
    } else if (self.postDraftModel.storyType == 1) {
        [self.postDraftModel.richContentModels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[JARichImageModel class]]) {
                JARichImageModel *model = (JARichImageModel *)obj;
                if (!model.remoteImageUrlString.length) {
                    success = NO;
                    *stop = YES;
                }
            }
        }];
    }
    return success;
}

- (void)handleRemoveDraft:(JAPostDraftModel *)draftModel needUpdateUploadState:(BOOL)isNeed {
    if (isNeed) {
        self.postDraftModel.uploadState = JAUploadSuccessState;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"JAUploadState" object:nil];
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [draftModel deleteToDB];
        // 删除草稿箱数据
        [[NSNotificationCenter defaultCenter] postNotificationName:@"JA_DraftCountChange" object:nil];
        if (draftModel.storyType == 0) {
            // 删除本地音频文件
            NSString *localVoiceFilePath = [NSHomeDirectory() stringByAppendingPathComponent:draftModel.localAudioUrl];
            [NSString ja_removeFilePath:localVoiceFilePath];
            // 删除本地图片文件
            [draftModel.imageInfoArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[JARichImageModel class]]) {
                    JARichImageModel *imgContent = (JARichImageModel*)obj;
                    [JARichContentUtil deleteImageContent:imgContent];
                }
            }];
        } else if (draftModel.storyType == 1) {
            for (int i = 0; i< draftModel.richContentModels.count; i++) {
                id content = draftModel.richContentModels[i];
                if ([content isKindOfClass:[JARichImageModel class]]) {
                    JARichImageModel *imgContent = (JARichImageModel*)content;
                    [JARichContentUtil deleteImageContent:imgContent];
                }
            }
        }
    });
}

- (void)handleReleaseSuccessWithModel:(JANewVoiceModel *)model method:(NSInteger)method {
    [[UIApplication sharedApplication].delegate.window ja_makeToast:@"发布成功"];
    // 神策统计
    [self eventWithSuccess:YES storyId:model.storyId];
    // 插入到关注列表
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshVoiceModel" object:@{@"data":model,@"method":@(method)}];
    // 发布成功后删除草稿数据及附件
    [self handleRemoveDraft:self.postDraftModel needUpdateUploadState:YES];
    
    // 更新个人发帖数
    NSInteger postCount = [JAUserInfo userInfo_getUserImfoWithKey:User_storyCount].integerValue;
    postCount = postCount + 1;
    [JAUserInfo userInfo_updataUserInfoWithKey:User_storyCount value:[NSString stringWithFormat:@"%ld",postCount]];
    
    // 更新本地发帖数
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 发帖数增一
        JAReleaseStoryCountModel *model = [JAReleaseStoryCountModel searchSingleWithWhere:nil orderBy:nil];
        if (model && [model.lastDate isToday]) {
            // 当天的数据，直接自增
            model.storyCount++;
            [model updateToDB];
        } else {
            // 启动的时候获取发帖数的接口没调用成功，
            model = [JAReleaseStoryCountModel new];
            model.storyCount = 1;
            model.lastDate = [NSDate date];
            if (model) {
                [LKDBHelper clearTableData:[JAReleaseStoryCountModel class]];
                [model saveToDB];
            }
        }
    });
}

- (void)handleReleaseFailWithMethod:(NSInteger)method {
    // 首页跳转到关注列表，查看上传失败后的UI
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshVoiceModel" object:@{@"method":@(method)}];
    // 更新上传进度UI
    self.postDraftModel.uploadState = JAUploadFailState;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"JAUploadState" object:nil];
    // 神策统计
    [self eventWithSuccess:NO storyId:nil];
    // 更新数据库
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.postDraftModel updateToDB];
        // 草稿箱更改数据
        [[NSNotificationCenter defaultCenter] postNotificationName:@"JA_DraftCountChange" object:nil];
    });
}

- (void)eventWithSuccess:(BOOL)isSuccess storyId:(NSString *)storyId{
    if (!storyId.length) {
        // 接口返回异常导致没有storyid
        return;
    }
    if (self.postDraftModel.storyType == 0) {
        NSMutableDictionary *params = [NSMutableDictionary new];
        params[JA_Property_RecordDuration] = @([NSString getSeconds:self.postDraftModel.time]);
        //    NSString *categoryId = [self getVoiceParams][@"categoryId"];
        //    params[JA_Property_Category] = [JAConfigManager shareInstance].channelDic[categoryId];
        BOOL isAnonymous = self.postDraftModel.isAnonymous.length?YES:NO;
        params[JA_Property_Anonymous] = @(isAnonymous);
        if (isSuccess) {
            params[JA_Property_PostSucceed] = @(YES);
            params[JA_Property_ContentId] = storyId;
            params[JA_Property_ContentTitle] = self.postDraftModel.content;
            params[JA_Property_storyType] = self.postDraftModel.storyType == 0 ? @"语音":@"图文";
        } else {
            params[JA_Property_PostSucceed] = @(NO);
            params[JA_Property_ContentId] = @"无法获取该属性";
            params[JA_Property_ContentTitle] = self.postDraftModel.content;
            params[JA_Property_storyType] = self.postDraftModel.storyType == 0 ? @"语音":@"图文";
           
        }
        [JASensorsAnalyticsManager sensorsAnalytics_post:params];
    } else if (self.postDraftModel.storyType == 1) {
        
    }
}

@end
