//
//  JADetailClickManager.m
//  Jasmine
//
//  Created by 刘宏亮 on 2017/12/14.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JADetailClickManager.h"
#import "LCActionSheet.h"

#import "JADeleteReasonModel.h"
#import "JAVoicePersonApi.h"
#import "JAVoiceCommentApi.h"
#import "JAVoiceReplyApi.h"
#import "JAVoiceCommonApi.h"
#import "JAVoiceApi.h"

#import "JACheckNetRequest.h"
#import "JAUserActionNetRequest.h"

#import "NSDictionary+NTESJson.h"
#import "JANotInterestView.h"

@implementation JADetailClickManager

/// 帖子的选项操作 (standbyParameter 为备用参数 传nil即可)
+ (void)detail_modalChooseWindowWithStory:(JANewVoiceModel *)storyModel standbyParameter:(id)standbyParameter needBlock:(void(^)(NSInteger actionType))finishBlock
{
    // 置顶  取消置顶 加精华 取消加精华 收藏 取消收藏 不感兴趣 举报  删除
    if (!IS_LOGIN) {
        [JAAPPManager app_modalLogin];
        return;
    }
    
    NSString *power = [JAUserInfo userInfo_getUserImfoWithKey:User_Admin];
    BOOL userPower = (power.integerValue == 1);
    NSString *own = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    BOOL userOwn = [storyModel.user.userId isEqualToString:own];
    
    NSDictionary *standbyDic = (NSDictionary *)standbyParameter;
    NSString *sourcePage = [standbyDic stringForKey:@"sourcePage"];
    CGFloat noInterestViewY = [standbyDic floatForKey:@"noInterestViewY"];
    BOOL isRecommend = [sourcePage isEqualToString:@"recommend"];
    
    NSMutableArray *buttonTitle = [NSMutableArray array];
    
    if (userPower) {   // 是管理员
        [buttonTitle addObject:@"推荐"];
        [buttonTitle addObject:@"通过"];
        [buttonTitle addObject:@"隐藏"];
        [buttonTitle addObject:(storyModel.circleTop ? @"取消置顶":@"置顶")];
        [buttonTitle addObject:(storyModel.essence ? @"取消加精":@"加精")];
        [buttonTitle addObject:(storyModel.userCollect ? @"取消收藏":@"收藏")];
        if (!userOwn && isRecommend) {
            [buttonTitle addObject:@"不感兴趣"];
        }
        if (!userOwn) {
            [buttonTitle addObject:@"举报"];
        }
        [buttonTitle addObject:@"删除"];
    }else if (userOwn){  // 是自己
        [buttonTitle addObject:(storyModel.userCollect ? @"取消收藏":@"收藏")];
        [buttonTitle addObject:@"删除"];
    }else{   // 路人
        [buttonTitle addObject:(storyModel.userCollect ? @"取消收藏":@"收藏")];
        if (!userOwn && isRecommend) {
            [buttonTitle addObject:@"不感兴趣"];
        }
        [buttonTitle addObject:@"举报"];
    }
    @WeakObj(self);
    LCActionSheet *actionS = [[LCActionSheet alloc] initWithTitle:nil buttonTitles:buttonTitle redButtonIndex:-1 completion:^(NSInteger buttonIndex, LCActionSheet *actionSheet) {
        @StrongObj(self);
        if (buttonIndex >= buttonTitle.count) {
            return;
        }
        NSString *title = buttonTitle[buttonIndex];
        if ([title isEqualToString:@"推荐"]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确定要推荐该帖子吗？" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
            UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                [self requestStory_storyRecommendActionWithModel:storyModel finishBlock:finishBlock];
            }];
            [alert addAction:action1];
            [alert addAction:action2];
            [[AppDelegateModel rootviewController] presentViewController:alert animated:YES completion:nil];
            
        }else if ([title isEqualToString:@"通过"]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确定要通过该帖子吗？" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
            UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                [self requestStory_storyPassActionWithModel:storyModel finishBlock:finishBlock];
            }];
            [alert addAction:action1];
            [alert addAction:action2];
            [[AppDelegateModel rootviewController] presentViewController:alert animated:YES completion:nil];
        }else if ([title isEqualToString:@"隐藏"]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确定要隐藏该帖子吗？" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
            UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                [self requestStory_storyHiddenActionWithModel:storyModel finishBlock:finishBlock];
            }];
            [alert addAction:action1];
            [alert addAction:action2];
            [[AppDelegateModel rootviewController] presentViewController:alert animated:YES completion:nil];
        }else if ([title isEqualToString:@"取消置顶"] || [title isEqualToString:@"置顶"]) {
            [self requestStory_storyTopActionWithModel:storyModel isTop:storyModel.circleTop finishBlock:finishBlock];
        }else if ([title isEqualToString:@"取消加精"] || [title isEqualToString:@"加精"]){
            [self requestStory_storyEssenceActionWithModel:storyModel isEssence:storyModel.essence finishBlock:finishBlock];
        }else if ([title isEqualToString:@"取消收藏"] || [title isEqualToString:@"收藏"]){
            [self requestStory_storyCollectActionWithModel:storyModel isCollect:storyModel.userCollect finishBlock:finishBlock];
        }else if ([title isEqualToString:@"不感兴趣"]){
            [JANotInterestView showNotInterestWithStory:storyModel noInterestViewY:noInterestViewY finishBlock:^(NSString *reason) {
                 [self requestStory_storyLoseInterestWithModel:storyModel reason:reason finishBlock:finishBlock];
            }];
        }else if ([title isEqualToString:@"举报"]){
            [self requestStory_storyReportWithModel:storyModel finishBlock:finishBlock];
        }else if ([title isEqualToString:@"删除"]){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确定要删除吗？" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self requestStory_storyDeleteWithModel:storyModel finishBlock:finishBlock];
            }];
            
            UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [alert addAction:action1];
            [alert addAction:action2];
            [[AppDelegateModel rootviewController] presentViewController:alert animated:YES completion:nil];
        }
    }];
    
    [actionS show];
    
}

/// 评论的选项操作 (standbyParameter 为备用参数 传nil即可)
+ (void)detail_modalChooseWindowWithComment:(JANewCommentModel *)commentModel standbyParameter:(id)standbyParameter needBlock:(void(^)(NSInteger actionType))finishBlock
{
    if (!IS_LOGIN) {
        [JAAPPManager app_modalLogin];
        return;
    }
    
    NSString *power = [JAUserInfo userInfo_getUserImfoWithKey:User_Admin];
    BOOL userPower = (power.integerValue == 1);
    NSString *own = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    BOOL userOwn = [commentModel.user.userId isEqualToString:own];
    
    NSMutableArray *buttonTitle = [NSMutableArray array];
     // 神回复  取消神回复  隐藏  举报  删除  回复
    if (userPower) {   // 是管理员
        [buttonTitle addObject:((commentModel.sort.integerValue == 1) ? @"取消神回复":@"加神回复")];
        [buttonTitle addObject:@"隐藏"];
        [buttonTitle addObject:@"举报"];
        [buttonTitle addObject:@"删除"];
        
    }else if (userOwn){  // 是自己
        [buttonTitle addObject:@"删除"];
        
    }else{   // 路人
        [buttonTitle addObject:@"举报"];
        
    }
    
    LCActionSheet *actionS = [[LCActionSheet alloc] initWithTitle:nil buttonTitles:buttonTitle redButtonIndex:-1 completion:^(NSInteger buttonIndex, LCActionSheet *actionSheet) {
        if (buttonIndex >= buttonTitle.count) {
            return;
        }
        NSString *title = buttonTitle[buttonIndex];
        if ([title isEqualToString:@"取消神回复"] || [title isEqualToString:@"加神回复"]){
            BOOL shen = commentModel.sort.integerValue == 1;
            [self requestComment_commentShenWithModel:commentModel isShen:shen finishBlock:finishBlock];
        }else if ([title isEqualToString:@"隐藏"]){
            [self requestComment_commentHiddenWithModel:commentModel finishBlock:finishBlock];
        }else if ([title isEqualToString:@"举报"]){
            [self requestComment_commentReportWithModel:commentModel finishBlock:finishBlock];
        }else if ([title isEqualToString:@"删除"]){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确定要删除吗？" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self requestComment_commentDeleteWithModel:commentModel finishBlock:finishBlock];
            }];
            
            UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [alert addAction:action1];
            [alert addAction:action2];
            [[AppDelegateModel rootviewController] presentViewController:alert animated:YES completion:nil];
        }
    }];
    
    [actionS show];
   
}

/// 回复的选项操作 (standbyParameter 为备用参数 传nil即可)
+ (void)detail_modalChooseWindowWithReply:(JANewReplyModel *)replyModel standbyParameter:(id)standbyParameter needBlock:(void(^)(NSInteger actionType))finishBlock
{
    if (!IS_LOGIN) {
        [JAAPPManager app_modalLogin];
        return;
    }
    
    NSString *power = [JAUserInfo userInfo_getUserImfoWithKey:User_Admin];
    BOOL userPower = (power.integerValue == 1);
    NSString *own = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    BOOL userOwn = [replyModel.user.userId isEqualToString:own];
    
    NSMutableArray *buttonTitle = [NSMutableArray array];
    // 举报  删除  回复
    if (userPower) {   // 是管理员
        [buttonTitle addObject:@"举报"];
        [buttonTitle addObject:@"删除"];
        
    }else if (userOwn){  // 是自己
        [buttonTitle addObject:@"删除"];
        
    }else{   // 路人
        [buttonTitle addObject:@"举报"];
        
    }
    
    LCActionSheet *actionS = [[LCActionSheet alloc] initWithTitle:nil buttonTitles:buttonTitle redButtonIndex:-1 completion:^(NSInteger buttonIndex, LCActionSheet *actionSheet) {
        if (buttonIndex >= buttonTitle.count) {
            return;
        }
        NSString *title = buttonTitle[buttonIndex];
        if ([title isEqualToString:@"举报"]){
            [self requestReply_replyReportWithModel:replyModel finishBlock:finishBlock];
        }else if ([title isEqualToString:@"删除"]){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确定要删除吗？" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self requestReply_replyDeleteWithModel:replyModel finishBlock:finishBlock];
            }];
            
            UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [alert addAction:action1];
            [alert addAction:action2];
            [[AppDelegateModel rootviewController] presentViewController:alert animated:YES completion:nil];
        }
    }];
    
    [actionS show];
}

// 帖子操作 - 加精（取消加精）
+ (void)requestStory_storyEssenceActionWithModel:(JANewVoiceModel *)model isEssence:(BOOL)essence finishBlock:(void(^)(NSInteger actionType))finishBlock
{
    
    JACheckNetRequest *r = [[JACheckNetRequest alloc] initRequest_essenceStoryWithParameter:nil storyId:model.storyId];
    
    [r baseNetwork_startRequestWithcompletion:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        
        if (responseModel.code != 10000) {
            [[UIApplication sharedApplication].delegate.window ja_makeToast:responseModel.message];
            return;
        }
        
        if (essence) {  // 执行取消加精
            [[UIApplication sharedApplication].delegate.window ja_makeToast:@"取消加精成功"];
            if (finishBlock) {
                finishBlock(4);
            }
        }else{  // 执行加精
            [[UIApplication sharedApplication].delegate.window ja_makeToast:@"加精成功"];
            if (finishBlock) {
                finishBlock(3);
            }
        }
        
    } failure:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        [[UIApplication sharedApplication].delegate.window ja_makeToast:@"网络异常"];
    }];
    
    
}
// 帖子操作 - 推荐
+ (void)requestStory_storyRecommendActionWithModel:(JANewVoiceModel *)model finishBlock:(void(^)(NSInteger actionType))finishBlock
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"id"] = model.storyId;
    dic[@"dataType"] = @"recommend";
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    
    [[JAVoicePersonApi shareInstance] voice_listCheckPostsWithPara:dic success:^(NSDictionary *result) {
        
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"推荐成功"];
    } failure:^(NSError *error) {
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:error.localizedDescription];
    }];
}

// 帖子操作 - 通过
+ (void)requestStory_storyPassActionWithModel:(JANewVoiceModel *)model finishBlock:(void(^)(NSInteger actionType))finishBlock
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"id"] = model.storyId;
    dic[@"dataType"] = @"norecommend";
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    
    [[JAVoicePersonApi shareInstance] voice_listCheckPostsWithPara:dic success:^(NSDictionary *result) {
        
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"通过成功"];
    } failure:^(NSError *error) {
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:error.localizedDescription];
    }];
}

// 帖子操作 - 隐藏
+ (void)requestStory_storyHiddenActionWithModel:(JANewVoiceModel *)model finishBlock:(void(^)(NSInteger actionType))finishBlock
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"id"] = model.storyId;
    dic[@"dataType"] = @"hide";
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    
    [[JAVoicePersonApi shareInstance] voice_listCheckPostsWithPara:dic success:^(NSDictionary *result) {
        
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"隐藏成功"];
    } failure:^(NSError *error) {
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:error.localizedDescription];
    }];
}

// 帖子操作 - 置顶（取消置顶）
+ (void)requestStory_storyTopActionWithModel:(JANewVoiceModel *)model isTop:(BOOL)top finishBlock:(void(^)(NSInteger actionType))finishBlock
{
    JACheckNetRequest *r = [[JACheckNetRequest alloc] initRequest_circleTopWithParameter:nil storyId:model.storyId];
    
    [r baseNetwork_startRequestWithcompletion:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        
        if (responseModel.code != 10000) {
            [[UIApplication sharedApplication].delegate.window ja_makeToast:responseModel.message];
            return;
        }
        
        if (top) {  // 执行取消置顶
            [[UIApplication sharedApplication].delegate.window ja_makeToast:@"取消置顶成功"];
            if (finishBlock) {
                finishBlock(2);
            }
        }else{  // 执行置顶
            [[UIApplication sharedApplication].delegate.window ja_makeToast:@"置顶成功"];
            if (finishBlock) {
                finishBlock(1);
            }
        }
        
    } failure:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        [[UIApplication sharedApplication].delegate.window ja_makeToast:@"网络异常"];
    }];
    
}

// 帖子操作 - 收藏（取消收藏）
+ (void)requestStory_storyCollectActionWithModel:(JANewVoiceModel *)model isCollect:(BOOL)collect finishBlock:(void(^)(NSInteger actionType))finishBlock
{
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"typeId"] = model.storyId;
    dic[@"type"] = JA_STORY_TYPE;
    
    JAUserActionNetRequest *r = [[JAUserActionNetRequest alloc] initRequest_userCollectWithParameter:dic];
    
    [r baseNetwork_startRequestWithcompletion:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        if (responseModel.code != 10000) {
            [[UIApplication sharedApplication].delegate.window ja_makeToast:responseModel.message];
            return;
        }
        NSInteger isCollent = [request.responseObject[@"resBody"][@"isCollent"] integerValue];
        if (isCollent) {
            [[UIApplication sharedApplication].delegate.window ja_makeToast:@"收藏成功"];
            // 获取收藏数 + 1
            NSInteger collect = [JAUserInfo userInfo_getUserImfoWithKey:User_collentCount].integerValue;
            collect = collect + 1;
            [JAUserInfo userInfo_updataUserInfoWithKey:User_collentCount value:[NSString stringWithFormat:@"%ld",collect]];
        }else{
            [[UIApplication sharedApplication].delegate.window ja_makeToast:@"取消收藏成功"];
            // 获取收藏数 - 1
            NSInteger collect = [JAUserInfo userInfo_getUserImfoWithKey:User_collentCount].integerValue;
            collect = collect - 1 > 0 ? (collect - 1) : 0;
            [JAUserInfo userInfo_updataUserInfoWithKey:User_collentCount value:[NSString stringWithFormat:@"%ld",collect]];
        }
        
        if (collect) {  // 执行取消收藏
            if (finishBlock) {
                finishBlock(6);
            }
        }else{  // 执行收藏
            if (finishBlock) {
                finishBlock(5);
            }
        }
        
        // 神策数据
        NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
        senDic[JA_Property_ContentId] = model.storyId;
        senDic[JA_Property_ContentTitle] = model.content;
        senDic[JA_Property_Anonymous] = @(model.user.isAnonymous);
        senDic[JA_Property_RecordDuration] = @([NSString getSeconds:model.time]);
        senDic[JA_Property_PostId] = model.user.userId;
        senDic[JA_Property_PostName] = model.user.userName;
        if (collect) {
            senDic[JA_Property_BindingType] = @"取消收藏";
        } else {
            senDic[JA_Property_BindingType] = @"收藏";
        }
        senDic[JA_Property_storyType] = model.concernType.integerValue == 0 ? @"语音":@"图文";
        NSString *sourcePN = model.sourcePageName;
        NSString *sourceP = model.sourcePage;
        if (sourceP.length) {
            senDic[JA_Property_SourcePage] = sourceP;
        }
        if (sourcePN.length) {
            senDic[JA_Property_SourcePageName] = sourcePN;
        }
        [JASensorsAnalyticsManager sensorsAnalytics_collect:senDic];
        
    } failure:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        
        [[UIApplication sharedApplication].delegate.window ja_makeToast:@"网络异常，稍后再试"];
    }];
   
}

// 帖子操作 - 不感兴趣
+ (void)requestStory_storyLoseInterestWithModel:(JANewVoiceModel *)model reason:(NSString *)reason finishBlock:(void(^)(NSInteger actionType))finishBlock
{
    // 开始请求
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (reason.length) {
        dic[@"reason"] = reason;
    }
    dic[@"type"] = JA_STORY_TYPE;
    dic[@"typeId"] = model.storyId;
    dic[@"appId"] = [[SensorsAnalyticsSDK sharedInstance] distinctId];
    dic[@"userId"] = IS_LOGIN?[JAUserInfo userInfo_getUserImfoWithKey:User_id]:@"0";
    [[JAVoicePersonApi shareInstance] voice_insertDislikeWithParas:dic success:^(NSDictionary *result) {
        [[UIApplication sharedApplication].delegate.window ja_makeToast:@"将减少类似内容推荐"];
        if (finishBlock) {
            finishBlock(7);
        }
        // 神策数据
        NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
        senDic[JA_Property_ContentId] = model.storyId;
        senDic[JA_Property_ContentTitle] = model.content;
        senDic[JA_Property_Anonymous] = @(model.user.isAnonymous);
        senDic[JA_Property_RecordDuration] = @([NSString getSeconds:model.time]);
        senDic[JA_Property_PostId] = model.user.userId;
        senDic[JA_Property_PostName] = model.user.userName;
        NSString *sourcePN = model.sourcePageName;
        NSString *sourceP = model.sourcePage;
        if (sourceP.length) {
            senDic[JA_Property_SourcePage] = sourceP;
        }
        if (sourcePN.length) {
            senDic[JA_Property_SourcePageName] = sourcePN;
        }
        senDic[JA_Property_storyType] = model.concernType.integerValue == 0 ? @"语音":@"图文";
        if (reason.length) {
            senDic[JA_Property_blockedReason] = reason;
        }
        [JASensorsAnalyticsManager sensorsAnalytics_noInterest:senDic];
    } failure:^(NSError *error) {
        
    }];
}

// 帖子操作 - 举报
+ (void)requestStory_storyReportWithModel:(JANewVoiceModel *)model finishBlock:(void(^)(NSInteger actionType))finishBlock
{
    
    NSMutableArray *buttonTitle = [NSMutableArray array];
    
    for (NSInteger i = 0; i < [JAConfigManager shareInstance].deleteReasonArray.count; i++) {

        JADeleteReasonModel *deletemodel = [JAConfigManager shareInstance].deleteReasonArray[i];

        [buttonTitle addObject:deletemodel.content];
    }
    
    LCActionSheet *actionS = [[LCActionSheet alloc] initWithTitle:nil buttonTitles:buttonTitle redButtonIndex:-1 completion:^(NSInteger buttonIndex, LCActionSheet *actionSheet) {
        
        if (buttonIndex < [JAConfigManager shareInstance].deleteReasonArray.count) {
            JADeleteReasonModel *deletemodel = [JAConfigManager shareInstance].deleteReasonArray[buttonIndex];
            // 举报接口
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
            dic[@"type"] = JA_STORY_TYPE;
            dic[@"reportTypeId"] = model.storyId;
            dic[@"content"] = deletemodel.content;
            [[JAVoicePersonApi shareInstance] voice_personalReportUserWithParas:dic success:^(NSDictionary *result) {
                [[UIApplication sharedApplication].delegate.window ja_makeToast:@"举报成功"];
                if (finishBlock) {
                    finishBlock(8);
                }
                // 神策数据
                NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
                senDic[JA_Property_ReportTeason] = deletemodel.content;
                senDic[JA_Property_ReportType] = @"主帖";
                senDic[JA_Property_PostId] = model.user.userId;
                senDic[JA_Property_PostName] = model.user.userName;
                senDic[JA_Property_ContentId] = model.storyId;
                senDic[JA_Property_ContentTitle] = model.content;
                [JASensorsAnalyticsManager sensorsAnalytics_reportPerson:senDic];
            } failure:^(NSError *error) {
            }];
        }
        
    }];
    [actionS show];
}

// 帖子操作 - 删除
+ (void)requestStory_storyDeleteWithModel:(JANewVoiceModel *)model finishBlock:(void(^)(NSInteger actionType))finishBlock
{
    // 判断是不是自己
    NSString *own = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    BOOL userOwn = [model.user.userId isEqualToString:own];
    
    if (userOwn) {
        [self storyDeleteWithModel:model deleteReason:nil finishBlock:finishBlock];
        return;
    }
    
    NSMutableArray *buttonTitle = [NSMutableArray array];
    for (NSInteger i = 0; i < [JAConfigManager shareInstance].deleteReasonArray.count; i++) {
        JADeleteReasonModel *deletemodel = [JAConfigManager shareInstance].deleteReasonArray[i];
        [buttonTitle addObject:deletemodel.content];
    }
    @WeakObj(self);
    LCActionSheet *actionS = [[LCActionSheet alloc] initWithTitle:nil buttonTitles:buttonTitle redButtonIndex:-1 completion:^(NSInteger buttonIndex, LCActionSheet *actionSheet) {
        @StrongObj(self);
        
        if (buttonIndex < [JAConfigManager shareInstance].deleteReasonArray.count) {
            
            JADeleteReasonModel *deletemodel = [JAConfigManager shareInstance].deleteReasonArray[buttonIndex];
            // 删除帖子接口
            [self storyDeleteWithModel:model deleteReason:deletemodel finishBlock:finishBlock];
        }
        
    }];
    [actionS show];
   
}

+ (void)storyDeleteWithModel:(JANewVoiceModel *)model deleteReason:(JADeleteReasonModel *)deleteModel finishBlock:(void(^)(NSInteger actionType))finishBlock
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    dic[@"id"] = model.storyId;
    dic[@"power"] = [JAUserInfo userInfo_getUserImfoWithKey:User_Admin];
    if (deleteModel) {
        dic[@"digest"] = deleteModel.content;
        dic[@"delReasonType"] = deleteModel.type;
    }
    [[JAVoiceApi shareInstance] voice_deleteVoiceWithParas:dic success:^(NSDictionary *result) {
        [[UIApplication sharedApplication].delegate.window ja_makeToast:@"删除成功"];
        
        if (!deleteModel) {   // 自己删除
            NSInteger story = [JAUserInfo userInfo_getUserImfoWithKey:User_storyCount].integerValue;
            story = story - 1 > 0 ? (story - 1) : 0;
            [JAUserInfo userInfo_updataUserInfoWithKey:User_storyCount value:[NSString stringWithFormat:@"%ld",story]];
        }
        
        if (finishBlock) {
            finishBlock(9);
        }
        
        
    } failure:^(NSError *error) {
        [[UIApplication sharedApplication].delegate.window ja_makeToast:error.localizedDescription];
    }];
    
}

// 评论操作 - 加神（取消加神）
+ (void)requestComment_commentShenWithModel:(JANewCommentModel *)model isShen:(BOOL)shen finishBlock:(void(^)(NSInteger actionType))finishBlock
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    dic[@"id"] = model.commentId;
    if (shen) {
        dic[@"sort"] = @(0);
    }else{
        dic[@"sort"] = @(1);
    }
    
    [[JAVoiceCommonApi shareInstance] voice_commentCreamWithParas:dic success:^(NSDictionary *result) {
        if (shen) {  // 执行取消加神
            [[UIApplication sharedApplication].delegate.window ja_makeToast:@"取消加神成功"];
            if (finishBlock) {
                finishBlock(2);
            }
        }else{  // 执行加神
            [[UIApplication sharedApplication].delegate.window ja_makeToast:@"加神成功"];
            if (finishBlock) {
                finishBlock(1);
            }
        }
        
    } failure:^(NSError *error) {
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:error.localizedDescription];
    }];
}
// 评论操作 - 隐藏
+ (void)requestComment_commentHiddenWithModel:(JANewCommentModel *)model finishBlock:(void(^)(NSInteger actionType))finishBlock
{

    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"id"] = model.commentId;
    dic[@"dataType"] = @"sedimentation";
    dic[@"debugFlag"] = @"9999";
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    
    [[JAVoicePersonApi shareInstance] voice_listCheckCommentWithPara:dic success:^(NSDictionary *result) {
        [[UIApplication sharedApplication].delegate.window ja_makeToast:@"隐藏成功"];
        if (finishBlock) {
            finishBlock(3);
        }
    } failure:^(NSError *error) {
        [[UIApplication sharedApplication].delegate.window ja_makeToast:error.localizedDescription];
    }];
    
}

// 评论操作 - 举报
+ (void)requestComment_commentReportWithModel:(JANewCommentModel *)model finishBlock:(void(^)(NSInteger actionType))finishBlock
{
    NSMutableArray *buttonTitle = [NSMutableArray array];
    
    for (NSInteger i = 0; i < [JAConfigManager shareInstance].deleteReasonArray.count; i++) {
        
        JADeleteReasonModel *deletemodel = [JAConfigManager shareInstance].deleteReasonArray[i];
        
        [buttonTitle addObject:deletemodel.content];
    }
    
    LCActionSheet *actionS = [[LCActionSheet alloc] initWithTitle:nil buttonTitles:buttonTitle redButtonIndex:-1 completion:^(NSInteger buttonIndex, LCActionSheet *actionSheet) {
        
        if (buttonIndex < [JAConfigManager shareInstance].deleteReasonArray.count) {
            JADeleteReasonModel *deletemodel = [JAConfigManager shareInstance].deleteReasonArray[buttonIndex];
            // 举报接口
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
            dic[@"type"] = JA_COMMENT_TYPE;
            dic[@"reportTypeId"] = model.commentId;
            dic[@"content"] = deletemodel.content;
            [[JAVoicePersonApi shareInstance] voice_personalReportUserWithParas:dic success:^(NSDictionary *result) {
                [[UIApplication sharedApplication].delegate.window ja_makeToast:@"举报成功"];
                
                if (finishBlock) {
                    finishBlock(4);
                }
                // 神策数据
                NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
                senDic[JA_Property_ReportTeason] = deletemodel.content;
                senDic[JA_Property_ReportType] = @"一级回复";
                senDic[JA_Property_PostId] = model.user.userId;
                senDic[JA_Property_PostName] = model.user.userName;
                senDic[JA_Property_ContentId] = model.commentId;
                senDic[JA_Property_ContentTitle] = model.content;
                [JASensorsAnalyticsManager sensorsAnalytics_reportPerson:senDic];
            } failure:^(NSError *error) {
            }];
        }
        
    }];
    
    [actionS show];
}

// 评论操作 - 删除
+ (void)requestComment_commentDeleteWithModel:(JANewCommentModel *)model finishBlock:(void(^)(NSInteger actionType))finishBlock
{
    NSString *own = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    BOOL userOwn = [model.user.userId isEqualToString:own];
    
    if (userOwn) {
        [self commentDeleteWithModel:model deleteReason:nil finishBlock:finishBlock];
        return;
    }
    
    NSMutableArray *buttonTitle = [NSMutableArray array];
    for (NSInteger i = 0; i < [JAConfigManager shareInstance].deleteReasonArray.count; i++) {
        JADeleteReasonModel *deletemodel = [JAConfigManager shareInstance].deleteReasonArray[i];
        [buttonTitle addObject:deletemodel.content];
    }
    
    LCActionSheet *actionS = [[LCActionSheet alloc] initWithTitle:nil buttonTitles:buttonTitle redButtonIndex:-1 completion:^(NSInteger buttonIndex, LCActionSheet *actionSheet) {
        if (buttonIndex < [JAConfigManager shareInstance].deleteReasonArray.count) {
            JADeleteReasonModel *deletemodel = [JAConfigManager shareInstance].deleteReasonArray[buttonIndex];
            // 删除评论接口
            [self commentDeleteWithModel:model deleteReason:deletemodel finishBlock:finishBlock];
        }
    }];
    [actionS show];
    
}

+ (void)commentDeleteWithModel:(JANewCommentModel *)model deleteReason:(JADeleteReasonModel *)deleteModel finishBlock:(void(^)(NSInteger actionType))finishBlock
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (deleteModel) {
        dic[@"digest"] = deleteModel.content;
        dic[@"delReasonType"] = deleteModel.type;
    }
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    dic[@"id"] = model.commentId;
    dic[@"power"] = [JAUserInfo userInfo_getUserImfoWithKey:User_Admin];
    [[JAVoiceCommentApi shareInstance] voice_deleteVoiceCommentWithParas:dic success:^(NSDictionary *result) {
        [[UIApplication sharedApplication].delegate.window ja_makeToast:@"删除成功"];
        
        if (!deleteModel) {   // 自己删除评论
            NSInteger comment = [JAUserInfo userInfo_getUserImfoWithKey:User_commentCount].integerValue;
            comment = comment - 1 > 0 ? (comment - 1) : 0;
            [JAUserInfo userInfo_updataUserInfoWithKey:User_commentCount value:[NSString stringWithFormat:@"%ld",comment]];
        }
        if (finishBlock) {
            finishBlock(5);
        }
    } failure:^(NSError *error) {
        [[UIApplication sharedApplication].delegate.window ja_makeToast:error.localizedDescription];
    }];
    
}

//// 回复操作 - 隐藏
//+ (void)requestReply_replyHiddenWithModel:(JANewReplyModel *)model finishBlock:(void(^)(NSInteger actionType))finishBlock
//{
//
//    if (finishBlock) {
//        finishBlock(1);
//    }
//}

// 回复操作 - 举报
+ (void)requestReply_replyReportWithModel:(JANewReplyModel *)model finishBlock:(void(^)(NSInteger actionType))finishBlock
{
    
    NSMutableArray *buttonTitle = [NSMutableArray array];
    
    for (NSInteger i = 0; i < [JAConfigManager shareInstance].deleteReasonArray.count; i++) {
        
        JADeleteReasonModel *deletemodel = [JAConfigManager shareInstance].deleteReasonArray[i];
        
        [buttonTitle addObject:deletemodel.content];
    }
    LCActionSheet *actionS = [[LCActionSheet alloc] initWithTitle:nil buttonTitles:buttonTitle redButtonIndex:-1 completion:^(NSInteger buttonIndex, LCActionSheet *actionSheet) {
        
        if (buttonIndex < [JAConfigManager shareInstance].deleteReasonArray.count) {
            JADeleteReasonModel *deletemodel = [JAConfigManager shareInstance].deleteReasonArray[buttonIndex];
            // 举报接口
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
            dic[@"type"] = JA_REPLY_TYPE;
            dic[@"reportTypeId"] = model.replyId;
            dic[@"content"] = deletemodel.content;
            [[JAVoicePersonApi shareInstance] voice_personalReportUserWithParas:dic success:^(NSDictionary *result) {
                [[UIApplication sharedApplication].delegate.window ja_makeToast:@"举报成功"];
                if (finishBlock) {
                    finishBlock(1);
                }
                // 神策数据
                NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
                senDic[JA_Property_ReportTeason] = deletemodel.content;
                senDic[JA_Property_ReportType] = @"二级回复";
                senDic[JA_Property_PostId] = model.user.userId;
                senDic[JA_Property_PostName] = model.user.userName;
                senDic[JA_Property_ContentId] = model.replyId;
                senDic[JA_Property_ContentTitle] = model.content;
                [JASensorsAnalyticsManager sensorsAnalytics_reportPerson:senDic];
                
            } failure:^(NSError *error) {
            }];
        }
        
    }];
    
    [actionS show];
}

// 回复操作 - 删除
+ (void)requestReply_replyDeleteWithModel:(JANewReplyModel *)model finishBlock:(void(^)(NSInteger actionType))finishBlock
{
    NSString *own = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    BOOL userOwn = [model.user.userId isEqualToString:own];
    
    if (userOwn) {
        [self replyDeleteWithModel:model deleteReason:nil finishBlock:finishBlock];
        return;
    }
    
    NSMutableArray *buttonTitle = [NSMutableArray array];
    for (NSInteger i = 0; i < [JAConfigManager shareInstance].deleteReasonArray.count; i++) {
        JADeleteReasonModel *deletemodel = [JAConfigManager shareInstance].deleteReasonArray[i];
        [buttonTitle addObject:deletemodel.content];
    }
    
    LCActionSheet *actionS = [[LCActionSheet alloc] initWithTitle:nil buttonTitles:buttonTitle redButtonIndex:-1 completion:^(NSInteger buttonIndex, LCActionSheet *actionSheet) {
        if (buttonIndex < [JAConfigManager shareInstance].deleteReasonArray.count) {
            JADeleteReasonModel *deletemodel = [JAConfigManager shareInstance].deleteReasonArray[buttonIndex];
            // 删除回复接口
            [self replyDeleteWithModel:model deleteReason:deletemodel finishBlock:finishBlock];
        }
    }];
    [actionS show];
   
}

+ (void)replyDeleteWithModel:(JANewReplyModel *)model deleteReason:(JADeleteReasonModel *)deleteModel finishBlock:(void(^)(NSInteger actionType))finishBlock
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    dic[@"id"] = model.replyId;
    dic[@"power"] = [JAUserInfo userInfo_getUserImfoWithKey:User_Admin];
    if (deleteModel) {
        dic[@"digest"] = deleteModel.content;
        dic[@"delReasonType"] = deleteModel.type;
    }
    [[JAVoiceReplyApi shareInstance] voice_deleteVoiceReplyWithParas:dic success:^(NSDictionary *result) {
        [[UIApplication sharedApplication].delegate.window ja_makeToast:@"删除成功"];
        if (finishBlock) {
            finishBlock(2);
        }
    } failure:^(NSError *error) {
        [[UIApplication sharedApplication].delegate.window ja_makeToast:error.localizedDescription];
    }];
    
}
@end
