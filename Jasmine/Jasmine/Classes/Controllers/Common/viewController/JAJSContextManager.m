//
//  JAJSContextManager.m
//  Jasmine
//
//  Created by moli-2017 on 2017/10/25.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAJSContextManager.h"
#import "JAFunctionToolV.h"
#import "JAPlatformShareManager.h"
#import "JAPostDetailViewController.h"
#import "JAUserApiRequest.h"
#import "JAPersonalCenterViewController.h"
#import "JAPersonalTaskViewController.h"
#import "JAPersonalSharePictureViewController.h"
#import "JAPacketViewController.h"
#import "JAHelperViewController.h"
#import "JAOpenInvitePacketViewController.h"
#import "JAVoiceRecordViewController.h"
#import "JAReleasePostManager.h"
#import <WXApi.h>
#import "JAVoicePlayerManager.h"
#import "JAWebViewController.h"

@interface JAJSContextManager ()<JSObjcDelegate>

@end

@implementation JAJSContextManager

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
        // 分享
        JAFunctionToolV *shareView = [JAFunctionToolV webshareToolV];
        shareView.shareWitnIndex = ^(NSInteger index) {
            NSLog(@"%ld",index);
            if (index == 0) {                                       // 微信朋友圈
                JAShareModel *model = [[JAShareModel alloc] init];
                model.title = dic[@"title"];
                model.shareUrl = dic[@"url"];
                model.image = dic[@"logo"];
                [JAPlatformShareManager wxShare:WeiXinShareTypeSession shareContent:model domainType:1];
            }else if (index == 1){                                        // 微信好友
                JAShareModel *model = [[JAShareModel alloc] init];
                model.title = dic[@"title"];
                model.descripe = dic[@"content"];
                model.shareUrl = dic[@"url"];
                model.image = dic[@"logo"];
                [JAPlatformShareManager wxShare:WeiXinShareTypeTimeline shareContent:model domainType:1];
            }else if (index == 2){                                           // 手机QQ
                JAShareModel *model = [JAShareModel new];
                model.title = dic[@"title"];
                model.descripe = dic[@"content"];
                model.shareUrl = dic[@"url"];
                model.image = dic[@"logo"];
                [JAPlatformShareManager qqShare:QQShareTypeFriend shareContent:model domainType:1];
            }else if (index == 3){                                              // 微博
                JAShareModel *model = [[JAShareModel alloc] init];
                model.title = dic[@"title"];
                model.shareUrl = dic[@"url"];
                model.image = dic[@"logo"];
                [JAPlatformShareManager wbShareWithshareContent:model domainType:1];
            }
        };
        [shareView show];
    });
}

// 获取分享的url -- 老版的app的分享内容是请求来的
- (void)getShareInfo:(void(^)())finishBlock
{
    [MBProgressHUD showMessage:nil];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"uuid"] = [JAUserInfo userInfo_getUserImfoWithKey:User_uuid];
    
    [[JAUserApiRequest shareInstance] userShareInviteInfo:dic success:^(NSDictionary *result) {
        
        [MBProgressHUD hideHUD];
        
        self.modelDic = result[@"resMap"];
        
        if (finishBlock) {
            finishBlock();
        }
        
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUD];
    }];
}

#pragma mark - JS调用  老版web页面 界面调用分享的js方法
- (void)shareInviteJasmine
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self getShareInfo:^{
            // 分享
            JAFunctionToolV *shareView = [JAFunctionToolV webshareToolV];
            shareView.shareWitnIndex = ^(NSInteger index) {
                NSLog(@"%ld",index);
                if (index == 0) {
                    JAShareModel *model = [[JAShareModel alloc] init];
                    model.title = self.modelDic[@"title"];
                    model.shareUrl = self.modelDic[@"url"];
                    model.image = self.modelDic[@"logo"];
                    [JAPlatformShareManager wxShare:WeiXinShareTypeSession shareContent:model domainType:1];
                }else if (index == 1){
                    JAShareModel *model = [[JAShareModel alloc] init];
                    model.title = self.modelDic[@"title"];
                    model.descripe = self.modelDic[@"content"];
                    model.shareUrl = self.modelDic[@"url"];
                    model.image = self.modelDic[@"logo"];
                    [JAPlatformShareManager wxShare:WeiXinShareTypeTimeline shareContent:model domainType:1];
                    
                }else if (index == 2){
                    JAShareModel *model = [JAShareModel new];
                    model.title = self.modelDic[@"title"];
                    model.descripe = self.modelDic[@"content"];
                    model.shareUrl = self.modelDic[@"url"];
                    model.image = self.modelDic[@"logo"];
                    [JAPlatformShareManager qqShare:QQShareTypeFriend shareContent:model domainType:1];
                }else if (index == 3){
                    JAShareModel *model = [[JAShareModel alloc] init];
                    model.title = self.modelDic[@"title"];
                    model.shareUrl = self.modelDic[@"url"];
                    model.image = self.modelDic[@"logo"];
                    [JAPlatformShareManager wbShareWithshareContent:model domainType:1];
                }
            };
            [shareView show];
            
        }];
        
    });
}

#pragma mark - JS调用 跳转帖子详情
- (void)activityGotoVoiceDetail:(NSString *)voiceId   // 获取js 给的故事id 跳转帖子详情
{
    dispatch_async(dispatch_get_main_queue(), ^{
        JAPostDetailViewController *vc = [[JAPostDetailViewController alloc] init];
        if (voiceId.length) {
            vc.voiceId = voiceId;
            [[AppDelegateModel getBaseNavigationViewControll] pushViewController:vc animated:YES];
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
        if([WXApi isWXAppInstalled]){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"weixin://"]];
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
    0 个人中心
    1 任务界面
    2 分享收入
    3 邀请红包
    4 帮助中心 新手教程
    5 帮助中心 视频教程
    6 输入邀请码
    7 帖子详情
    8 首页
    9 录制
 */
- (void)moliH5Action:(NSString *)jsonString
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *dic = [jsonString mj_JSONObject];
        
        NSString *type = [NSString stringWithFormat:@"%@",dic[@"actionType"]];
        
        if (type.integerValue == 0) {
            
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
                [[AppDelegateModel getBaseNavigationViewControll] pushViewController:vc animated:YES];
            }else{
                [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"用户信息异常"];
            }
            
        }else if (type.integerValue == 1){  // 任务界面
//            if ([JAConfigManager shareInstance].isDebug.integerValue == 1 ||
//                [[JAUserInfo userInfo_getUserImfoWithKey:User_id] isEqualToString:@"7031"]) {
//                return;
//            }
//            if (!IS_LOGIN) {
//                [JAAPPManager app_modalLogin];
//                return;
//            }
//            if ([[JAUserInfo userInfo_getUserImfoWithKey:User_Admin] integerValue] == JAVPOWER) {
//                
//                return;
//            }
            
            JAPersonalTaskViewController *vc = [[JAPersonalTaskViewController alloc] init];
            vc.fromType = @"web";
            [[AppDelegateModel getBaseNavigationViewControll] pushViewController:vc animated:YES];
//            [[AppDelegateModel getBaseNavigationViewControll] popViewControllerAnimated:YES];
        }else if (type.integerValue == 2){
            
            if (!IS_LOGIN) {
                [JAAPPManager app_modalLogin];
                return;
            }
            JAPersonalSharePictureViewController *vc = [[JAPersonalSharePictureViewController alloc] init];
            [[AppDelegateModel getBaseNavigationViewControll] pushViewController:vc animated:YES];
            
        }else if (type.integerValue == 3){
            
            if (!IS_LOGIN) {
                [JAAPPManager app_modalLogin];
                return;
            }
            JAPacketViewController *vc = [[JAPacketViewController alloc] init];
            [[AppDelegateModel getBaseNavigationViewControll] pushViewController:vc animated:YES];
            
        }else if (type.integerValue == 4){
            
            if (!IS_LOGIN) {
                [JAAPPManager app_modalLogin];
                return;
            }
//            JAHelperViewController *vc = [[JAHelperViewController alloc] init];
//            vc.currentIndex = 0;
//            [[AppDelegateModel getBaseNavigationViewControll] pushViewController:vc animated:YES];
            JAWebViewController *help = [[JAWebViewController alloc] init];
            help.urlString = @"http://www.urmoli.com/views/app/about/helpCenter.html";
            help.titleString = @"帮助中心";
            help.fromType = 1;
            help.enterType = @"帮助中心";
            [self.navigationController pushViewController:help animated:YES];
            
        }else if (type.integerValue == 5){
            
            if (!IS_LOGIN) {
                [JAAPPManager app_modalLogin];
                return;
            }
//            JAHelperViewController *vc = [[JAHelperViewController alloc] init];
//            vc.currentIndex = 1;
//            [[AppDelegateModel getBaseNavigationViewControll] pushViewController:vc animated:YES];
            JAWebViewController *help = [[JAWebViewController alloc] init];
            help.urlString = @"http://www.urmoli.com/views/app/about/helpCenter.html";
            help.titleString = @"帮助中心";
            help.fromType = 1;
            help.enterType = @"帮助中心";
            [self.navigationController pushViewController:help animated:YES];
            
        }else if (type.integerValue == 6){
            
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
                [[AppDelegateModel getBaseNavigationViewControll] pushViewController:vc animated:YES];
            }
        }else if (type.integerValue == 7){
            
            JAPostDetailViewController *vc = [[JAPostDetailViewController alloc] init];
            NSString *voiceid = [NSString stringWithFormat:@"%@",dic[@"voiceId"]];
            if (voiceid.length) {
                vc.voiceId = voiceid;
                [[AppDelegateModel getBaseNavigationViewControll] pushViewController:vc animated:YES];
            }else{
                [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"帖子信息异常"];
            }
        }else if (type.integerValue == 8){

            [[AppDelegateModel getBaseNavigationViewControll] popToRootViewControllerAnimated:YES];
            
        }else if (type.integerValue == 9){
            if ([JAReleasePostManager shareInstance].postDraftModel.uploadState == JAUploadUploadingState) {
                [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"你有帖子正在上传中，请上传完毕后再发帖"];
                return;
            }
            JAVoiceRecordViewController *vc = [[JAVoiceRecordViewController alloc] init];
            [[AppDelegateModel getBaseNavigationViewControll] pushViewController:vc animated:YES];
        }
        
    });
}

#pragma mark - 关闭音频
- (void)playToPause
{
    [[JAVoicePlayerManager shareInstance] pause];
    
}
@end
