//
//  JAPacketInviteFriendViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2017/8/20.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAPacketInviteFriendViewController.h"
#import "JAPaddingLabel.h"
#import "JAPlatformShareManager.h"
#import "JAUserApiRequest.h"
#import <MessageUI/MessageUI.h>
#import "JAWebViewController.h"
#import "JAShareRegistModel.h"
#import "JASwitchDefine.h"
#import "JAPersonalSharePictureViewController.h"
#import "JAInviteFriendRuleView.h"

@interface JAPacketInviteFriendViewController ()<MFMessageComposeViewControllerDelegate>

//@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UIView *buttonView;
@property (nonatomic, weak) UIButton *qqButton;     // QQ
@property (nonatomic, weak) UIButton *wxButton;     // 微信
@property (nonatomic, weak) UIButton *msgButton;    // 短信
@property (nonatomic, weak) UIButton *faceButton;   // 面对面
@property (nonatomic, weak) UIButton *flockButton;  // 群
@property (nonatomic, weak) UIButton *wxSessionButton; // 朋友圈
@property (nonatomic, weak) UIButton *inviteCodeButton;
@property (nonatomic, weak) UIButton *inviteCourseButton;  // 邀请教程

@property (nonatomic, weak) UIView *moreActionView;
@property (nonatomic, weak) UIButton *showIncomeButton;
@property (nonatomic, weak) UIButton *awakeButton;

@property (nonatomic, weak) UIImageView *bottomImageView;
@property (nonatomic, weak) JAPaddingLabel *label1;
@property (nonatomic, weak) JAPaddingLabel *label2;
@property (nonatomic, weak) UIButton *ruleButton;

@property (nonatomic, strong) NSString *urlStr;
@property (nonatomic, strong) NSArray *textArray;

@property (nonatomic, strong) NSString *shareError;
@end

@implementation JAPacketInviteFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupInviteFriendUI];

    self.shareError = @"获取分享信息失败，请重试";
    
    // 获取邀请链接
    [self getUserShareInfo];
    
    // 获取邀请规则
    [self getInviteRule];
}

// 不加未缓存的情况
- (void)getUserShareInfo
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"uuid"] = [JAUserInfo userInfo_getUserImfoWithKey:User_uuid];
    [[JAUserApiRequest shareInstance] userShareInviteInfo:param success:^(NSDictionary *result) {
        NSDictionary *resultDic = result[@"resMap"];
        if (resultDic) {
            self.shareError = nil;
            JAShareRegistModel *model = [JAShareRegistModel mj_objectWithKeyValues:result[@"resMap"]];
            [JAConfigManager shareInstance].shareRegistModel = model;
        }
    } failure:^(NSError *error) {
    }];
}

/// 获取规则
- (void)getInviteRule
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"dataType"] = @"22";
    [[JAUserApiRequest shareInstance] userInviteRuleInfo:param success:^(NSDictionary *result) {
        
        NSArray *arr = result[@"urlList"];
        self.urlStr = arr.firstObject[@"content"];
        
        self.textArray = result[@"textList"];
        
        if (self.textArray.count && self.textArray.count > 1) {
            NSString *text1 = self.textArray[0][@"content"];
            NSArray *keyArr1 = [self getKeyWordArray:self.textArray[0][@"keyContent"]];
            
            NSString *text2 = self.textArray[1][@"content"];
            NSArray *keyArr2 = [self getKeyWordArray:self.textArray[1][@"keyContent"]];
            
            [self.label1 setAttributedText:[self attributedString:text1 wordArray:keyArr1]];
            [self.label2 setAttributedText:[self attributedString:text2 wordArray:keyArr2]];
        }
        
        [self.view layoutIfNeeded];
        [self.view setNeedsLayout];
    } failure:^(NSError *error) {
    }];
}

- (NSArray *)getKeyWordArray:(NSString *)keyWord
{
    if (keyWord.length) {
        return [keyWord componentsSeparatedByString:@","];
    }else{
        return nil;
    }
}

- (NSMutableAttributedString *)attributedString:(NSString *)text wordArray:(NSArray *)keyWordArr
{
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:text];
    
    for (NSInteger i = 0; i < keyWordArr.count; i++) {
        
        NSString *keyWord = keyWordArr[i];
        // 获取关键字的位置
        NSRange rang = [text rangeOfString:keyWord];
        
        [attr addAttribute:NSForegroundColorAttributeName value:HEX_COLOR(0xFF7054) range:rang];
    }
    
    return attr;
}

// 加缓存的情况
//- (void)setInviteInfo {
//    if (IS_LOGIN) {
//        NSString *uuid = [JAUserInfo userInfo_getUserImfoWithKey:User_uuid];
//        NSString *filePath = [NSString ja_getPlistFilePath:[NSString stringWithFormat:@"/ShareRegistInfoDefault_%@.plist",uuid]];
//        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
//        if (!dic) {
//            [MBProgressHUD showMessage:@""];
//            NSMutableDictionary *param = [NSMutableDictionary dictionary];
//            param[@"uuid"] = uuid;
//            [[JAUserApiRequest shareInstance] userShareInviteInfo:param success:^(NSDictionary *result) {
//                [MBProgressHUD hideHUD];
//                NSDictionary *resultDic = result[@"resMap"];
//                if (resultDic) {
//
//                    JAShareRegistModel *model = [JAShareRegistModel mj_objectWithKeyValues:result[@"resMap"]];
//                    [JAConfigManager shareInstance].shareRegistModel = model;
//                    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:result];
//                    dictionary[@"version"] = @(0);
//                    [dictionary writeToFile:filePath atomically:YES];
//                }
//
//            } failure:^(NSError *error) {
//                [MBProgressHUD hideHUD];
//            }];
//        } else {
//            JAShareRegistModel *model = [JAShareRegistModel mj_objectWithKeyValues:dic[@"resMap"]];
//            [JAConfigManager shareInstance].shareRegistModel = model;
//        }
//    }
//}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.titleView.selectedItemIndex == 0) {
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[JA_Property_ScreenName] = @"邀请收徒";
        [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:dic];
    }
}

- (void)setupInviteFriendUI
{
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    _scrollView = scrollView;
    [self.view addSubview:scrollView];
    
    UIButton *inviteCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _inviteCodeButton = inviteCodeButton;
    NSString *str = [NSString stringWithFormat:@"收徒邀请码 %@",[JAUserInfo userInfo_getUserImfoWithKey:User_uuid]];
    [inviteCodeButton setTitle:str forState:UIControlStateNormal];
    [inviteCodeButton setTitleColor:HEX_COLOR(0x4A90E2) forState:UIControlStateNormal];
    inviteCodeButton.titleLabel.font = JA_REGULAR_FONT(14);
    [inviteCodeButton addTarget:self action:@selector(clickCopyInviteCode:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:inviteCodeButton];

    UIButton *inviteCourseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _inviteCourseButton = inviteCourseButton;
    [inviteCourseButton setTitle:@"查看邀请收徒教程" forState:UIControlStateNormal];
    [inviteCourseButton setTitleColor:HEX_COLOR(JA_BlackSubTitle) forState:UIControlStateNormal];
    inviteCourseButton.titleLabel.font = JA_REGULAR_FONT(13);
    inviteCourseButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    [inviteCourseButton addTarget:self action:@selector(seeInviteCourse:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:inviteCourseButton];
    
    UIView *buttonView = [[UIView alloc] init];
    _buttonView = buttonView;
    [scrollView addSubview:buttonView];
    
    UIButton *qqButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _qqButton = qqButton;
    [qqButton setImage:[UIImage imageNamed:@"mine_packet_qq"] forState:UIControlStateNormal];
    [qqButton setTitle:@"QQ邀请" forState:UIControlStateNormal];
    [qqButton setTitleColor:HEX_COLOR(0x4a4a4a) forState:UIControlStateNormal];
    qqButton.titleLabel.font = JA_REGULAR_FONT(13);
    [qqButton addTarget:self action:@selector(clickQQ) forControlEvents:UIControlEventTouchUpInside];
    [buttonView addSubview:qqButton];
    
    UIButton *wxButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _wxButton = wxButton;
    [wxButton setImage:[UIImage imageNamed:@"mine_packet_wx"] forState:UIControlStateNormal];
    [wxButton setTitle:@"微信邀请" forState:UIControlStateNormal];
    [wxButton setTitleColor:HEX_COLOR(0x4a4a4a) forState:UIControlStateNormal];
    wxButton.titleLabel.font = JA_REGULAR_FONT(13);
    [wxButton addTarget:self action:@selector(clickWX) forControlEvents:UIControlEventTouchUpInside];
    [buttonView addSubview:wxButton];
    
    UIButton *wxSessionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _wxSessionButton = wxSessionButton;
    [wxSessionButton setImage:[UIImage imageNamed:@"mine_packet_wx_s"] forState:UIControlStateNormal];
    [wxSessionButton setTitle:@"朋友圈邀请" forState:UIControlStateNormal];
    [wxSessionButton setTitleColor:HEX_COLOR(0x4a4a4a) forState:UIControlStateNormal];
    wxSessionButton.titleLabel.font = JA_REGULAR_FONT(13);
    [wxSessionButton addTarget:self action:@selector(clickWXSession) forControlEvents:UIControlEventTouchUpInside];
    [buttonView addSubview:wxSessionButton];
    
    UIButton *msgButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _msgButton = msgButton;
    [msgButton setImage:[UIImage imageNamed:@"mine_packet_msg"] forState:UIControlStateNormal];
    [msgButton setTitle:@"短信邀请" forState:UIControlStateNormal];
    [msgButton setTitleColor:HEX_COLOR(0x4a4a4a) forState:UIControlStateNormal];
    msgButton.titleLabel.font = JA_REGULAR_FONT(13);
    [msgButton addTarget:self action:@selector(clickMsgButton) forControlEvents:UIControlEventTouchUpInside];
    [buttonView addSubview:msgButton];
    
    UIButton *flockButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _flockButton = flockButton;
    [flockButton setImage:[UIImage imageNamed:@"mine_packet_flock"] forState:UIControlStateNormal];
    [flockButton setTitle:@"群发邀请" forState:UIControlStateNormal];
    [flockButton setTitleColor:HEX_COLOR(0x4a4a4a) forState:UIControlStateNormal];
    flockButton.titleLabel.font = JA_REGULAR_FONT(13);
    [flockButton addTarget:self action:@selector(clickFlockButton) forControlEvents:UIControlEventTouchUpInside];
    [buttonView addSubview:flockButton];
    
    UIButton *faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _faceButton = faceButton;
    [faceButton setImage:[UIImage imageNamed:@"mine_packet_face"] forState:UIControlStateNormal];
    [faceButton setTitle:@"面对面邀请" forState:UIControlStateNormal];
    [faceButton setTitleColor:HEX_COLOR(0x4a4a4a) forState:UIControlStateNormal];
    faceButton.titleLabel.font = JA_REGULAR_FONT(13);
    [faceButton addTarget:self action:@selector(clickFaceButton) forControlEvents:UIControlEventTouchUpInside];
    [buttonView addSubview:faceButton];
    
    UIView *moreActionView = [[UIView alloc] init];
    moreActionView.backgroundColor = HEX_COLOR(0xF6F6F6);
    _moreActionView = moreActionView;
    [scrollView addSubview:moreActionView];
    
    UIButton *showIncomeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    showIncomeButton.backgroundColor = [UIColor whiteColor];
    _showIncomeButton = showIncomeButton;
    [showIncomeButton setTitle:@"晒收入" forState:UIControlStateNormal];
    [showIncomeButton setTitleColor:HEX_COLOR(0x4a4a4a) forState:UIControlStateNormal];
    showIncomeButton.titleLabel.font = JA_REGULAR_FONT(16);
    showIncomeButton.layer.cornerRadius = 20;
    showIncomeButton.layer.masksToBounds = YES;
    [showIncomeButton addTarget:self action:@selector(showIncomeAction) forControlEvents:UIControlEventTouchUpInside];
    [moreActionView addSubview:showIncomeButton];
  
    UIButton *awakeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    awakeButton.backgroundColor = [UIColor whiteColor];
    _awakeButton = awakeButton;
    [awakeButton setTitle:@"唤醒徒弟" forState:UIControlStateNormal];
    [awakeButton setTitleColor:HEX_COLOR(0x4a4a4a) forState:UIControlStateNormal];
    awakeButton.titleLabel.font = JA_REGULAR_FONT(16);
    awakeButton.layer.cornerRadius = 20;
    awakeButton.layer.masksToBounds = YES;
    [awakeButton addTarget:self action:@selector(awakeAction) forControlEvents:UIControlEventTouchUpInside];
    [moreActionView addSubview:awakeButton];
    
    UIImageView *bottomImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mine_benefit_icon"]];
    _bottomImageView = bottomImageView;
    [self.scrollView addSubview:bottomImageView];
    
    JAPaddingLabel *label1 = [[JAPaddingLabel alloc] init];
    _label1 = label1;
    label1.text = @" ";
    label1.textColor = HEX_COLOR(0x525252);
    label1.font = JA_MEDIUM_FONT(14);
    label1.numberOfLines = 0;
    label1.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    [self.scrollView addSubview:label1];
    
    JAPaddingLabel *label2 = [[JAPaddingLabel alloc] init];
    _label2 = label2;
    label2.text = @" ";
    label2.textColor = HEX_COLOR(0x4A4A4A);
    label2.font = JA_REGULAR_FONT(14);
    label2.backgroundColor = HEX_COLOR(0xF6F6F6);
    label2.numberOfLines = 0;
    if (iPhone4 || iPhone5) {
        label2.edgeInsets = UIEdgeInsetsMake(5, 5, 26, 5);
    }else{
        label2.edgeInsets = UIEdgeInsetsMake(14, 14, 26, 14);
    }
    [self.scrollView addSubview:label2];
    
    UIButton *ruleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _ruleButton = ruleButton;
    [ruleButton setTitle:@"查看规则" forState:UIControlStateNormal];
    [ruleButton setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateNormal];
    ruleButton.backgroundColor = HEX_COLOR(0x6BD379);
    ruleButton.titleLabel.font = JA_MEDIUM_FONT(14);
    [ruleButton addTarget:self action:@selector(clickBottomRuleButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:ruleButton];
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self caculatorUIFrame];
}

- (void)caculatorUIFrame
{
    self.scrollView.frame = self.view.bounds;
    
    self.buttonView.width = JA_SCREEN_WIDTH;
    self.buttonView.height = 190;
    self.buttonView.x = 0;
    self.buttonView.y = 10;
    
    self.wxButton.width = self.buttonView.width / 4;
    self.wxButton.height = self.buttonView.height * 0.5;
    [self.wxButton setButtonImageTitleStyle:ButtonImageTitleStyleTop padding:10];
    
    self.wxSessionButton.width = self.buttonView.width / 4;
    self.wxSessionButton.height = self.buttonView.height * 0.5;
    self.wxSessionButton.x = self.wxButton.right;
    [self.wxSessionButton setButtonImageTitleStyle:ButtonImageTitleStyleTop padding:10];
    
    self.qqButton.width = self.buttonView.width / 4;
    self.qqButton.height = self.buttonView.height * 0.5;
    self.qqButton.x = self.wxSessionButton.right;
    [self.qqButton setButtonImageTitleStyle:ButtonImageTitleStyleTop padding:10];
    
    self.msgButton.width = self.buttonView.width / 4;
    self.msgButton.height = self.buttonView.height * 0.5;
    self.msgButton.x = self.qqButton.right;
    [self.msgButton setButtonImageTitleStyle:ButtonImageTitleStyleTop padding:10];
    
    self.flockButton.width = self.buttonView.width / 4;
    self.flockButton.height = self.buttonView.height * 0.5;
    self.flockButton.x = self.wxSessionButton.x;
    self.flockButton.y = self.wxSessionButton.bottom;
    [self.flockButton setButtonImageTitleStyle:ButtonImageTitleStyleTop padding:10];
    
    self.faceButton.width = self.buttonView.width / 4;
    self.faceButton.height = self.buttonView.height * 0.5;
    self.faceButton.x = self.qqButton.x;
    self.faceButton.y = self.qqButton.bottom;
    [self.faceButton setButtonImageTitleStyle:ButtonImageTitleStyleTop padding:10];
    
    self.inviteCodeButton.y = self.buttonView.bottom+5;
    self.inviteCodeButton.height = 30;
    self.inviteCodeButton.width = 163;
    self.inviteCodeButton.centerX = JA_SCREEN_WIDTH * 0.5;
    
    self.inviteCodeButton.layer.cornerRadius = self.inviteCodeButton.height * 0.5;
    self.inviteCodeButton.layer.borderColor = HEX_COLOR(0x4A90E2).CGColor;
    self.inviteCodeButton.layer.borderWidth =  1;

    self.inviteCourseButton.width = 110;
    self.inviteCourseButton.height = 18;
    self.inviteCourseButton.centerX = JA_SCREEN_WIDTH * 0.5;
    self.inviteCourseButton.y = self.inviteCodeButton.bottom + 12;
    
    self.moreActionView.width = JA_SCREEN_WIDTH;
    self.moreActionView.height = 60;
    self.moreActionView.x = 0;
    self.moreActionView.y = self.inviteCourseButton.bottom + 15;
    
    CGFloat buttonW = (JA_SCREEN_WIDTH - 12*2-10)/2.0;
    
    self.showIncomeButton.width = buttonW;
    self.showIncomeButton.height = 40;
    self.showIncomeButton.x = 12;
    self.showIncomeButton.centerY = self.moreActionView.height/2.0;

    self.awakeButton.width = buttonW;
    self.awakeButton.height = 40;
    self.awakeButton.x = self.showIncomeButton.right + 10;
    self.awakeButton.centerY = self.moreActionView.height/2.0;
    
    self.bottomImageView.centerX = self.scrollView.width * 0.5;
    self.bottomImageView.y = self.moreActionView.bottom + 30;
    
    self.label1.width = JA_SCREEN_WIDTH - 2 * 20;
    [self.label1 sizeToFit];
    self.label1.width = JA_SCREEN_WIDTH - 2 * 20;
    self.label1.x = 20;
    self.label1.y = self.bottomImageView.bottom + 20;
    
    self.label2.width = JA_SCREEN_WIDTH - 2 * 20;
    [self.label2 sizeToFit];
    self.label2.width = JA_SCREEN_WIDTH - 2 * 20;
    self.label2.x = 20;
    self.label2.y = self.label1.bottom + 10;
    
    self.ruleButton.width = 80;
    self.ruleButton.height = 30;
    self.ruleButton.centerX = self.scrollView.width * 0.5;
    self.ruleButton.centerY = self.label2.bottom;
    self.ruleButton.layer.cornerRadius = self.ruleButton.height * 0.5;
    
    self.scrollView.contentSize = CGSizeMake(0, self.ruleButton.bottom + 20);
}

#pragma mark - 按钮的点击事件
- (void)seeInviteCourse:(UIButton *)btn
{
    JAWebViewController *vc = [[JAWebViewController alloc] init];
    vc.urlString = self.urlStr;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)clickBottomRuleButton:(UIButton *)btn
{
    if (self.textArray.count && self.textArray.count > 3) {
        NSString *text1 = self.textArray[2][@"content"];
        NSArray *keyArr1 = [self getKeyWordArray:self.textArray[2][@"keyContent"]];
        
        NSString *text2 = self.textArray[3][@"content"];
        
        JAInviteFriendRuleView *v = [[JAInviteFriendRuleView alloc] init];
        [v showInviteRuleFloat:text1 keyWord:keyArr1 ruleText:text2];
    }else{
        [self.view ja_makeToast:@"获取规则信息失败"];
    }
}

// 复制邀请码
- (void)clickCopyInviteCode:(UIButton *)button
{
    UIPasteboard *board = [UIPasteboard generalPasteboard];
    NSString *boardString = [JAUserInfo userInfo_getUserImfoWithKey:User_uuid];
    [board setString:boardString];
    if (board == nil) {
        [self.view ja_makeToast:@"复制失败"];
    }
    else {
        [self.view ja_makeToast:@"复制成功"];
    }
}

- (void)co_pyInvite
{
    UIPasteboard *board = [UIPasteboard generalPasteboard];
    NSString *boardString = [JAUserInfo userInfo_getUserImfoWithKey:User_uuid];
    [board setString:boardString];
    if (board == nil) {
        [self.view ja_makeToast:@"复制失败"];
    }
    else {
        [self.view ja_makeToast:@"复制成功"];
    }
}

// 点击QQ邀请
- (void)clickQQ
{
    if (self.shareError.length) {
        [self.view ja_makeToast:self.shareError];
        [self getUserShareInfo];
        return;
    }
    
    JAShareRegistModel *sharemodel = [JAConfigManager shareInstance].shareRegistModel;
    [self sensorsAnalyticsInviteFriend:@"qq"];
    JAShareModel *model = [JAShareModel new];
    model.title = sharemodel.title;
    model.descripe = sharemodel.content;
    model.shareUrl = sharemodel.url;
    model.image = sharemodel.logo;
    [JAPlatformShareManager qqShare:QQShareTypeFriend shareContent:model domainType:1];
}

// 点击微信好友邀请
- (void)clickWX
{
    if (self.shareError.length) {
        [self.view ja_makeToast:self.shareError];
        [self getUserShareInfo];
        return;
    }
    
    JAShareRegistModel *sharemodel = [JAConfigManager shareInstance].shareRegistModel;
    [self sensorsAnalyticsInviteFriend:@"微信"];
    JAShareModel *model = [[JAShareModel alloc] init];
    model.title = sharemodel.title;
    model.descripe = sharemodel.content;
    model.shareUrl = sharemodel.url;
    model.image = sharemodel.logo;

    [JAPlatformShareManager wxShare:WeiXinShareTypeTimeline shareContent:model domainType:1];
}

// 点击微信朋友圈邀请
- (void)clickWXSession
{
    if (self.shareError.length) {
        [self.view ja_makeToast:self.shareError];
        [self getUserShareInfo];
        return;
    }
    
    JAShareRegistModel *sharemodel = [JAConfigManager shareInstance].shareRegistModel;
    [self sensorsAnalyticsInviteFriend:@"朋友圈"];
    JAShareModel *model = [[JAShareModel alloc] init];
    model.title = sharemodel.title;
    model.shareUrl = sharemodel.url;
    model.image = sharemodel.logo;
    [JAPlatformShareManager wxShare:WeiXinShareTypeSession shareContent:model domainType:1];
}

// 短信邀请
- (void)clickMsgButton
{
    if (self.shareError.length) {
        [self.view ja_makeToast:self.shareError];
        [self getUserShareInfo];
        return;
    }
    
    if( [MFMessageComposeViewController canSendText]) {
        JAShareRegistModel *sharemodel = [JAConfigManager shareInstance].shareRegistModel;
        [self sensorsAnalyticsInviteFriend:@"短信"];
        MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc] init];
        NSString *str = [NSString stringWithFormat:@"在这里聊聊天就可以赚零花钱，我用了一段时间了非常棒！推荐你试试，哈哈。点这个链接: %@ 注册成功后，下载并登录茉莉APP,就能领取1-10元随机红包!",sharemodel.url];
        controller.body = str;
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
        [[[[controller viewControllers] lastObject] navigationItem] setTitle:@"新消息"];//修改短信界面标题
        
    }else {
        [self.view ja_makeToast:@"该设备不支持短信功能"];
    }
}

// 群发邀请
- (void)clickFlockButton
{
    [self sensorsAnalyticsInviteFriend:@"群"];
    JAWebViewController *vc = [[JAWebViewController alloc] init];
#ifdef JA_TEST_HOST
    if (![[JAConfigManager shareInstance].host containsString:@"data.urmoli.com"]) {
        vc.urlString = @"http://index.yourmoli.com/newmoli/views/app/groupInvitation/groupInvitation.html";
    } else {
        vc.urlString = @"http://www.urmoli.com/newmoli/views/app/groupInvitation/groupInvitation.html";
    }
#else
    vc.urlString = @"http://www.urmoli.com/newmoli/views/app/groupInvitation/groupInvitation.html";
#endif
    [self.navigationController pushViewController:vc animated:YES];
}

// 面对面邀请
- (void)clickFaceButton
{
    [self sensorsAnalyticsInviteFriend:@"面对面"];
    JAWebViewController *vc = [[JAWebViewController alloc] init];
    
#ifdef JA_TEST_HOST
    if (![[JAConfigManager shareInstance].host containsString:@"data.urmoli.com"]) {
        vc.urlString = @"http://index.yourmoli.com/newmoli/views/app/faceInvitation/faceInvitation.html";
    } else {
        vc.urlString = @"http://www.urmoli.com/newmoli/views/app/faceInvitation/faceInvitation.html";
    }
#else
    vc.urlString = @"http://www.urmoli.com/newmoli/views/app/faceInvitation/faceInvitation.html";
#endif
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showIncomeAction {
    JAPersonalSharePictureViewController *vc = [[JAPersonalSharePictureViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)awakeAction {
    
    if (self.callFriendBlock) {
        self.callFriendBlock();
    }
}

#pragma mark - 短信代理
-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissViewControllerAnimated:YES completion:nil];
    switch (result) {
        case MessageComposeResultSent:
            //信息传送成功
            break;
        case MessageComposeResultFailed:
            //信息传送失败
            break;
        case MessageComposeResultCancelled:
            //信息被用户取消传送
            break;
        default:
            break;
    }
}

// 高亮文字
//- (NSMutableAttributedString *)attributedString:(NSString *)text word:(NSString *)keyWord
//{
//    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:text];
//
//    // 获取关键字的位置
//    NSRange rang = [text rangeOfString:keyWord];
//
//    [attr addAttribute:NSForegroundColorAttributeName value:HEX_COLOR(0xFF7054) range:rang];
//
//    return attr;
//}

- (void)sensorsAnalyticsInviteFriend:(NSString *)mothod
{
    // 神策数据
    NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
    senDic[JA_Property_InvitationMethod] = mothod;
    [JASensorsAnalyticsManager sensorsAnalytics_inviteFriend:senDic];
}

@end

