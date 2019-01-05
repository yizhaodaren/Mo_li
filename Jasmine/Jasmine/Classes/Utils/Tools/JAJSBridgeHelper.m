//
//  JAJSBridgeHelper.m
//  Jasmine
//
//  Created by xujin on 09/03/2018.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JAJSBridgeHelper.h"
#import "JAFunctionToolV.h"
#import "JAPlatformShareManager.h"
#import "JAUserApiRequest.h"

#import "JAPostDetailViewController.h"
#import "JAPersonalCenterViewController.h"
#import "JAPersonalTaskViewController.h"
#import "JAPersonalSharePictureViewController.h"
#import "JAPacketViewController.h"
#import "JAHelperViewController.h"
#import "JAOpenInvitePacketViewController.h"
#import "JAVoiceRecordViewController.h"
#import "JABottomShareView.h"
#import "NSDictionary+NTESJson.h"
#import "JAPersonTopicViewController.h"
#import "JAVoicePlayerManager.h"
#import "JACircleDetailViewController.h"
#import "JAAlbumDetailViewController.h"
#import "JAVoiceReleaseViewController.h"
#import "JAWebViewController.h"

#import "CYLTabBarController.h"

#import "JANewPlayTool.h"
#import "JANewPlaySingleTool.h"
#import "JANewBaseNetRequest.h"

@interface JAJSBridgeHelper()

@end

@implementation JAJSBridgeHelper


#pragma mark - JS调用  web页面需要的用户信息
- (NSString *)activityGetUserInfo
{
    NSMutableDictionary *dic = [NSMutableDictionary new];
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    dic[@"userName"] = [JAUserInfo userInfo_getUserImfoWithKey:User_Name];
    dic[@"userImage"] = [JAUserInfo userInfo_getUserImfoWithKey:User_ImageUrl];
    dic[@"userSex"] = [JAUserInfo userInfo_getUserImfoWithKey:User_Sex];
    dic[@"userBirthday"] = [JAUserInfo userInfo_getUserImfoWithKey:User_Birthday];
    dic[@"userAge"] = [JAUserInfo userInfo_getUserImfoWithKey:User_Age];
    dic[@"userLevel"] = [JAUserInfo userInfo_getUserImfoWithKey:User_LevelId];
    dic[@"userUuid"] = [JAUserInfo userInfo_getUserImfoWithKey:User_uuid];
    dic[@"userScore"] = [JAUserInfo userInfo_getUserImfoWithKey:User_score];
    dic[@"userIncome"] = [JAUserInfo userInfo_getUserImfoWithKey:User_IncomeMoney];
    dic[@"userExpenditure"] = [JAUserInfo userInfo_getUserImfoWithKey:User_expenditureMoney];
    dic[@"userFlower"] = [JAUserInfo userInfo_getUserImfoWithKey:User_MoliFlowerCount];
    dic[@"userLevelScore"] = [JAUserInfo userInfo_getUserImfoWithKey:User_LevelScore];
    dic[@"userTopScore"] = [JAUserInfo userInfo_getUserImfoWithKey:User_TopScore];
    dic[@"appVersion"] = [STSystemHelper getApp_version];
    return [dic mj_JSONString];
}

#pragma mark - JS调用  新版web页面需要调起分享的js方法
- (void)shareWithInfo:(NSString *)jsonString
{
    // 解析数据
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *dic = [jsonString mj_JSONObject];
        
        NSInteger type = [dic jsonInteger:@"type"];
        
        // 新版分享 type
        JABottomShareView *shareView = [[JABottomShareView alloc] initWithShareType:JABottomShareViewTypeOneLine contentType:type twoContentType:JABottomShareTwoContentTypeNormal];
        
        shareView.bottomShareClickButton = ^(JABottomShareClickType clickType, BOOL select, UIButton *button) {
            
            JAShareModel *model = [JAShareModel new];
            model.title = dic[@"title"];
            model.descripe = dic[@"content"];
            model.shareUrl = dic[@"url"];
            model.image = dic[@"logo"];
            
            NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
            if (clickType == JABottomShareClickTypeWX) {
                senDic[JA_Property_InvitationMethod] = @"微信";
                
                [JAPlatformShareManager wxShare:WeiXinShareTypeTimeline shareContent:model domainType:1];
            }else if (clickType == JABottomShareClickTypeWXSession){
                senDic[JA_Property_InvitationMethod] = @"朋友圈";
                
                [JAPlatformShareManager wxShare:WeiXinShareTypeSession shareContent:model domainType:1];
            }else if (clickType == JABottomShareClickTypeQQ){
                senDic[JA_Property_InvitationMethod] = @"qq";
                
                [JAPlatformShareManager qqShare:QQShareTypeFriend shareContent:model domainType:1];
            }else if (clickType == JABottomShareClickTypeQQZone){
                senDic[JA_Property_InvitationMethod] = @"qq空间";
                
                [JAPlatformShareManager qqShare:QQShareTypeZone shareContent:model domainType:1];
            }else if (clickType == JABottomShareClickTypeWB){
                senDic[JA_Property_InvitationMethod] = @"微博";
                
                [JAPlatformShareManager wbShareWithshareContent:model domainType:1];
            }
            
            NSString *activityId = [dic stringForKey:@"adId"];
            NSString *activityTitle = [dic stringForKey:@"head"];
            if (activityId.length && activityTitle.length) {
                senDic[JA_Property_ActivityId] = activityId;
                senDic[JA_Property_ActivityTitle] = activityTitle;
                [JASensorsAnalyticsManager sensorsAnalytics_shareActivity:senDic];
            }
        };
        
        [shareView showBottomShareView];
    });
}

#pragma mark - JS调用 跳转帖子详情
- (void)activityGotoVoiceDetail:(NSString *)voiceId   // 获取js 给的故事id 跳转帖子详情
{
    dispatch_async(dispatch_get_main_queue(), ^{
        JAPostDetailViewController *vc = [[JAPostDetailViewController alloc] init];
        if (voiceId.length) {
            vc.voiceId = voiceId;
            [[self cyl_tabBarController].selectedViewController pushViewController:vc animated:YES];
        }else{
            [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"帖子信息异常"];
        }
    });
}

#pragma mark - JS调用 复制文字
- (void)shareWithCopyWord:(NSString *)jsonString
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIPasteboard *board = [UIPasteboard generalPasteboard];
        NSString *boardString = jsonString;
        [board setString:boardString];
        if (board == nil) {
            [[UIApplication sharedApplication].delegate.window ja_makeToast:@"复制失败"];
        }else {
            [[UIApplication sharedApplication].delegate.window ja_makeToast:@"复制成功"];
        }
    });
}

#pragma mark - JS调用 存储相册
- (void)shareWithStorePicture:(NSString *)jsonString
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSURL *url  =[NSURL URLWithString:jsonString];
        NSData *data = [NSData dataWithContentsOfURL:url];
        //        NSData *data = [[NSData alloc] initWithBase64EncodedString:jsonString options:0];
        // 将二进制转为图片并存到本地
        UIImage *image = [UIImage imageWithData:data];
        [self saveImageToPhotos:image];
    });
    
}
- (void)saveImageToPhotos:(UIImage*)savedImage
{
    UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

// 指定回调方法
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    if(error != NULL){
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"图片保存失败"];
    }else{
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"图片保存成功"];
    }
}

#pragma mark - 打开微信
- (void)shareWithOpenWx
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *headString = @"weixin://";
        BOOL canOpen = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]];
        if(canOpen){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:headString]];
        }else{
            [[UIApplication sharedApplication].delegate.window ja_makeToast:@"请安装微信"];
        }
    });
}

#pragma mark - 分享图片到三方
- (void)shareImageToPlatformWithImage:(NSString *)jsonString // 分享图片到三方
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSDictionary *dic = [jsonString mj_JSONObject];
        
        NSString *imageStr = dic[@"image"];
        NSInteger imageType = [dic[@"type"] integerValue];
        NSString *title = dic[@"title"];
        NSString *subtitle = dic[@"subtitle"];
        
        // 分享
        JAFunctionToolV *shareView = [JAFunctionToolV webshareToolV];
        shareView.shareWitnIndex = ^(NSInteger index) {
            
            if (index == 0) {
                
                [JAPlatformShareManager web_wxShareImage:WeiXinShareTypeSession shareImage:imageStr imageType:imageType title:nil subTitle:nil];
                
            }else if (index == 1){
                
                [JAPlatformShareManager web_wxShareImage:WeiXinShareTypeTimeline shareImage:imageStr imageType:imageType title:nil subTitle:nil];
                
            }else if (index == 2){
                
                [JAPlatformShareManager web_qqShareImage:QQShareTypeFriend shareImage:imageStr imageType:imageType title:title subTitle:subtitle];
                
            }else if (index == 3){
                
                [JAPlatformShareManager web_wbShareImageWithImage:imageStr imageType:imageType title:title subTitle:subtitle];
            }
        };
        [shareView show];
    });
}

#pragma mark - h5跳转app界面
/*
 100 个人中心   ---  需要参数 “actionType = 100”  “userId = xx”  “userName = xx”  “userImage = xx”
 114 任务界面   ---  需要参数 “actionType = 114”
 117 分享收入   ---  需要参数 “actionType = 117”
 110 邀请收徒   ---  需要参数 “actionType = 110”
 118 帮助中心 新手教程  ---  需要参数 “actionType = 118”
 119 帮助中心 视频教程  ---  需要参数 “actionType = 119”
 113 输入邀请码  ---  需要参数 “actionType = 113”
 127 帖子详情  ---  需要参数  “actionType = 127”  “voiceId = xx”
 123 首页     ---  需要参数  “actionType = 123”
 122 录制     ---  需要参数  “actionType = 122”
 128 话题     ---  需要参数  “actionType = 128”  “topicName = xx”
 112 唤醒好友  ---  需要参数  “actionType = 112”
 130 圈子详情  ---  需要参数  “actionType = 130”  “circleId = xx”
 131 专辑详情  ---  需要参数  “actionType = 131”  “subjectId = xx”
 132 图文帖    ---  需要参数  “actionType = 132”
 */
- (void)moliH5Action:(NSString *)jsonString
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *dic = [jsonString mj_JSONObject];
        
        NSString *type = [NSString stringWithFormat:@"%@",dic[@"actionType"]];
        
        if (type.integerValue == 0 || type.integerValue == 100) {
            
            if (!IS_LOGIN) {
                [JAAPPManager app_modalLogin];
                return;
            }
            
            JAPersonalCenterViewController *vc = [[JAPersonalCenterViewController alloc] init];
            JAConsumer *model = [[JAConsumer alloc] init];
            NSString *userid = [NSString stringWithFormat:@"%@",dic[@"userId"]];
            NSString *name = [NSString stringWithFormat:@"%@",dic[@"userName"]];
            NSString *image = [NSString stringWithFormat:@"%@",dic[@"userImage"]];
            if (userid.length) {
                model.userId = userid;
                if (name.length) model.name = name;
                if (image.length) model.image = image;
                vc.personalModel = model;
                [[self cyl_tabBarController].selectedViewController pushViewController:vc animated:YES];
            }else{
                [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"用户信息异常"];
            }
            
        }else if (type.integerValue == 1 || type.integerValue == 114){  // 任务界面
       
            JAPersonalTaskViewController *vc = [[JAPersonalTaskViewController alloc] init];
            vc.fromType = @"web";
            [[self cyl_tabBarController].selectedViewController pushViewController:vc animated:YES];
            //            [[AppDelegateModel getBaseNavigationViewControll] popViewControllerAnimated:YES];
        }else if (type.integerValue == 2 || type.integerValue == 117){
            
            if (!IS_LOGIN) {
                [JAAPPManager app_modalLogin];
                return;
            }
            JAPersonalSharePictureViewController *vc = [[JAPersonalSharePictureViewController alloc] init];
            [[self cyl_tabBarController].selectedViewController pushViewController:vc animated:YES];
            
        }else if (type.integerValue == 3 || type.integerValue == 110){
            
            if (!IS_LOGIN) {
                [JAAPPManager app_modalLogin];
                return;
            }
            JAPacketViewController *vc = [[JAPacketViewController alloc] init];
            [[self cyl_tabBarController].selectedViewController pushViewController:vc animated:YES];
            
        }else if (type.integerValue == 4 || type.integerValue == 118){
            
            if (!IS_LOGIN) {
                [JAAPPManager app_modalLogin];
                return;
            }
//            JAHelperViewController *vc = [[JAHelperViewController alloc] init];
//            vc.currentIndex = 0;
//            [[self cyl_tabBarController].selectedViewController pushViewController:vc animated:YES];
            JAWebViewController *help = [[JAWebViewController alloc] init];
            help.urlString = @"http://www.urmoli.com/views/app/about/helpCenter.html";
            help.titleString = @"帮助中心";
            help.fromType = 1;
            help.enterType = @"帮助中心";
            [[self cyl_tabBarController].selectedViewController pushViewController:help animated:YES];
            
        }else if (type.integerValue == 5 || type.integerValue == 119){
            
            if (!IS_LOGIN) {
                [JAAPPManager app_modalLogin];
                return;
            }
//            JAHelperViewController *vc = [[JAHelperViewController alloc] init];
//            vc.currentIndex = 1;
//            [[self cyl_tabBarController].selectedViewController pushViewController:vc animated:YES];
            JAWebViewController *help = [[JAWebViewController alloc] init];
            help.urlString = @"http://www.urmoli.com/views/app/about/helpCenter.html";
            help.titleString = @"帮助中心";
            help.fromType = 1;
            help.enterType = @"帮助中心";
            [[self cyl_tabBarController].selectedViewController pushViewController:help animated:YES];
            
        }else if (type.integerValue == 6 || type.integerValue == 113){
            
            if (!IS_LOGIN) {
                [JAAPPManager app_modalLogin];
                return;
            }
            // 判断是否可以邀请
            NSString *inviteUid = [JAUserInfo userInfo_getUserImfoWithKey:User_InviteUuid];
            if (inviteUid.length) {
                [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"您已经完成该任务了"];
            }else{
                JAOpenInvitePacketViewController *vc = [[JAOpenInvitePacketViewController alloc] init];
                [[self cyl_tabBarController].selectedViewController pushViewController:vc animated:YES];
            }
        }else if (type.integerValue == 7 || type.integerValue == 127){
            
            JAPostDetailViewController *vc = [[JAPostDetailViewController alloc] init];
            NSString *voiceid = [NSString stringWithFormat:@"%@",dic[@"voiceId"]];
            if (voiceid.length) {
                vc.voiceId = voiceid;
                [[self cyl_tabBarController].selectedViewController pushViewController:vc animated:YES];
            }else{
                [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"帖子信息异常"];
            }
        }else if (type.integerValue == 8 || type.integerValue == 123){

            [[self cyl_tabBarController].selectedViewController popToRootViewControllerAnimated:NO];
            [self cyl_tabBarController].selectedIndex = 0;
            
        }else if (type.integerValue == 9 || type.integerValue == 122){
            JAVoiceRecordViewController *vc = [[JAVoiceRecordViewController alloc] init];
            [[self cyl_tabBarController].selectedViewController pushViewController:vc animated:YES];
        }else if (type.integerValue == 128){   // 话题详情
            
            NSString *topicName = [NSString stringWithFormat:@"%@",dic[@"topicName"]];
            
            JAPersonTopicViewController *vc = [[JAPersonTopicViewController alloc] init];
            if (topicName.length) {
                vc.topicTitle = topicName;
                [[self cyl_tabBarController].selectedViewController pushViewController:vc animated:YES];
            }else{
                [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"话题信息异常"];
            }
            
        }else if (type.integerValue == 112){   // 唤醒好友
            // 唤醒好友
            JAPacketViewController *vc = [[JAPacketViewController alloc] init];
            vc.type = 1;
            vc.callFriend = 1;
            [[self cyl_tabBarController].selectedViewController pushViewController:vc animated:YES];
        }else if (type.integerValue == 130){   // 圈子详情
            
            NSString *circleid = [NSString stringWithFormat:@"%@",dic[@"circleId"]];
            if (circleid.length) {
                JACircleDetailViewController *vc = [[JACircleDetailViewController alloc] init];
                vc.circleId = circleid;
                [[self cyl_tabBarController].selectedViewController pushViewController:vc animated:YES];
            }
        }else if (type.integerValue == 131){   // 专辑详情
            
            NSString *subjectid = [NSString stringWithFormat:@"%@",dic[@"subjectId"]];
            if (subjectid.length) {
                JAAlbumDetailViewController *vc = [[JAAlbumDetailViewController alloc] init];
                vc.subjectId = subjectid;
                [[self cyl_tabBarController].selectedViewController pushViewController:vc animated:YES];
            }
        }else if (type.integerValue == 132){   // 图文贴
            
            JAVoiceReleaseViewController *vc = [JAVoiceReleaseViewController new];
            vc.storyType = 1;
            [[self cyl_tabBarController].selectedViewController pushViewController:vc animated:YES];
        }
    });
}

#pragma mark - 关闭音频
- (void)playToPause
{
    [[JAVoicePlayerManager shareInstance] pause];
    [[JANewPlayTool shareNewPlayTool] playTool_pause];
    [[JANewPlaySingleTool shareNewPlaySingleTool] playSingleTool_pause];
}

#pragma mark - h5启动传值给h5
- (void)getAppStarts {
    NSString *jsFun = [NSString stringWithFormat:@"APP_data('%@')",[self activityGetUserInfo]];
    [self.webView evaluateJavaScript:jsFun completionHandler:^(id _Nullable item, NSError * _Nullable error) {
        
    }];
}

#pragma mark - 2.6.4 新版分享（不带UI）
- (void)shareActive:(NSString *)jsonString
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSDictionary *dic = [jsonString mj_JSONObject];
        NSInteger type = [dic[@"type"] integerValue];
        NSInteger dataType = [dic[@"dataType"] integerValue];
        
        NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
        
        if (type == 1) {
            [self qqFriendShareWithInfo:dic dataType:dataType];
            senDic[JA_Property_InvitationMethod] = @"qq";
        }else if (type == 2){
            [self qqTimelineShareWithInfo:dic dataType:dataType];
            senDic[JA_Property_InvitationMethod] = @"qq空间";
        }else if (type == 3){
            [self wbShareWithInfo:dic dataType:dataType];
            senDic[JA_Property_InvitationMethod] = @"微博";
        }else if (type == 4){
            [self wxFriendShareWithInfo:dic dataType:dataType];
            senDic[JA_Property_InvitationMethod] = @"微信";
        }else if (type == 5){
            [self wxTimelineShareWithInfo:dic dataType:dataType];
            senDic[JA_Property_InvitationMethod] = @"朋友圈";
        }
        
        NSString *activityId = [dic stringForKey:@"activityId"];
        NSString *activityTitle = [dic stringForKey:@"activityTitle"];
        if (activityId.length && activityTitle.length) {
            senDic[JA_Property_ActivityId] = activityId;
            senDic[JA_Property_ActivityTitle] = activityTitle;
            [JASensorsAnalyticsManager sensorsAnalytics_shareActivity:senDic];
        }
        
    });
}

// 分享到微信好友
- (void)wxFriendShareWithInfo:(NSDictionary *)dic dataType:(NSInteger)dataType
{
    if (dataType == 1) {  // 分享一般的url内容
        
        JAShareModel *model = [JAShareModel new];
        model.title = dic[@"title"];
        model.descripe = dic[@"subtitle"];
        model.shareUrl = dic[@"shareUrl"];
        model.image = dic[@"logo"];
        
        [JAPlatformShareManager wxShare:WeiXinShareTypeTimeline shareContent:model domainType:1];
        
    }else if (dataType == 2){  // 分享图片 - url图片
        
        NSString *imageStr = dic[@"imageUrl"];
        NSInteger imageType = 1;
        NSString *title = dic[@"title"];
        NSString *subtitle = dic[@"subtitle"];
        
        [JAPlatformShareManager web_wxShareImage:WeiXinShareTypeTimeline shareImage:imageStr imageType:imageType title:title subTitle:subtitle];
        
    }else if (dataType == 3){  // 分享图片 - base64图片
        
        NSString *imageStr = dic[@"imageBase64"];
        NSInteger imageType = 2;
        NSString *title = dic[@"title"];
        NSString *subtitle = dic[@"subtitle"];
        [JAPlatformShareManager web_wxShareImage:WeiXinShareTypeTimeline shareImage:imageStr imageType:imageType title:title subTitle:subtitle];
        
        
    }else if (dataType == 4){  // 分享音乐类型
        
        JAShareModel *model = [JAShareModel new];
        model.title = dic[@"title"];
        model.descripe = dic[@"subtitle"];
        model.shareUrl = dic[@"shareUrl"];
        model.image = dic[@"logo"];
        model.music = dic[@"audioUrl"];
        [JAPlatformShareManager wxShareMusic:WeiXinShareTypeTimeline shareContent:model domainType:1];
        
    }else if (dataType == 5){  // 分享小程序
        
        JAShareModel *model = [JAShareModel new];
        model.title = dic[@"title"];
        model.descripe = dic[@"subtitle"];
        model.shareUrl = dic[@"shareUrl"];
        model.image = dic[@"logo"];
        model.miniProgramId = dic[@"miniId"];
        model.miniProgramPath = dic[@"miniPath"];
        [JAPlatformShareManager wxShareMiniProgram:WeiXinShareTypeTimeline shareContent:model domainType:1];
    }
    
}
// 分享到朋友圈
- (void)wxTimelineShareWithInfo:(NSDictionary *)dic dataType:(NSInteger)dataType
{
    if (dataType == 1) {  // 分享一般的url内容
        
        JAShareModel *model = [JAShareModel new];
        model.title = dic[@"title"];
        model.descripe = dic[@"subtitle"];
        model.shareUrl = dic[@"shareUrl"];
        model.image = dic[@"logo"];
        
        [JAPlatformShareManager wxShare:WeiXinShareTypeSession shareContent:model domainType:1];
        
    }else if (dataType == 2){  // 分享图片 - url图片
        
        NSString *imageStr = dic[@"imageUrl"];
        NSInteger imageType = 1;
        NSString *title = dic[@"title"];
        NSString *subtitle = dic[@"subtitle"];
        [JAPlatformShareManager web_wxShareImage:WeiXinShareTypeSession shareImage:imageStr imageType:imageType title:title subTitle:subtitle];
        
    }else if (dataType == 3){  // 分享图片 - base64图片
        
        NSString *imageStr = dic[@"imageBase64"];
        NSInteger imageType = 2;
        NSString *title = dic[@"title"];
        NSString *subtitle = dic[@"subtitle"];
        [JAPlatformShareManager web_wxShareImage:WeiXinShareTypeSession shareImage:imageStr imageType:imageType title:title subTitle:subtitle];
        
    }else if (dataType == 4){  // 分享音乐类型
        
        JAShareModel *model = [JAShareModel new];
        model.title = dic[@"title"];
        model.descripe = dic[@"subtitle"];
        model.shareUrl = dic[@"shareUrl"];
        model.image = dic[@"logo"];
        model.music = dic[@"audioUrl"];
        [JAPlatformShareManager wxShareMusic:WeiXinShareTypeSession shareContent:model domainType:1];
        
    }
}
// 分享到QQ好友
- (void)qqFriendShareWithInfo:(NSDictionary *)dic dataType:(NSInteger)dataType
{
    if (dataType == 1) {  // 分享一般的url内容
        
        JAShareModel *model = [JAShareModel new];
        model.title = dic[@"title"];
        model.descripe = dic[@"subtitle"];
        model.shareUrl = dic[@"shareUrl"];
        model.image = dic[@"logo"];
        [JAPlatformShareManager qqShare:QQShareTypeFriend shareContent:model domainType:1];
        
    }else if (dataType == 2){  // 分享图片 - url图片
        
        NSString *imageStr = dic[@"imageUrl"];
        NSInteger imageType = 1;
        NSString *title = dic[@"title"];
        NSString *subtitle = dic[@"subtitle"];
        [JAPlatformShareManager web_qqShareImage:QQShareTypeFriend shareImage:imageStr imageType:imageType title:title subTitle:subtitle];
        
    }else if (dataType == 3){  // 分享图片 - base64图片
        
        NSString *imageStr = dic[@"imageBase64"];
        NSInteger imageType = 2;
        NSString *title = dic[@"title"];
        NSString *subtitle = dic[@"subtitle"];
        [JAPlatformShareManager web_qqShareImage:QQShareTypeFriend shareImage:imageStr imageType:imageType title:title subTitle:subtitle];
        
    }else if (dataType == 4){  // 分享音乐类型
        
        JAShareModel *model = [JAShareModel new];
        model.title = dic[@"title"];
        model.descripe = dic[@"subtitle"];
        model.shareUrl = dic[@"shareUrl"];
        model.image = dic[@"logo"];
        model.music = dic[@"audioUrl"];
        
        [JAPlatformShareManager qqShareMusic:QQShareTypeFriend shareContent:model domainType:1];
        
    }
}
// 分享到QQ空间
- (void)qqTimelineShareWithInfo:(NSDictionary *)dic dataType:(NSInteger)dataType
{
    if (dataType == 1) {  // 分享一般的url内容
        
        JAShareModel *model = [JAShareModel new];
        model.title = dic[@"title"];
        model.descripe = dic[@"subtitle"];
        model.shareUrl = dic[@"shareUrl"];
        model.image = dic[@"logo"];
        
        [JAPlatformShareManager qqShare:QQShareTypeZone shareContent:model domainType:1];
        
    }else if (dataType == 2){  // 分享图片 - url图片
        
        NSString *imageStr = dic[@"imageUrl"];
        NSInteger imageType = 1;
        NSString *title = dic[@"title"];
        NSString *subtitle = dic[@"subtitle"];
        [JAPlatformShareManager web_qqShareImage:QQShareTypeZone shareImage:imageStr imageType:imageType title:title subTitle:subtitle];
        
    }else if (dataType == 3){  // 分享图片 - base64图片
        
        NSString *imageStr = dic[@"imageBase64"];
        NSInteger imageType = 2;
        NSString *title = dic[@"title"];
        NSString *subtitle = dic[@"subtitle"];
        [JAPlatformShareManager web_qqShareImage:QQShareTypeZone shareImage:imageStr imageType:imageType title:title subTitle:subtitle];
        
    }else if (dataType == 4){  // 分享音乐类型
        
        JAShareModel *model = [JAShareModel new];
        model.title = dic[@"title"];
        model.descripe = dic[@"subtitle"];
        model.shareUrl = dic[@"shareUrl"];
        model.image = dic[@"logo"];
        model.music = dic[@"audioUrl"];
        [JAPlatformShareManager qqShareMusic:QQShareTypeZone shareContent:model domainType:1];
        
    }
}
// 分享到微博
- (void)wbShareWithInfo:(NSDictionary *)dic dataType:(NSInteger)dataType
{
    if (dataType == 1) {  // 分享一般的url内容
        
        JAShareModel *model = [JAShareModel new];
        model.title = dic[@"title"];
        model.descripe = dic[@"subtitle"];
        model.shareUrl = dic[@"shareUrl"];
        model.image = dic[@"logo"];
        [JAPlatformShareManager wbShareWithshareContent:model domainType:1];
        
    }else if (dataType == 2){  // 分享图片 - url图片
        
        NSString *imageStr = dic[@"imageUrl"];
        NSInteger imageType = 1;
        NSString *title = dic[@"title"];
        NSString *subtitle = dic[@"subtitle"];
        [JAPlatformShareManager web_wbShareImageWithImage:imageStr imageType:imageType title:title subTitle:subtitle];
        
        
    }else if (dataType == 3){  // 分享图片 - base64图片
        
        NSString *imageStr = dic[@"imageBase64"];
        NSInteger imageType = 2;
        NSString *title = dic[@"title"];
        NSString *subtitle = dic[@"subtitle"];
        [JAPlatformShareManager web_wbShareImageWithImage:imageStr imageType:imageType title:title subTitle:subtitle];
        
        
    }
}

#pragma mark - v3.0.0 将http的header传给前端
- (void)getHttpHeader {
    JANewBaseNetRequest *request = [JANewBaseNetRequest new];
    NSString *httpHeaderJsonString = [request.requestHeaderFieldValueDictionary mj_JSONString];
    NSString *jsFun = [NSString stringWithFormat:@"APP_httpHeader('%@')",httpHeaderJsonString];
    [self.webView evaluateJavaScript:jsFun completionHandler:^(id _Nullable item, NSError * _Nullable error) {
        
    }];
}

@end
