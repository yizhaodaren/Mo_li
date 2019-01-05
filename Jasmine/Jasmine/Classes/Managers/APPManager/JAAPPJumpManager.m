//
//  JAAPPJumpManager.m
//  Jasmine
//
//  Created by moli-2017 on 2018/3/16.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAAPPJumpManager.h"

// 站内跳转
#import "JAPersonalCenterViewController.h"  // 个人主页  100
#import "JAEditInfoViewController.h"       // 编辑个人资料 101
#import "JACreditViewController.h"          // 信用积分 102
#import "JAPersonalLevelViewController.h"   // 等级 103
#import "JAVoiceNotifacationViewController.h"  // 消息（通知） 104回复 105点赞 106邀请 107关注
#import "JAMessageViewController.h"            // 私信 108
#import "JAActivityCenterViewController.h"      // 活动中心 109
#import "JAPacketViewController.h"              // 邀请收徒   110邀请徒弟  111 徒弟进贡 112唤醒徒弟
#import "JAOpenInvitePacketViewController.h"    // 输入邀请码  113
#import "JAPersonalTaskViewController.h"        // 任务中心 114
#import "JAPersonIncomeViewController.h"        // 个人收入   115 茉莉花  116 零钱
#import "JAPersonalSharePictureViewController.h"  // 晒收入  117
#import "JAHelperViewController.h"               // 新手指南 118 常见问题 119 视频教程
#import "JASettingViewController.h"              // 设置 120
#import "JADraftViewController.h"               // 草稿箱 121
#import "JAVoiceRecordViewController.h"           // 录音 122
#import "JACenterDrawerViewController.h"           // 首页  123 推荐 124 关注 125 发现  126 最新
#import "JAVoiceCommentDetailViewController.h"    // 帖子详情 127
#import "JAPersonTopicViewController.h"           // 话题详情 128


// 站外跳转
#import "JAWebViewController.h"      // h5  300
#import "JAPlatformShareManager.h"   //  三方
#import "JALoginManager.h"

// 可以跳转的页面
#import "JAVoiceViewController.h"
#import "JAHomeFloatActivityView.h"
#import "JALaunchADManager.h"
#import "JASessionViewController.h"

// 模型
#import "JATaskRowModel.h"
#import "JAShareRegistModel.h"
#import "JAActivityModel.h"
#import "JAActivityFloatModel.h"

// 辅助类
#import "JAReleasePostManager.h"
#import "JAVoiceCommonApi.h"
#import "JAUserApiRequest.h"
#import <WXApi.h>

@interface JAAPPJumpManager ()<PlatformShareDelegate>

@property (nonatomic, strong) NSString *pageClassString;  // 页面类型
@property (nonatomic, weak) JABaseViewController *currentVc;
@property (nonatomic, weak) id model;

@property (nonatomic, assign) NSInteger shareToType;        // 具体的分享类型
/*
    任务界面 1. 分享邀请链接
           2. 分享小程序
 */

@property (nonatomic, weak) MBProgressHUD *currentProgressHUD;


@end

@implementation JAAPPJumpManager

+ (instancetype)shareAppJumpManager
{
    static JAAPPJumpManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil)
        {
            instance = [[JAAPPJumpManager alloc] init];
            
            /*
            @{
              @"100":@"JAPersonalCenterViewController",
              @"101":@"JAEditInfoViewController",
              @"102":@"JACreditViewController",
              @"103":@"JAPersonalLevelViewController",
              @"104":@"JAVoiceNotifacationViewController",
              @"105":@"JAVoiceNotifacationViewController",
              @"106":@"JAVoiceNotifacationViewController",
              @"107":@"JAVoiceNotifacationViewController",
              @"108":@"JAMessageViewController",
              @"109":@"JAActivityCenterViewController",
              @"110":@"JAPacketViewController",
              @"111":@"JAPacketViewController",
              @"112":@"JAPacketViewController",
              @"113":@"JAOpenInvitePacketViewController",
              @"114":@"JAPersonalTaskViewController",
              @"115":@"JAPersonIncomeViewController",
              @"116":@"JAPersonIncomeViewController",
              @"117":@"JAPersonalSharePictureViewController",
              @"118":@"JAHelperViewController",
              @"119":@"JAHelperViewController",
              @"120":@"JASettingViewController",
              @"121":@"JADraftViewController",
              @"122":@"JAVoiceRecordViewController",
              @"123":@"JACenterDrawerViewController",
              @"124":@"JACenterDrawerViewController",
              @"125":@"JACenterDrawerViewController",
              @"126":@"JACenterDrawerViewController",
              @"127":@"JAVoiceCommentDetailViewController",
              @"128":@"JAPersonTopicViewController",
              };
            */
            
        }
    });
    return instance;
}

// 站内跳转
- (void)app_insideJumpWithType:(NSInteger)type
                         model:(id)model
                       superVc:(JABaseViewController *)superVc
                   currentPage:(NSString *)page
{
    self.pageClassString = page;
    self.currentVc = superVc;
    self.model = model;
    
//    if ([NSClassFromString(self.pageClassString) isMemberOfClass:[JAPersonalTaskViewController class]]){   // 任务界面
//
//        if (type == 100) {
//            [self jumpPersonPageWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 101 || type == 0){
//            [self jumpEditPersonInfoWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 102){
//            [self jumpPersonCreditWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 103){
//            [self jumpPersonLevelWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 104){
//            [self jumpYX_Noti_Message_replyWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 105){
//            [self jumpYX_Noti_Message_agreeWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 106){
//            [self jumpYX_Noti_Message_inviteWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 107){
//            [self jumpYX_Noti_Message_focusWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 108){
//            [self jumpMessageWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 109){
//            [self jumpActivityWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 110 || type == 1){
//            [self jumpInviteFriendWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 111){
//            [self jumpInviteFriend_PageOneWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 112 || type == 7){
//            [self jumpInviteFriend_PageTwoWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 113 || type == 5){
//            [self jumpPersonInviteCodeWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 114){
//            [self jumpPersonTaskWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 115){
//            [self jumpPersonIncome_flowerWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 116){
//            [self jumpPersonIncome_moneyWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 117 || type == 2){
//            [self jumpPersonShareIncomeWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 118){
//            [self jumpPersonHelpWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 119){
//            [self jumpPersonHelp_videoWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 120){
//            [self jumpPersonSettingWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 121){
//            [self jumpPersonDrafWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 122 || type == 3){
//            [self jumpRecordWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 123 || type == 4){
//            [self jumpCenterPage_RecommendWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 124){
//            [self jumpCenterPage_FocusWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 125){
//            [self jumpCenterPage_FindWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 126){
//            [self jumpCenterPage_NewWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 127){
//            [self jumpVoiceDetailWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 128){
//            [self jumpTopicDetailWithSuperVc:superVc currentPage:page model:model];
//        }
//
//
//    }else if ([NSClassFromString(self.pageClassString) isMemberOfClass:[JAHomeFloatActivityView class]] ||    [NSClassFromString(self.pageClassString) isMemberOfClass:[JAVoiceViewController class]] ||           [NSClassFromString(self.pageClassString) isMemberOfClass:[JALaunchADManager class]]){  // 首页弹窗  登录页面banner  开屏广告
//
//
//        if (type == 100) {
//            [self jumpPersonPageWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 101){
//            [self jumpEditPersonInfoWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 102){
//            [self jumpPersonCreditWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 103){
//            [self jumpPersonLevelWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 104){
//            [self jumpYX_Noti_Message_replyWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 105){
//            [self jumpYX_Noti_Message_agreeWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 106){
//            [self jumpYX_Noti_Message_inviteWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 107){
//            [self jumpYX_Noti_Message_focusWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 108){
//            [self jumpMessageWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 109){
//            [self jumpActivityWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 110 || type == 3){
//            [self jumpInviteFriendWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 111){
//            [self jumpInviteFriend_PageOneWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 112){
//            [self jumpInviteFriend_PageTwoWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 113){
//            [self jumpPersonInviteCodeWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 114 || type == 2){
//            [self jumpPersonTaskWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 115){
//            [self jumpPersonIncome_flowerWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 116){
//            [self jumpPersonIncome_moneyWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 117){
//            [self jumpPersonShareIncomeWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 118 || type == 4){
//            [self jumpPersonHelpWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 119 || type == 5){
//            [self jumpPersonHelp_videoWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 120){
//            [self jumpPersonSettingWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 121){
//            [self jumpPersonDrafWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 122){
//            [self jumpRecordWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 123){
//            [self jumpCenterPage_RecommendWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 124){
//            [self jumpCenterPage_FocusWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 125){
//            [self jumpCenterPage_FindWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 126){
//            [self jumpCenterPage_NewWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 127 || type == 1){
//            [self jumpVoiceDetailWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 128){
//            [self jumpTopicDetailWithSuperVc:superVc currentPage:page model:model];
//        }
//
//    }else if ([NSClassFromString(self.pageClassString) isMemberOfClass:[JASessionViewController class]]){  // 小秘书
//
//
//        if (type == 100) {
//            [self jumpPersonPageWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 101){
//            [self jumpEditPersonInfoWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 102 || type == 6){
//            [self jumpPersonCreditWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 103 || type == 7){
//            [self jumpPersonLevelWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 104){
//            [self jumpYX_Noti_Message_replyWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 105){
//            [self jumpYX_Noti_Message_agreeWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 106){
//            [self jumpYX_Noti_Message_inviteWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 107){
//            [self jumpYX_Noti_Message_focusWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 108){
//            [self jumpMessageWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 109){
//            [self jumpActivityWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 110 || type == 1){
//            [self jumpInviteFriendWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 111 || type == 10){
//            [self jumpInviteFriend_PageOneWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 112){
//            [self jumpInviteFriend_PageTwoWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 113){
//            [self jumpPersonInviteCodeWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 114){
//            [self jumpPersonTaskWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 115 || type == 11){
//            [self jumpPersonIncome_flowerWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 116){
//            [self jumpPersonIncome_moneyWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 117){
//            [self jumpPersonShareIncomeWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 118 || type == 8){
//            [self jumpPersonHelpWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 119 || type == 9){
//            [self jumpPersonHelp_videoWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 120){
//            [self jumpPersonSettingWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 121){
//            [self jumpPersonDrafWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 122){
//            [self jumpRecordWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 123){
//            [self jumpCenterPage_RecommendWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 124){
//            [self jumpCenterPage_FocusWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 125){
//            [self jumpCenterPage_FindWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 126){
//            [self jumpCenterPage_NewWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 127 || type == 0){
//            [self jumpVoiceDetailWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 128){
//            [self jumpTopicDetailWithSuperVc:superVc currentPage:page model:model];
//        }
//    }else if ([NSClassFromString(self.pageClassString) isMemberOfClass:[AppDelegate class]]){     // 推送
//
//        if (type == 100) {
//            [self jumpPersonPageWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 101){
//            [self jumpEditPersonInfoWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 102){
//            [self jumpPersonCreditWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 103){
//            [self jumpPersonLevelWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 104 || type == 4){
//            [self jumpYX_Noti_Message_replyWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 105){
//            [self jumpYX_Noti_Message_agreeWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 106 || type == 6){
//            [self jumpYX_Noti_Message_inviteWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 107 || type == 5){
//            [self jumpYX_Noti_Message_focusWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 108){
//            [self jumpMessageWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 109 || type == 0){
//            [self jumpActivityWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 110){
//            [self jumpInviteFriendWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 111){
//            [self jumpInviteFriend_PageOneWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 112){
//            [self jumpInviteFriend_PageTwoWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 113){
//            [self jumpPersonInviteCodeWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 114){
//            [self jumpPersonTaskWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 115){
//            [self jumpPersonIncome_flowerWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 116){
//            [self jumpPersonIncome_moneyWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 117){
//            [self jumpPersonShareIncomeWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 118){
//            [self jumpPersonHelpWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 119){
//            [self jumpPersonHelp_videoWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 120){
//            [self jumpPersonSettingWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 121){
//            [self jumpPersonDrafWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 122){
//            [self jumpRecordWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 123 || type == 1){
////            [self jumpCenterPage_RecommendWithSuperVc:superVc currentPage:page model:model]; // 不用跳，默认打开就是
//        }else if (type == 124 || type == 7){
//            [self jumpCenterPage_FocusWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 125){
//            [self jumpCenterPage_FindWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 126){
//            [self jumpCenterPage_NewWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 127 || type == 2){
//            [self jumpVoiceDetailWithSuperVc:superVc currentPage:page model:model];
//        }else if (type == 128){
//            [self jumpTopicDetailWithSuperVc:superVc currentPage:page model:model];
//        }
//
//    }else if ([NSClassFromString(self.pageClassString) isMemberOfClass:[JAWebViewController class]]){
//
//#warning TODO:web跳转没写
//
//    }else{
//
//
//    }
    

    if (type == 100) {
        [self jumpPersonPageWithSuperVc:superVc currentPage:page model:model];
    }else if (type == 101){
        [self jumpEditPersonInfoWithSuperVc:superVc currentPage:page model:model];
    }else if (type == 102){
        [self jumpPersonCreditWithSuperVc:superVc currentPage:page model:model];
    }else if (type == 103){
        [self jumpPersonLevelWithSuperVc:superVc currentPage:page model:model];
    }else if (type == 104){
        [self jumpYX_Noti_Message_replyWithSuperVc:superVc currentPage:page model:model];
    }else if (type == 105){
        [self jumpYX_Noti_Message_agreeWithSuperVc:superVc currentPage:page model:model];
    }else if (type == 106){
        [self jumpYX_Noti_Message_inviteWithSuperVc:superVc currentPage:page model:model];
    }else if (type == 107){
        [self jumpYX_Noti_Message_focusWithSuperVc:superVc currentPage:page model:model];
    }else if (type == 108){
        [self jumpMessageWithSuperVc:superVc currentPage:page model:model];
    }else if (type == 109){
        [self jumpActivityWithSuperVc:superVc currentPage:page model:model];
    }else if (type == 110){
        [self jumpInviteFriendWithSuperVc:superVc currentPage:page model:model];
    }else if (type == 111){
        [self jumpInviteFriend_PageOneWithSuperVc:superVc currentPage:page model:model];
    }else if (type == 112){
        [self jumpInviteFriend_PageTwoWithSuperVc:superVc currentPage:page model:model];
    }else if (type == 113){
        [self jumpPersonInviteCodeWithSuperVc:superVc currentPage:page model:model];
    }else if (type == 114){
        [self jumpPersonTaskWithSuperVc:superVc currentPage:page model:model];
    }else if (type == 115){
        [self jumpPersonIncome_flowerWithSuperVc:superVc currentPage:page model:model];
    }else if (type == 116){
        [self jumpPersonIncome_moneyWithSuperVc:superVc currentPage:page model:model];
    }else if (type == 117){
        [self jumpPersonShareIncomeWithSuperVc:superVc currentPage:page model:model];
    }else if (type == 118){
        [self jumpPersonHelpWithSuperVc:superVc currentPage:page model:model];
    }else if (type == 119){
        [self jumpPersonHelp_videoWithSuperVc:superVc currentPage:page model:model];
    }else if (type == 120){
        [self jumpPersonSettingWithSuperVc:superVc currentPage:page model:model];
    }else if (type == 121){
        [self jumpPersonDrafWithSuperVc:superVc currentPage:page model:model];
    }else if (type == 122){
        [self jumpRecordWithSuperVc:superVc currentPage:page model:model];
    }else if (type == 123){
        [self jumpCenterPage_RecommendWithSuperVc:superVc currentPage:page model:model];
    }else if (type == 124){
        [self jumpCenterPage_FocusWithSuperVc:superVc currentPage:page model:model];
    }else if (type == 125){
        [self jumpCenterPage_FindWithSuperVc:superVc currentPage:page model:model];
    }else if (type == 126){
        [self jumpCenterPage_NewWithSuperVc:superVc currentPage:page model:model];
    }else if (type == 127){
        [self jumpVoiceDetailWithSuperVc:superVc currentPage:page model:model];
    }else if (type == 128){
        [self jumpTopicDetailWithSuperVc:superVc currentPage:page model:model];
    }
    
}

// 站外跳转
/*
 qq : 0 好友
      1 空间
 wx : 0 微信好友
      1 朋友圈
 */

- (void)app_outsideJumpWithType:(NSInteger)type
                          model:(id)model
                        superVc:(JABaseViewController *)superVc
                    currentPage:(NSString *)page
{
    self.pageClassString = page;
    self.currentVc = superVc;
    self.model = model;
    
    if (type == 300 || type == 16 || type == 0 || type == 3) {
        [self open_webWithSuperVc:superVc currentPage:page model:model];
    }else if (type == 301){
        [self openQQ];                           // 打开QQ
    }else if (type == 302){
        [self sharePicTo_qq:0];   // 分享纯图片到qq好友
    }else if (type == 303){
        [self shareTo_qq:0];      // 分享obj到qq好友
    }else if (type == 304){
        [self sharePicTo_qq:1];    // 分享纯图片到qq空间
    }else if (type == 305){
        [self shareTo_qq:1];        // 分享obj到qq空间
    }else if (type == 306){
        [self openQQGroup];                           // 打开QQ群
    }else if (type == 307){
        [self openWX];              // 打开WX
    }else if (type == 308){
        [self sharePicTo_wx:1];       // 分享纯图片到朋友圈
    }else if (type == 309 || type == 8){
        [self shareTo_wx:1];         // 分享obj到朋友圈
    }else if (type == 310){
        [self shareTo_wx:0];         // 分享obj到wx好友
    }else if (type == 311){
        [self sharePicTo_wx:0];       // 分享纯图片到wx好友
    }else if (type == 312 || type == 9){
        [self share_mini];             // 分享小程序
    }else if (type == 313 || type == 6){
        [self bindingWx];               // 绑定微信
    }else if (type == 314){
        [self sharePicTo_wb];        // 分享纯图片到wb
    }else if (type == 315){
        [self shareTo_wb];            // 分享obj到wb
    }

}

#pragma mark - 站内跳转
/// 个人主页  100
- (void)jumpPersonPageWithSuperVc:(JABaseViewController *)superVc currentPage:(NSString *)page model:(id)model
{
    JAPersonalCenterViewController *vc = [[JAPersonalCenterViewController alloc] init];
    [superVc.navigationController pushViewController:vc animated:YES];
}
/// 编辑个人资料 101
- (void)jumpEditPersonInfoWithSuperVc:(JABaseViewController *)superVc currentPage:(NSString *)page model:(id)model
{
    [self needLogin];
    
    JAEditInfoViewController *vc = [[JAEditInfoViewController alloc] init];
    JAConsumer *personalModel = [[JAConsumer alloc] init];
    personalModel.consumerId = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    personalModel.name = [JAUserInfo userInfo_getUserImfoWithKey:User_Name];
    personalModel.image = [JAUserInfo userInfo_getUserImfoWithKey:User_ImageUrl];
    personalModel.address = [JAUserInfo userInfo_getUserImfoWithKey:User_Address];
    personalModel.age = [JAUserInfo userInfo_getUserImfoWithKey:User_Age];
    personalModel.sex = [JAUserInfo userInfo_getUserImfoWithKey:User_Sex];
    personalModel.constellation = [JAUserInfo userInfo_getUserImfoWithKey:User_Constellation];
    personalModel.concernUserCount = [JAUserInfo userInfo_getUserImfoWithKey:User_concernUserCount];
    personalModel.userConsernCount = [JAUserInfo userInfo_getUserImfoWithKey:User_userConsernCount];
    personalModel.agreeCount = [JAUserInfo userInfo_getUserImfoWithKey:User_agree];
    personalModel.uuid = [JAUserInfo userInfo_getUserImfoWithKey:User_uuid];
    personalModel.birthdayName = [JAUserInfo userInfo_getUserImfoWithKey:User_Birthday];
    personalModel.introduce = [JAUserInfo userInfo_getUserImfoWithKey:User_Introduce];
    vc.model = personalModel;
    [superVc.navigationController pushViewController:vc animated:YES];
}
/// 信用积分 102
- (void)jumpPersonCreditWithSuperVc:(JABaseViewController *)superVc currentPage:(NSString *)page model:(id)model
{
    [self needLogin];
    
    JACreditViewController *vc = [[JACreditViewController alloc] init];
    [superVc.navigationController pushViewController:vc animated:YES];
}
/// 等级 103
- (void)jumpPersonLevelWithSuperVc:(JABaseViewController *)superVc currentPage:(NSString *)page model:(id)model
{
    [self needLogin];
    
    JAPersonalLevelViewController *vc = [[JAPersonalLevelViewController alloc] init];
    [superVc.navigationController pushViewController:vc animated:YES];
}
/// 消息（通知） 104回复
- (void)jumpYX_Noti_Message_replyWithSuperVc:(JABaseViewController *)superVc currentPage:(NSString *)page model:(id)model
{
    [self needLogin];
    JAVoiceNotifacationViewController *vc = [[JAVoiceNotifacationViewController alloc] init];
    vc.notiPageType = 0;
    [superVc.navigationController pushViewController:vc animated:NO];
}

/// 105点赞
- (void)jumpYX_Noti_Message_agreeWithSuperVc:(JABaseViewController *)superVc currentPage:(NSString *)page model:(id)model
{
    [self needLogin];
    JAVoiceNotifacationViewController *vc = [[JAVoiceNotifacationViewController alloc] init];
    vc.notiPageType = 1;
    [superVc.navigationController pushViewController:vc animated:NO];
}

/// 106邀请
- (void)jumpYX_Noti_Message_inviteWithSuperVc:(JABaseViewController *)superVc currentPage:(NSString *)page model:(id)model
{
    [self needLogin];
    JAVoiceNotifacationViewController *vc = [[JAVoiceNotifacationViewController alloc] init];
    vc.notiPageType = 2;
    [superVc.navigationController pushViewController:vc animated:NO];
}

/// 107关注
- (void)jumpYX_Noti_Message_focusWithSuperVc:(JABaseViewController *)superVc currentPage:(NSString *)page model:(id)model
{
    [self needLogin];
    JAVoiceNotifacationViewController *vc = [[JAVoiceNotifacationViewController alloc] init];
    vc.notiPageType = 3;
    [superVc.navigationController pushViewController:vc animated:NO];
}

/// 私信 108
- (void)jumpMessageWithSuperVc:(JABaseViewController *)superVc currentPage:(NSString *)page model:(id)model
{
    [self needLogin];
    
    JAMessageViewController *vc = [[JAMessageViewController alloc] init];
    [superVc.navigationController pushViewController:vc animated:YES];
}
/// 活动中心 109
- (void)jumpActivityWithSuperVc:(JABaseViewController *)superVc currentPage:(NSString *)page model:(id)model
{
    [self needLogin];
    JAActivityCenterViewController *vc = [[JAActivityCenterViewController alloc] init];
    [superVc.navigationController pushViewController:vc animated:YES];
}
/// 邀请收徒   110邀请徒弟
- (void)jumpInviteFriendWithSuperVc:(JABaseViewController *)superVc currentPage:(NSString *)page model:(id)model
{
    [self needLogin];
    
    [self noNeedCheck];
    
    JAPacketViewController *vc = [[JAPacketViewController alloc] init];
    [superVc.navigationController pushViewController:vc animated:YES];
}
/// 111 徒弟进贡
- (void)jumpInviteFriend_PageOneWithSuperVc:(JABaseViewController *)superVc currentPage:(NSString *)page model:(id)model
{
    [self needLogin];
    
    JAPacketViewController *vc = [[JAPacketViewController alloc] init];
    vc.type = 1;
    [superVc.navigationController pushViewController:vc animated:YES];
}

/// 112唤醒徒弟
- (void)jumpInviteFriend_PageTwoWithSuperVc:(JABaseViewController *)superVc currentPage:(NSString *)page model:(id)model
{
    
    [self needLogin];
    
    // 唤醒好友
    JAPacketViewController *vc = [[JAPacketViewController alloc] init];
    vc.type = 1;
    vc.callFriend = 1;
    [superVc.navigationController pushViewController:vc animated:YES];
}

/// 输入邀请码  113
- (void)jumpPersonInviteCodeWithSuperVc:(JABaseViewController *)superVc currentPage:(NSString *)page model:(id)model
{
    
    [self needLogin];
    
    // 判断是否可以邀请
    NSString *inviteUid = [JAUserInfo userInfo_getUserImfoWithKey:User_InviteUuid];
    if (inviteUid.length) {
        
        [superVc.view ja_makeToast:@"您已经完成该任务了"];
    }else{
        
        JAOpenInvitePacketViewController *vc = [[JAOpenInvitePacketViewController alloc] init];
        [superVc.navigationController pushViewController:vc animated:YES];
    }
}
/// 任务中心 114  
- (void)jumpPersonTaskWithSuperVc:(JABaseViewController *)superVc currentPage:(NSString *)page model:(id)model
{
    [self noNeedCheck];
    [self needLogin];
    [self noNeedVpower];
    
    JAPersonalTaskViewController *vc = [[JAPersonalTaskViewController alloc] init];
    [superVc.navigationController pushViewController:vc animated:YES];
}
/// 个人收入   115 茉莉花  116 零钱
- (void)jumpPersonIncome_flowerWithSuperVc:(JABaseViewController *)superVc currentPage:(NSString *)page model:(id)model
{
    [self needLogin];
    
    JAPersonIncomeViewController *vc = [[JAPersonIncomeViewController alloc] init];
    [superVc.navigationController pushViewController:vc animated:YES];
}

/// 116 零钱
- (void)jumpPersonIncome_moneyWithSuperVc:(JABaseViewController *)superVc currentPage:(NSString *)page model:(id)model
{
    [self needLogin];
    
    JAPersonIncomeViewController *vc = [[JAPersonIncomeViewController alloc] init];
    [vc jumpRightPage:1];
    [superVc.navigationController pushViewController:vc animated:YES];
}

/// 晒收入  117
- (void)jumpPersonShareIncomeWithSuperVc:(JABaseViewController *)superVc currentPage:(NSString *)page model:(id)model
{
    [self needLogin];
    
    JAPersonalSharePictureViewController *vc = [[JAPersonalSharePictureViewController alloc] init];
    [superVc.navigationController pushViewController:vc animated:YES];
}
/// 新手指南 118 常见问题 119 视频教程
- (void)jumpPersonHelpWithSuperVc:(JABaseViewController *)superVc currentPage:(NSString *)page model:(id)model
{
    [self needLogin];
    JAHelperViewController *vc = [[JAHelperViewController alloc] init];
    vc.currentIndex = 0;
    [superVc.navigationController pushViewController:vc animated:YES];
}

/// 119 视频教程
- (void)jumpPersonHelp_videoWithSuperVc:(JABaseViewController *)superVc currentPage:(NSString *)page model:(id)model
{
    [self needLogin];
    JAHelperViewController *vc = [[JAHelperViewController alloc] init];
    vc.currentIndex = 1;
    [superVc.navigationController pushViewController:vc animated:YES];
}

/// 设置 120
- (void)jumpPersonSettingWithSuperVc:(JABaseViewController *)superVc currentPage:(NSString *)page model:(id)model
{
    [self needLogin];
    
    JASettingViewController *vc = [[JASettingViewController alloc] init];
    [superVc.navigationController pushViewController:vc animated:YES];
}
/// 草稿箱 121
- (void)jumpPersonDrafWithSuperVc:(JABaseViewController *)superVc currentPage:(NSString *)page model:(id)model
{
    [self needLogin];
    
    JADraftViewController *vc = [[JADraftViewController alloc] init];
    [superVc.navigationController pushViewController:vc animated:YES];
}
/// 录音 122
- (void)jumpRecordWithSuperVc:(JABaseViewController *)superVc currentPage:(NSString *)page model:(id)model
{
    [self needLogin];
    
    if ([JAReleasePostManager shareInstance].postDraftModel.uploadState == JAUploadUploadingState) {
        [superVc.view ja_makeToast:@"你有帖子正在上传中，请上传完毕后再发帖"];
        return;
    }
    JAVoiceRecordViewController *vc = [[JAVoiceRecordViewController alloc] init];
    [superVc.navigationController pushViewController:vc animated:YES];
}
/// 首页  123 推荐
- (void)jumpCenterPage_RecommendWithSuperVc:(JABaseViewController *)superVc currentPage:(NSString *)page model:(id)model
{
    if ([NSClassFromString(self.pageClassString) isMemberOfClass:[AppDelegate class]]) {
        // 回到首页
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [[AppDelegateModel rootviewController] closeDrawerAnimated:NO completion:^(BOOL finished) {
                // 设置打开抽屉模式为MMOpenDrawerGestureModeNone，也就是没有任何效果。
                [[AppDelegateModel rootviewController] setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
            }];
            [superVc.navigationController popToRootViewControllerAnimated:NO];
            
            JACenterDrawerViewController *vc = [AppDelegateModel getCenterMenuViewController];
            [vc.titleView setSelectedItemIndex:1];
        });
    }else{
        
        
        JACenterDrawerViewController *vc = [AppDelegateModel getCenterMenuViewController];
        [vc.titleView setSelectedItemIndex:1];
        [superVc.navigationController popToRootViewControllerAnimated:YES];
    }
    
    
}

/// 124 关注
- (void)jumpCenterPage_FocusWithSuperVc:(JABaseViewController *)superVc currentPage:(NSString *)page model:(id)model
{
    
    if ([NSClassFromString(self.pageClassString) isMemberOfClass:[AppDelegate class]]) {
        // 回到首页
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [[AppDelegateModel rootviewController] closeDrawerAnimated:NO completion:^(BOOL finished) {
                // 设置打开抽屉模式为MMOpenDrawerGestureModeNone，也就是没有任何效果。
                [[AppDelegateModel rootviewController] setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
            }];
            [superVc.navigationController popToRootViewControllerAnimated:NO];
            
            JACenterDrawerViewController *vc = [AppDelegateModel getCenterMenuViewController];
            [vc.titleView setSelectedItemIndex:0];
        });
    }else{
        
        
        JACenterDrawerViewController *vc = [AppDelegateModel getCenterMenuViewController];
        [vc.titleView setSelectedItemIndex:0];
        [superVc.navigationController popToRootViewControllerAnimated:YES];
    }
    
}

/// 125 发现
- (void)jumpCenterPage_FindWithSuperVc:(JABaseViewController *)superVc currentPage:(NSString *)page model:(id)model
{
    if ([NSClassFromString(self.pageClassString) isMemberOfClass:[AppDelegate class]]) {
        // 回到首页
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [[AppDelegateModel rootviewController] closeDrawerAnimated:NO completion:^(BOOL finished) {
                // 设置打开抽屉模式为MMOpenDrawerGestureModeNone，也就是没有任何效果。
                [[AppDelegateModel rootviewController] setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
            }];
            [superVc.navigationController popToRootViewControllerAnimated:NO];
            
            JACenterDrawerViewController *vc = [AppDelegateModel getCenterMenuViewController];
            [vc.titleView setSelectedItemIndex:2];
        });
    }else{
        
        
        JACenterDrawerViewController *vc = [AppDelegateModel getCenterMenuViewController];
        [vc.titleView setSelectedItemIndex:2];
        [superVc.navigationController popToRootViewControllerAnimated:YES];
    }
}

/// 126 最新
- (void)jumpCenterPage_NewWithSuperVc:(JABaseViewController *)superVc currentPage:(NSString *)page model:(id)model
{
    if ([NSClassFromString(self.pageClassString) isMemberOfClass:[AppDelegate class]]) {
        // 回到首页
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [[AppDelegateModel rootviewController] closeDrawerAnimated:NO completion:^(BOOL finished) {
                // 设置打开抽屉模式为MMOpenDrawerGestureModeNone，也就是没有任何效果。
                [[AppDelegateModel rootviewController] setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
            }];
            [superVc.navigationController popToRootViewControllerAnimated:NO];
            
            JACenterDrawerViewController *vc = [AppDelegateModel getCenterMenuViewController];
            [vc.titleView setSelectedItemIndex:3];
        });
    }else{
        
        
        JACenterDrawerViewController *vc = [AppDelegateModel getCenterMenuViewController];
        [vc.titleView setSelectedItemIndex:3];
        [superVc.navigationController popToRootViewControllerAnimated:YES];
    }
}
/// 帖子详情 127
- (void)jumpVoiceDetailWithSuperVc:(JABaseViewController *)superVc currentPage:(NSString *)page model:(id)model
{
    if ([NSClassFromString(self.pageClassString) isMemberOfClass:[JAVoiceViewController class]]){  // 首页banner
        
        JAActivityModel *banner = (JAActivityModel *)model;
        
        JAVoiceCommentDetailViewController *vc = [[JAVoiceCommentDetailViewController alloc] init];
        vc.voiceId = banner.url;
        vc.channelId = @"2";
        [superVc.navigationController pushViewController:vc animated:YES];
        
    }else if ([NSClassFromString(self.pageClassString) isMemberOfClass:[JAHomeFloatActivityView class]]){
        
        JAActivityFloatModel *activityFloat = (JAActivityFloatModel *)model;
        
        JAVoiceCommentDetailViewController *vc = [[JAVoiceCommentDetailViewController alloc] init];
        vc.voiceId = activityFloat.url;
        [superVc.navigationController pushViewController:vc animated:YES];
        
    }else if ([NSClassFromString(self.pageClassString) isMemberOfClass:[JASessionViewController class]]){
        
        NSDictionary *dic = (NSDictionary *)model;
        
        JAVoiceCommentDetailViewController *vc = [[JAVoiceCommentDetailViewController alloc] init];
        vc.voiceId = dic[@"typeId"];
        [superVc.navigationController pushViewController:vc animated:YES];
        
    }else if ([NSClassFromString(self.pageClassString) isMemberOfClass:[JALaunchADManager class]]){
        
        JAActivityModel *banner = (JAActivityModel *)model;
        
        JAVoiceCommentDetailViewController *vc = [[JAVoiceCommentDetailViewController alloc] init];
        vc.voiceId = banner.url;
        [superVc.navigationController pushViewController:vc animated:YES];
        
    }else if ([NSClassFromString(self.pageClassString) isMemberOfClass:[AppDelegate class]]){
        
        NSDictionary *dic = (NSDictionary *)model;
        
        JAVoiceCommentDetailViewController *vc = [[JAVoiceCommentDetailViewController alloc] init];
        vc.voiceId = dic[@"typeId"];
        [superVc.navigationController pushViewController:vc animated:YES];
    }
    
}
/// 话题详情 128
- (void)jumpTopicDetailWithSuperVc:(JABaseViewController *)superVc currentPage:(NSString *)page model:(id)model
{
    if ([NSClassFromString(self.pageClassString) isMemberOfClass:[JAVoiceViewController class]]){
        
        JAActivityModel *banner = (JAActivityModel *)model;
        
        JAPersonTopicViewController *vc = [[JAPersonTopicViewController alloc] init];
        vc.topicTitle = banner.url;
        [superVc.navigationController pushViewController:vc animated:YES];
        
    }else if ([NSClassFromString(self.pageClassString) isMemberOfClass:[JASessionViewController class]]){
        
        NSDictionary *dic = (NSDictionary *)model;
        
        JAPersonTopicViewController *vc = [[JAPersonTopicViewController alloc] init];
        vc.topicTitle = dic[@"url"];
        [superVc.navigationController pushViewController:vc animated:YES];
        
    }else if ([NSClassFromString(self.pageClassString) isMemberOfClass:[JALaunchADManager class]]){
        
        JAActivityModel *banner = (JAActivityModel *)model;
        
        JAPersonTopicViewController *vc = [[JAPersonTopicViewController alloc] init];
        vc.topicTitle = banner.url;
        [superVc.navigationController pushViewController:vc animated:YES];
        
    }else if ([NSClassFromString(self.pageClassString) isMemberOfClass:[JAHomeFloatActivityView class]]){
        
        JAActivityFloatModel *activityFloat = (JAActivityFloatModel *)model;
        
        JAPersonTopicViewController *vc = [[JAPersonTopicViewController alloc] init];
        vc.topicTitle = activityFloat.title;
        [superVc.navigationController pushViewController:vc animated:YES];
        
    }else if ([NSClassFromString(self.pageClassString) isMemberOfClass:[JAPersonalTaskViewController class]]){
        
        JATaskRowModel *task = (JATaskRowModel *)model;
        
        JAPersonTopicViewController *vc = [[JAPersonTopicViewController alloc] init];
        vc.topicTitle = task.taskOpenUrl;
        [superVc.navigationController pushViewController:vc animated:YES];
    }else if ([NSClassFromString(self.pageClassString) isMemberOfClass:[AppDelegate class]]){
        
        NSDictionary *dic = (NSDictionary *)model;
        
        JAPersonTopicViewController *vc = [[JAPersonTopicViewController alloc] init];
        vc.topicTitle = dic[@"title"];
        [superVc.navigationController pushViewController:vc animated:YES];
        
    }else if ([NSClassFromString(self.pageClassString) isMemberOfClass:[JAWebViewController class]]){
        
#warning TODO:web跳转没写
        
    }
    
    
}

#pragma mark - 站外跳转
// 打开web
- (void)open_webWithSuperVc:(JABaseViewController *)superVc currentPage:(NSString *)page model:(id)model
{
    [self needLogin];
    
    if ([NSClassFromString(self.pageClassString) isMemberOfClass:[JAPersonalTaskViewController class]]) {
        
        JATaskRowModel *task = (JATaskRowModel *)model;
        
        JAWebViewController *vc = [[JAWebViewController alloc] init];
        vc.urlString = task.taskOpenUrl;
        vc.enterType = @"任务中心";
        [superVc.navigationController pushViewController:vc animated:YES];
        
    }else if ([NSClassFromString(self.pageClassString) isMemberOfClass:[JAVoiceViewController class]]){
        
        JAActivityModel *banner = (JAActivityModel *)model;
        
        JAWebViewController *vc = [[JAWebViewController alloc] init];
        NSString *str = banner.url;
        if ([str isEqualToString:@"http://www.urmoli.com/newmoli/views/app/activity/invitingFriends.html"] && IS_LOGIN) {
            vc.urlString = [NSString stringWithFormat:@"%@?id=%@",str,[JAUserInfo userInfo_getUserImfoWithKey:User_id]];
        }else{
            vc.urlString = str;
        }
        vc.enterType = @"首页banner";
        [superVc.navigationController pushViewController:vc animated:YES];
        
    }else if ([NSClassFromString(self.pageClassString) isMemberOfClass:[JASessionViewController class]]){
        
        NSDictionary *dic = (NSDictionary *)model;
        
        JAWebViewController *vc = [[JAWebViewController alloc] init];
        vc.urlString = dic[@"url"];
        vc.enterType = @"官方私信";
        [superVc.navigationController pushViewController:vc animated:YES];
        
    }else if ([NSClassFromString(self.pageClassString) isMemberOfClass:[JALaunchADManager class]]){
        
        JAActivityModel *banner = (JAActivityModel *)model;
        
        JAWebViewController *vc = [[JAWebViewController alloc] init];
        vc.urlString = banner.url;
        vc.enterType = @"开屏广告";
        [superVc.navigationController pushViewController:vc animated:YES];
        
    }else if ([NSClassFromString(self.pageClassString) isMemberOfClass:[JAHomeFloatActivityView class]]){
        
        JAActivityFloatModel *banner = (JAActivityFloatModel *)model;
        
        JAWebViewController *vc = [[JAWebViewController alloc] init];
        NSString *str = banner.url;
        if ([str isEqualToString:@"http://www.urmoli.com/newmoli/views/app/activity/invitingFriends.html"] && IS_LOGIN) {
            vc.urlString = [NSString stringWithFormat:@"%@?id=%@",str,[JAUserInfo userInfo_getUserImfoWithKey:User_id]];
        }else{
            vc.urlString = str;
        }
        vc.enterType = @"首页弹窗";
        [superVc.navigationController pushViewController:vc animated:YES];
        
    }else if ([NSClassFromString(self.pageClassString) isMemberOfClass:[AppDelegate class]]){
        
        NSDictionary *dic = (NSDictionary *)model;
        
        JAWebViewController *vc = [JAWebViewController new];
        NSString *str = dic[@"url"];
        if ([str isEqualToString:@"http://www.urmoli.com/newmoli/views/app/activity/invitingFriends.html"] && IS_LOGIN) {
            vc.urlString = [NSString stringWithFormat:@"%@?id=%@",str,[JAUserInfo userInfo_getUserImfoWithKey:User_id]];
        }else{
            vc.urlString = str;
        }
        vc.enterType = @"推送";
        [superVc.navigationController pushViewController:vc animated:YES];
        
    }else if ([NSClassFromString(self.pageClassString) isMemberOfClass:[JAWebViewController class]]){
        
#warning TODO:web跳转没写
        
    }
}

/// 打开微信  307
- (void)openWX
{
    [self needLogin];
    
    if([WXApi isWXAppInstalled]){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"weixin://"]];
    }else{
        [[UIApplication sharedApplication].delegate.window ja_makeToast:@"请安装微信"];
    }
}

/// 绑定微信   313
- (void)bindingWx
{
    // 去绑定三方
    [[JALoginManager shareInstance] loginWithType:JALoginType_Wechat];
}


/// 分享到图片WX
- (void)sharePicTo_wx:(NSInteger)type
{
    NSDictionary *dic = (NSDictionary *)self.model;
    
    NSString *imageStr = dic[@"image"];
    NSInteger imageType = [dic[@"type"] integerValue];
   
    [JAPlatformShareManager web_wxShareImage:type shareImage:imageStr imageType:imageType title:nil subTitle:nil];
    
}

/// 分享到WX
- (void)shareTo_wx:(NSInteger)type
{
    if ([NSClassFromString(self.pageClassString) isMemberOfClass:[JAPersonalTaskViewController class]]) {   // 任务
        self.shareToType = 1;
        [self getUserShareInfoToWX];
    }
    
//TODO    NSLog(@"待实现除任务界面微信分享obj");
}


/// 分享小程序  312
- (void)share_mini
{
    if ([NSClassFromString(self.pageClassString) isMemberOfClass:[JAPersonalTaskViewController class]]) {   // 任务
        
        self.shareToType = 2;
        [self getUserShareMiniProgramToWX];
    }
}


/// 分享图片到QQ
- (void)sharePicTo_qq:(NSInteger)type
{
    NSDictionary *dic = (NSDictionary *)self.model;
    
    NSString *imageStr = dic[@"image"];
    NSInteger imageType = [dic[@"type"] integerValue];
    NSString *title = dic[@"title"];
    NSString *subtitle = dic[@"subtitle"];
    
    [JAPlatformShareManager web_qqShareImage:type shareImage:imageStr imageType:imageType title:title subTitle:subtitle];
    
}

/// 分享到QQ  
- (void)shareTo_qq:(NSInteger)type
{
//TODO    NSLog(@"待实现QQ分享obj");
}

/// 打开QQ  301
- (void)openQQ
{
    
    [self needLogin];
    
    //是否安装QQ
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"mqq://"]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mqq://"]];
    }else{
        [[UIApplication sharedApplication].delegate.window ja_makeToast:@"请安装QQ"];
    }
  
}

/// 打开QQ群  306
- (void)openQQGroup
{
    [self needLogin];
    
    NSString *urlStr = [NSString stringWithFormat:@"mqqapi://card/show_pslcard?src_type=internal&version=1&uin=%@&key=%@&card_type=group&source=external", [JAConfigManager shareInstance].QQGroup,@"e9861618c877e19711d8f2582cba5bd4"];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    if([[UIApplication sharedApplication] canOpenURL:url]){
        
        [[UIApplication sharedApplication] openURL:url];
    }else{
        [[UIApplication sharedApplication].delegate.window ja_makeToast:@"打开失败"];
    }
}


/// 分享到图片WB   314
- (void)sharePicTo_wb
{
    NSDictionary *dic = (NSDictionary *)self.model;
    
    NSString *imageStr = dic[@"image"];
    NSInteger imageType = [dic[@"type"] integerValue];
    NSString *title = dic[@"title"];
    NSString *subtitle = dic[@"subtitle"];
    [JAPlatformShareManager web_wbShareImageWithImage:imageStr imageType:imageType title:title subTitle:subtitle];
}

/// 分享到WB  315
- (void)shareTo_wb
{
//TODO    NSLog(@"待实现微博分享obj");
}

#pragma mark - 判断是否登录
- (void)noNeedCheck   // 过滤审核
{
    if ([JAConfigManager shareInstance].isDebug.integerValue == 1 ||
        [[JAUserInfo userInfo_getUserImfoWithKey:User_id] isEqualToString:@"7031"]) {
        return;
    }
}

- (void)needLogin   // 需要登录
{
    if (!IS_LOGIN) {
        [JAAPPManager app_modalLogin];
        return;
    }
}

- (void)noNeedVpower   // 过滤daV
{
    if ([[JAUserInfo userInfo_getUserImfoWithKey:User_Admin] integerValue] == JAVPOWER) {
        
        return;
    }
}

#pragma mark - 回调监听
- (void)qqShare:(NSString *)error
{
    if (error == nil) {
        
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享成功"];
        if ([NSClassFromString(self.pageClassString) isMemberOfClass:[JAVoiceViewController class]]){
            
        }else if ([NSClassFromString(self.pageClassString) isMemberOfClass:[JASessionViewController class]]){
            
            
        }else if ([NSClassFromString(self.pageClassString) isMemberOfClass:[JALaunchADManager class]]){
            
            
            
        }else if ([NSClassFromString(self.pageClassString) isMemberOfClass:[JAHomeFloatActivityView class]]){
            
            
            
        }else if ([NSClassFromString(self.pageClassString) isMemberOfClass:[JAPersonalTaskViewController class]]){
            
            
        }else if ([NSClassFromString(self.pageClassString) isMemberOfClass:[JAWebViewController class]]){
            
        }else if ([NSClassFromString(self.pageClassString) isMemberOfClass:[AppDelegate class]]){
            
        }
    }else{
        
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享失败"];
    }
}

- (void)wbShare:(int)code
{
    if (code == 0) {
        
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享成功"];
        // 分享邀请链接成功的回调
        if ([NSClassFromString(self.pageClassString) isMemberOfClass:[JAVoiceViewController class]]){
            
        }else if ([NSClassFromString(self.pageClassString) isMemberOfClass:[JASessionViewController class]]){
            
            
        }else if ([NSClassFromString(self.pageClassString) isMemberOfClass:[JALaunchADManager class]]){
            
            
            
        }else if ([NSClassFromString(self.pageClassString) isMemberOfClass:[JAHomeFloatActivityView class]]){
            
            
            
        }else if ([NSClassFromString(self.pageClassString) isMemberOfClass:[JAPersonalTaskViewController class]]){
            
           
        }else if ([NSClassFromString(self.pageClassString) isMemberOfClass:[JAWebViewController class]]){
            
        }else if ([NSClassFromString(self.pageClassString) isMemberOfClass:[AppDelegate class]]){
            
        }
    }else if (code == -1){
        
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享取消"];
    }else if (code == -2){
        
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享发送失败，请重试"];
    }else if (code == -3){
        
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"授权失败，请重试"];
    }else if (code == -8){
        
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享失败"];
    }else if (code == -99){
        
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"请求无效"];
    }else{
        
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享失败"];
    }
}

- (void)wxShare:(int)code   // 分享邀请链接 成功后才算完成任务
{
    if (code == 0) {
        // 分享邀请链接成功的回调
        if ([NSClassFromString(self.pageClassString) isMemberOfClass:[JAVoiceViewController class]]){
            
        }else if ([NSClassFromString(self.pageClassString) isMemberOfClass:[JASessionViewController class]]){
  
            
        }else if ([NSClassFromString(self.pageClassString) isMemberOfClass:[JALaunchADManager class]]){
            
           
            
        }else if ([NSClassFromString(self.pageClassString) isMemberOfClass:[JAHomeFloatActivityView class]]){
            
            
            
        }else if ([NSClassFromString(self.pageClassString) isMemberOfClass:[JAPersonalTaskViewController class]]){
            
            if (self.shareToType == 1) {
                
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
                dic[@"type"] = @"0";
                [[JAVoiceCommonApi shareInstance] voice_appShareRegistTaskWithParas:dic success:^(NSDictionary *result) {
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"taskFinish_refresh" object:nil];
                } failure:^(NSError *error) {
                    
                }];
            }
        }else if ([NSClassFromString(self.pageClassString) isMemberOfClass:[JAWebViewController class]]){
            

            
        }else if ([NSClassFromString(self.pageClassString) isMemberOfClass:[AppDelegate class]]){
            
        }
        
    }else if (code == -1) {
        
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"微信未识别的错误类型，请重试"];
    }else if (code == -2) {
        
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享取消"];
    }else if (code == -3) {
        
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享发送失败，请重试"];
    }else if (code == -4) {
        
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"授权失败，请重试"];
    }else if (code == -5) {
        
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"微信不支持"];
    }else{
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享失败"];
    }
}


#pragma mark - 网络请求
#pragma mark - 获取分享邀请链接
- (void)getUserShareInfoToWX
{
    self.currentProgressHUD = [MBProgressHUD showMessage:nil toView:self.currentVc.view];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"uuid"] = [JAUserInfo userInfo_getUserImfoWithKey:User_uuid];
    [[JAUserApiRequest shareInstance] userShareInviteInfo:param success:^(NSDictionary *result) {
        [self.currentProgressHUD hideAnimated:NO];
        NSDictionary *resultDic = result[@"resMap"];
        if (resultDic) {
            
            JAShareRegistModel *shareRegisetModel = [JAShareRegistModel mj_objectWithKeyValues:result[@"resMap"]];
            
            AppDelegate *appDelegate = [AppDelegate sharedInstance];
            appDelegate.shareDelegate = self;
            
            JAShareModel *model = [[JAShareModel alloc] init];
            model.title = shareRegisetModel.title;
            model.shareUrl = shareRegisetModel.url;
            model.image = shareRegisetModel.logo;
            [JAPlatformShareManager wxShare:WeiXinShareTypeSession shareContent:model domainType:1];
            
        }
    } failure:^(NSError *error) {
        [self.currentProgressHUD hideAnimated:NO];
        [self.currentVc.view ja_makeToast:@"获取分享信息失败，请重试"];
    }];
}

#pragma mark - 获取分享小程序的分享链接
- (void)getUserShareMiniProgramToWX
{
    self.currentProgressHUD = [MBProgressHUD showMessage:nil toView:self.currentVc.view];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"type"] = @"samll_routine_configuration";
    // 获取分享小程序的网络请求
    [[JAUserApiRequest shareInstance] userShareMiniInfo:param success:^(NSDictionary *result) {
        [self.currentProgressHUD hideAnimated:NO];
        NSDictionary *resultDic = result[@"resMap"];
        if (resultDic) {
            
            JAShareRegistModel *shareRegisetModel = [JAShareRegistModel mj_objectWithKeyValues:result[@"resMap"]];
            
            AppDelegate *appDelegate = [AppDelegate sharedInstance];
            appDelegate.shareDelegate = self;
            
            JAShareModel *model = [[JAShareModel alloc] init];
            model.title = shareRegisetModel.title;
            model.descripe = shareRegisetModel.content;
            model.shareUrl = shareRegisetModel.url;
            model.image = shareRegisetModel.logo;
            model.miniProgramId = shareRegisetModel.miniProgramId;
            model.miniProgramPath = shareRegisetModel.miniProgramPath;
            [JAPlatformShareManager wxShareMiniProgram:WeiXinShareTypeTimeline shareContent:model domainType:1];
            
            // 点了分享就算 - 分享小程序成功
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
            dic[@"type"] = @"1";
            [[JAVoiceCommonApi shareInstance] voice_appShareRegistTaskWithParas:dic success:^(NSDictionary *result) {
                
            } failure:^(NSError *error) {
                
            }];
            
        }
    } failure:^(NSError *error) {
        [self.currentProgressHUD hideAnimated:NO];
        [self.currentVc.view ja_makeToast:@"获取分享信息失败，请重试"];
    }];
}
@end
