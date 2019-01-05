//
//  JAVoiceReplyCell.m
//  Jasmine
//
//  Created by moli-2017 on 2017/8/30.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAVoiceFocusCell.h"
#import "JAVoicePersonApi.h"

@interface JAVoiceFocusCell ()

@property (nonatomic, weak) UIImageView *iconImageView;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UILabel *timeLabel;
@property (nonatomic, weak) UILabel *operationLbel;
@property (nonatomic, weak) UIImageView *unreadImageView;
@property (nonatomic, weak) UIButton *focusButton;
@property (nonatomic, weak) UIView *lineView;

@end

@implementation JAVoiceFocusCell

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupVoiceAgreeCell];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFocusStatusTrue:) name:@"searchRefreshFocusStatusTrue" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFocusStatusFalse:) name:@"searchRefreshFocusStatusFalse" object:nil];
        
    }
    return self;
}

#pragma mark - 刷新关注按钮
- (void)refreshFocusStatusTrue:(NSNotification *)noti
{
    NSDictionary *dic = noti.object;
    NSString *userId = dic[@"id"];
    NSString *modelUserId = self.model.user.userId;
    if ([userId isEqualToString:modelUserId]) {

        self.model.user.friendType = dic[@"status"];
        
        if ([self.model.user.friendType integerValue] == 0) {
            self.focusButton.backgroundColor = HEX_COLOR(JA_BoardLineColor);
            [self.focusButton setTitleColor:HEX_COLOR(JA_BlackSubTitle) forState:UIControlStateNormal];
            [self.focusButton setTitle:@"已关注" forState:UIControlStateNormal];
            self.focusButton.layer.borderWidth = 0;
        } else if([self.model.user.friendType integerValue] == 1) {
            self.focusButton.backgroundColor = HEX_COLOR(JA_BoardLineColor);
            [self.focusButton setTitleColor:HEX_COLOR(JA_BlackSubTitle) forState:UIControlStateNormal];
            [self.focusButton setTitle:@"相互关注" forState:UIControlStateNormal];
            self.focusButton.layer.borderWidth = 0;
        } else {
            self.focusButton.backgroundColor = [UIColor clearColor];
            [self.focusButton setTitleColor:HEX_COLOR(JA_Green) forState:UIControlStateNormal];
            [self.focusButton setTitle:@"+关注" forState:UIControlStateNormal];
            self.focusButton.layer.borderWidth = 1;
            self.focusButton.layer.borderColor = HEX_COLOR(JA_Green).CGColor;
        }
        
        [self.model updateToDB];
    }
    
}

- (void)refreshFocusStatusFalse:(NSNotification *)noti
{
    NSDictionary *dic = noti.object;
    NSString *userId = dic[@"id"];
    NSString *modelUserId = self.model.user.userId;
    if ([userId isEqualToString:modelUserId]) {
        
        self.model.user.friendType = dic[@"status"];
        
        if ([self.model.user.friendType integerValue] == 0) {
            self.focusButton.backgroundColor = HEX_COLOR(JA_BoardLineColor);
            [self.focusButton setTitleColor:HEX_COLOR(JA_BlackSubTitle) forState:UIControlStateNormal];
            [self.focusButton setTitle:@"已关注" forState:UIControlStateNormal];
            self.focusButton.layer.borderWidth = 0;
        } else if([self.model.user.friendType integerValue] == 1) {
            self.focusButton.backgroundColor = HEX_COLOR(JA_BoardLineColor);
            [self.focusButton setTitleColor:HEX_COLOR(JA_BlackSubTitle) forState:UIControlStateNormal];
            [self.focusButton setTitle:@"相互关注" forState:UIControlStateNormal];
            self.focusButton.layer.borderWidth = 0;
        } else {
            self.focusButton.backgroundColor = [UIColor clearColor];
            [self.focusButton setTitleColor:HEX_COLOR(JA_Green) forState:UIControlStateNormal];
            [self.focusButton setTitle:@"+关注" forState:UIControlStateNormal];
            self.focusButton.layer.borderWidth = 1;
            self.focusButton.layer.borderColor = HEX_COLOR(JA_Green).CGColor;
        }
        
        [self.model updateToDB];
    }
}

- (void)setupVoiceAgreeCell
{
    UIImageView *iconImageView = [[UIImageView alloc] init];
    _iconImageView = iconImageView;
    iconImageView.image = [UIImage imageNamed:@"moren_nan"];
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpPersonCenterVC)];
    iconImageView.userInteractionEnabled = YES;
    [iconImageView addGestureRecognizer:tap1];
    [self.contentView addSubview:iconImageView];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    _nameLabel = nameLabel;
    nameLabel.text = @"小茉莉";
    nameLabel.textColor = HEX_COLOR(JA_Title);
    nameLabel.font = JA_REGULAR_FONT(JA_PersonalDetail_commentPersonalFont);
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpPersonCenterVC)];
    nameLabel.userInteractionEnabled = YES;
    [nameLabel addGestureRecognizer:tap2];
    [self.contentView addSubview:nameLabel];
    
    UILabel *timeLabel = [[UILabel alloc] init];
    _timeLabel = timeLabel;
    timeLabel.text = @"刚刚";
    timeLabel.textColor = HEX_COLOR(JA_BlackSubSubTitle);
    timeLabel.font = JA_REGULAR_FONT(12);
    [self.contentView addSubview:timeLabel];
    
    UILabel *operationLbel = [[UILabel alloc] init];
    _operationLbel = operationLbel;
    operationLbel.text = @"关注了你";
    operationLbel.textColor = HEX_COLOR(JA_BlackSubTitle);
    operationLbel.font = JA_REGULAR_FONT(JA_PersonalDetail_commentPersonalFont);
    [self.contentView addSubview:operationLbel];
    
    UIImageView *unreadImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"branch_noti_unread"]];
    _unreadImageView = unreadImageView;
    [self.contentView addSubview:unreadImageView];
    
    UIButton *focusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.focusButton = focusButton;
    self.focusButton.titleLabel.font = JA_REGULAR_FONT(12);
    [self.focusButton setTitleColor:HEX_COLOR(JA_Green) forState:UIControlStateNormal];
    [self.focusButton setTitle:@"+关注" forState:UIControlStateNormal];
    [self.focusButton addTarget:self action:@selector(noti_clickFocusButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:focusButton];
    
    UIView *lineView = [[UIView alloc] init];
    _lineView = lineView;
    lineView.backgroundColor = HEX_COLOR(JA_Line);
    [self.contentView addSubview:lineView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self caculatorCommonCommentCell];
}

- (void)caculatorCommonCommentCell
{
    self.iconImageView.height = 35;
    self.iconImageView.width = self.iconImageView.height;
    self.iconImageView.x = 15;
    self.iconImageView.y = 15;
    self.iconImageView.layer.cornerRadius = self.iconImageView.width * 0.5;
    self.iconImageView.layer.masksToBounds = YES;
    
    [self.nameLabel sizeToFit];
    self.nameLabel.x = self.iconImageView.right + 10;
    self.nameLabel.y = 17;
    self.nameLabel.height = 18;
    
    [self.timeLabel sizeToFit];
    self.timeLabel.x = self.nameLabel.x;
    self.timeLabel.y = self.nameLabel.bottom;
    self.timeLabel.height = 14;
    self.timeLabel.width = 150;
    
    [self.operationLbel sizeToFit];
    self.operationLbel.height = 18;
    self.operationLbel.x = self.nameLabel.right + 10;
    self.operationLbel.y = self.nameLabel.y;

    self.unreadImageView.x = self.operationLbel.right + 3;
    self.unreadImageView.centerY = self.operationLbel.centerY;
    
    self.focusButton.width = 60;
    self.focusButton.height = 25;
    self.focusButton.centerY = self.iconImageView.centerY;
    self.focusButton.x = self.contentView.width - self.focusButton.width - 15;
    self.focusButton.layer.cornerRadius = self.focusButton.height * 0.5;
    self.focusButton.clipsToBounds = YES;
//    self.focusButton.layer.borderWidth = 1;
//    self.focusButton.layer.borderColor = HEX_COLOR(JA_Green).CGColor;
    
    self.lineView.width = self.contentView.width;
    self.lineView.height = 1;
    self.lineView.y = self.contentView.height - 1;
}

- (void)setModel:(JANotiModel *)model
{
    _model = model;
 
    int h = 35;
    int w = h;
    NSString *url = [model.user.img ja_getFitImageStringWidth:w height:h];
    [self.iconImageView ja_setImageWithURLStr:url];
    
    self.nameLabel.text = model.user.nick;
    
    self.timeLabel.text = [NSString distanceTimeWithBeforeTime:model.time.doubleValue];
    
    self.operationLbel.text = model.msgContent;
    
    if (model.readState) {  // 0 未读  1 已读
        
        //        self.contentView.backgroundColor = [UIColor whiteColor];
        self.unreadImageView.hidden = YES;
    }else{
        //        self.contentView.backgroundColor = HEX_COLOR_ALPHA(JA_Green, 0.05);
        self.unreadImageView.hidden = NO;
    }
    
//    if (model.user.friendType == nil) {
//        self.focusButton.hidden = YES;
//    }else{
//        self.focusButton.hidden = NO;
//    }
    
//    if ([model.user.friendType integerValue] == 0) {
//        self.focusButton.backgroundColor = HEX_COLOR(JA_BoardLineColor);
//        [self.focusButton setTitleColor:HEX_COLOR(JA_BlackSubTitle) forState:UIControlStateNormal];
//        [self.focusButton setTitle:@"已关注" forState:UIControlStateNormal];
//        self.focusButton.layer.borderWidth = 0;
//    } else if([model.user.friendType integerValue] == 1) {
//        self.focusButton.backgroundColor = HEX_COLOR(JA_BoardLineColor);
//        [self.focusButton setTitleColor:HEX_COLOR(JA_BlackSubTitle) forState:UIControlStateNormal];
//        [self.focusButton setTitle:@"相互关注" forState:UIControlStateNormal];
//        self.focusButton.layer.borderWidth = 0;
//    } else {
//        self.focusButton.backgroundColor = [UIColor clearColor];
//        [self.focusButton setTitleColor:HEX_COLOR(JA_Green) forState:UIControlStateNormal];
//        [self.focusButton setTitle:@"+关注" forState:UIControlStateNormal];
//        self.focusButton.layer.borderWidth = 1;
//        self.focusButton.layer.borderColor = HEX_COLOR(JA_Green).CGColor;
//    }
    [self updateFocusButton:model];
}

- (void)jumpPersonCenterVC
{
    if (self.jumpPersonalCenterBlock) {
        self.jumpPersonalCenterBlock(self);
    }
}


#pragma mark - 关注按钮
- (void)updateFocusButton:(JANotiModel *)model
{
    if ([model.user.friendType integerValue] == 0) {
        self.focusButton.backgroundColor = HEX_COLOR(JA_BoardLineColor);
        [self.focusButton setTitleColor:HEX_COLOR(JA_BlackSubTitle) forState:UIControlStateNormal];
        [self.focusButton setTitle:@"已关注" forState:UIControlStateNormal];
        self.focusButton.layer.borderWidth = 0;
    } else if([model.user.friendType integerValue] == 1) {
        self.focusButton.backgroundColor = HEX_COLOR(JA_BoardLineColor);
        [self.focusButton setTitleColor:HEX_COLOR(JA_BlackSubTitle) forState:UIControlStateNormal];
        [self.focusButton setTitle:@"相互关注" forState:UIControlStateNormal];
        self.focusButton.layer.borderWidth = 0;
    } else {
        self.focusButton.backgroundColor = [UIColor clearColor];
        [self.focusButton setTitleColor:HEX_COLOR(JA_Green) forState:UIControlStateNormal];
        [self.focusButton setTitle:@"+关注" forState:UIControlStateNormal];
        self.focusButton.layer.borderWidth = 1;
        self.focusButton.layer.borderColor = HEX_COLOR(JA_Green).CGColor;
    }
}
- (void)noti_clickFocusButton:(UIButton *)btn
{
    [self focusCustomer:btn];
}

// 关注人
- (void)focusCustomer:(UIButton *)btn
{
    if (!IS_LOGIN) {
        [JAAPPManager app_modalLogin];
        return;
    }
    
    btn.userInteractionEnabled = NO;
    if (self.model.user.friendType.integerValue == 0 || self.model.user.friendType.integerValue == 1) {
        
        // 取消关注
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
        dic[@"concernId"] = self.model.user.userId;
        
        // 神策数据
        NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
        senDic[JA_Property_BindingType] = @"取消关注";
        senDic[JA_Property_PostId] = self.model.user.userId;
        senDic[JA_Property_PostName] = self.model.user.nick;
        senDic[JA_Property_FollowMethod] = @"消息-关注";
        [JASensorsAnalyticsManager sensorsAnalytics_followPerson:senDic];
        
        [[JAVoicePersonApi shareInstance] voice_personalCancleFocusUseroWithParas:dic success:^(NSDictionary *result) {
            
            NSString *type = [NSString stringWithFormat:@"%@",result[@"friend"][@"friendType"]];
            self.model.user.friendType = type;
            btn.userInteractionEnabled = YES;
          
            [self updateFocusButton:self.model];
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"id"] = self.model.user.userId;
            dic[@"status"] = type;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"searchRefreshFocusStatusFalse" object:dic];
            
        } failure:^(NSError *error) {
            btn.userInteractionEnabled = YES;
            [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:error.localizedDescription];
        }];
        
        return;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"concernId"] = self.model.user.userId;
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    
    // 神策数据
    NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
    senDic[JA_Property_BindingType] = @"关注";
    senDic[JA_Property_PostId] = self.model.user.userId;
    senDic[JA_Property_PostName] = self.model.user.nick;
    senDic[JA_Property_FollowMethod] = @"消息-关注";
    [JASensorsAnalyticsManager sensorsAnalytics_followPerson:senDic];
    
    [[JAVoicePersonApi shareInstance] voice_personalFocusUserWithParas:dic success:^(NSDictionary *result) {
        
        NSString *type = [NSString stringWithFormat:@"%@",result[@"friend"][@"friendType"]];
        self.model.user.friendType = type;
        btn.userInteractionEnabled = YES;
        
        [self updateFocusButton:self.model];
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"id"] = self.model.user.userId;
        dic[@"status"] = type;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"searchRefreshFocusStatusTrue" object:dic];
        
    } failure:^(NSError *error) {
        btn.userInteractionEnabled = YES;
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:error.localizedDescription];
    }];
}
@end


