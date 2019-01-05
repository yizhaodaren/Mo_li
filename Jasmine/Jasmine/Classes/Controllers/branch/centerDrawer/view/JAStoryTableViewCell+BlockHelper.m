//
//  JAStoryTableViewCell+BlockHelper.m
//  Jasmine
//
//  Created by xujin on 2018/5/30.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JAStoryTableViewCell+BlockHelper.h"
#import "JAVoicePlayerManager.h"
#import "JADataHelper.h"
#import "JAVoiceCommonApi.h"
#import "JAVoicePersonApi.h"
#import "JAPersonalCenterViewController.h"
#import "JAPersonTopicViewController.h"
#import "JACircleDetailViewController.h"


@implementation JAStoryTableViewCell (BlockHelper)

- (void)setupCommonBlockWithModel:(JANewVoiceModel *)voice superVC:(UIViewController *)superVC {
    @WeakObj(self);
    __weak typeof(superVC) wvc = superVC;
    self.headActionBlock = ^(JAStoryTableViewCell *cell) {    // 个人中心
        @StrongObj(self);
        if ([cell.data.concernType integerValue] == 0) {
            if (self.data.user.isAnonymous && [JAUserInfo userInfo_getUserImfoWithKey:User_Admin].integerValue != JAPOWER) {
                [wvc.view ja_makeToast:@"该用户已匿名，昵称由系统随机生成"];
                return;
            }
            JAPersonalCenterViewController *vc = [[JAPersonalCenterViewController alloc] init];
            JAConsumer *model = [[JAConsumer alloc] init];
            model.userId = voice.user.userId;
            model.name = voice.user.userName;
            model.image = voice.user.avatar;
            vc.personalModel = model;
            [wvc.navigationController pushViewController:vc animated:YES];           
        } else if ([cell.data.concernType integerValue] == 1) {
            if (!cell.data.circle.circleId.length) {
                return;
            }
            JACircleDetailViewController *vc = [JACircleDetailViewController new];
            vc.circleId = cell.data.circle.circleId;
            [wvc.navigationController pushViewController:vc animated:YES];
        }
        
    };
    self.agreeBlock = ^(JAStoryTableViewCell *cell) {
        if (!IS_LOGIN) {
            [JAAPPManager app_modalLogin];
            return;
        }
        @StrongObj(self);
        [self agreeActionWithCell:cell];
    };

    self.topicDetailBlock = ^(NSString *topicName) {
        JAPersonTopicViewController *vc = [[JAPersonTopicViewController alloc] init];
        vc.topicTitle = topicName;
        [wvc.navigationController pushViewController:vc animated:YES];
    };
    // v2.6.0
    self.atPersonBlock = ^(NSString *userName, NSArray *atList) {
        if (userName.length && atList.count) {
            JAPersonalCenterViewController *vc = [[JAPersonalCenterViewController alloc] init];
            vc.personalModel = [JADataHelper getConsumer:userName atList:atList];
            [wvc.navigationController pushViewController:vc animated:YES];
        }
    };
    self.followBlock = ^(JAStoryTableViewCell *cell) {
        @StrongObj(self);
        [self focusCustomer:self.userContentView.followButton userModel:self.data.user];
    };
    self.circleBlock = ^(JAStoryTableViewCell *cell) {
        if (!cell.data.circle.circleId.length) {
            return;
        }
        JACircleDetailViewController *vc = [JACircleDetailViewController new];
        vc.circleId = cell.data.circle.circleId;
        [wvc.navigationController pushViewController:vc animated:YES];
    };
}

- (void)agreeActionWithCell:(JAStoryTableViewCell *)cell {
    JANewVoiceModel *data = cell.data;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userId"] =[JAUserInfo userInfo_getUserImfoWithKey:User_id];
    params[@"actionType"] = @"agree";
    params[@"typeId"] = data.storyId;
    params[@"type"] = @"story";
    [[JAVoiceCommonApi shareInstance] voice_agreeWithParas:params success:^(NSDictionary *result) {
    } failure:^(NSError *error) {
    }];
}

// 关注取消人
- (void)focusCustomer:(UIButton *)focusButton userModel:(JALightUserModel *)userModel
{
    if (!IS_LOGIN) {
        [JAAPPManager app_modalLogin];
        return;
    }
    
    focusButton.userInteractionEnabled = NO;
    if (focusButton.selected) {
        
        // 取消关注
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
        dic[@"concernId"] = userModel.userId;
        
        // 神策数据
        NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
        senDic[JA_Property_BindingType] = @"取消关注";
        senDic[JA_Property_PostId] = userModel.userId;
        senDic[JA_Property_PostName] = userModel.userName;
        senDic[JA_Property_FollowMethod] = @"帖子详情页";
        [JASensorsAnalyticsManager sensorsAnalytics_followPerson:senDic];
        
        [[JAVoicePersonApi shareInstance] voice_personalCancleFocusUseroWithParas:dic success:^(NSDictionary *result) {
            
            NSString *type = [NSString stringWithFormat:@"%@",result[@"friend"][@"friendType"]];
            userModel.friendType = type;
            focusButton.userInteractionEnabled = YES;
            focusButton.selected = NO;
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"id"] = userModel.userId;
            dic[@"status"] = type;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"searchRefreshFocusStatusFalse" object:dic];
            
        } failure:^(NSError *error) {
            focusButton.userInteractionEnabled = YES;
            [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:error.localizedDescription];
        }];
        
        return;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"concernId"] = userModel.userId;
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    
    // 神策数据
    NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
    senDic[JA_Property_BindingType] = @"关注";
    senDic[JA_Property_PostId] = userModel.userId;
    senDic[JA_Property_PostName] = userModel.userName;
    senDic[JA_Property_FollowMethod] = @"帖子详情页";
    [JASensorsAnalyticsManager sensorsAnalytics_followPerson:senDic];
    
    [[JAVoicePersonApi shareInstance] voice_personalFocusUserWithParas:dic success:^(NSDictionary *result) {
        
        NSString *type = [NSString stringWithFormat:@"%@",result[@"friend"][@"friendType"]];
        userModel.friendType = type;
        focusButton.userInteractionEnabled = YES;
        focusButton.selected = YES;
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"id"] = userModel.userId;
        dic[@"status"] = type;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"searchRefreshFocusStatusTrue" object:dic];
        
    } failure:^(NSError *error) {
        focusButton.userInteractionEnabled = YES;
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:error.localizedDescription];
    }];
}

@end
