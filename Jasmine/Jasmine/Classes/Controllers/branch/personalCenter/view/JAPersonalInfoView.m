//
//  JAPersonalInfoView.m
//  Jasmine
//
//  Created by moli-2017 on 2017/11/23.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAPersonalInfoView.h"
#import "JAPaddingLabel.h"
#import "JAVoicePersonApi.h"
#import "JAContributeIntroduceView.h"

@interface JAPersonalInfoView ()

@property (nonatomic, weak) UIImageView *iconImageView;  // 头像
@property (nonatomic, weak) UILabel *moliIdLabel;   // 茉莉id
@property (nonatomic, weak) JAPaddingLabel *levelLabel;   // 等级
@property (nonatomic, weak) UIButton *ageButton;   // 年龄
@property (nonatomic, weak) JAPaddingLabel *constellationLabel;   // 星座
@property (nonatomic, weak) UIView *whiteView;

@property (nonatomic, weak) UILabel *focusLabel;
@property (nonatomic, weak) UIView *lineView1;
@property (nonatomic, weak) UILabel *fansLabel;
@property (nonatomic, weak) UIView *lineView2;
@property (nonatomic, weak) UILabel *agreeLabel;

// 茉莉电台
@property (nonatomic, weak) UIButton *moliFocusButton;  // 关注
@property (nonatomic, weak) UIButton *molicontribute;    // 投稿

@property (nonatomic, weak) UILabel *introductionLabel; // 介绍

@end
@implementation JAPersonalInfoView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:(CGRect)frame];
    if (self) {
        
        [self setupPersonalCenterCellUI];
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFocusStatusTrue:) name:@"searchRefreshFocusStatusTrue" object:nil];
//        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFocusStatusFalse:) name:@"searchRefreshFocusStatusFalse" object:nil];
    }
    return self;
}

- (void)setupPersonalCenterCellUI
{
    
    UIView *whiteView = [[UIView alloc] init];
    _whiteView = whiteView;
    whiteView.backgroundColor = [UIColor whiteColor];
    [self addSubview:whiteView];
    
    // 头像
    UIImageView *iconImageView = [[UIImageView alloc] init];
    iconImageView.backgroundColor = [UIColor clearColor];
    iconImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickUserIcon)];
    [iconImageView addGestureRecognizer:tap];
    iconImageView.layer.borderWidth = 2;
    iconImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    _iconImageView = iconImageView;
    iconImageView.image = [UIImage imageNamed:@"moren_nan"];
    [self addSubview:iconImageView];
    
    // 茉莉ID
    UILabel *moliIdLabel = [[UILabel alloc] init];
    _moliIdLabel = moliIdLabel;
    moliIdLabel.text = @"茉莉ID：0";
    moliIdLabel.textColor = HEX_COLOR(0xffffff);
    moliIdLabel.font = JA_REGULAR_FONT(12);
    [self addSubview:moliIdLabel];
    
    // 等级
    JAPaddingLabel *levelLabel = [[JAPaddingLabel alloc] init];
    _levelLabel = levelLabel;
    levelLabel.backgroundColor = HEX_COLOR(JA_Green);
    levelLabel.textColor = HEX_COLOR(0xffffff);
    levelLabel.text = @"Lv.1";
    levelLabel.font = JA_REGULAR_FONT(10);
    levelLabel.edgeInsets = UIEdgeInsetsMake(0, 3, 0, 3);
    levelLabel.layer.cornerRadius = 2;
    levelLabel.layer.masksToBounds = YES;
    [self addSubview:levelLabel];
    
    // 年龄 - 性别
    UIButton *ageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _ageButton = ageButton;
    ageButton.hidden = YES;
    [ageButton setTitle:@" " forState:UIControlStateNormal];
    [ageButton setBackgroundImage:[UIImage imageNamed:@"person_man"] forState:UIControlStateNormal];
    [ageButton setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateNormal];
    ageButton.titleLabel.font = JA_REGULAR_FONT(10);
    ageButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    ageButton.layer.cornerRadius = 2;
    [self addSubview:ageButton];
    
    // 星座
    JAPaddingLabel *constellationLabel = [[JAPaddingLabel alloc] init];
    _constellationLabel = constellationLabel;
    constellationLabel.hidden = YES;
    constellationLabel.backgroundColor = HEX_COLOR(0xFF6DC1);
    constellationLabel.textColor = HEX_COLOR(0xffffff);
    constellationLabel.text = @" ";
    constellationLabel.font = JA_REGULAR_FONT(10);
    constellationLabel.edgeInsets = UIEdgeInsetsMake(0, 3, 0, 3);
    constellationLabel.layer.cornerRadius = 2;
    constellationLabel.layer.masksToBounds = YES;
    [self addSubview:constellationLabel];
    
    // 关注
    UILabel *focusLabel = [[UILabel alloc] init];
    _focusLabel = focusLabel;
    focusLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpFansAndFocus)];
    [focusLabel addGestureRecognizer:tap1];
    focusLabel.textColor = HEX_COLOR(JA_Title);
    focusLabel.font = JA_REGULAR_FONT(16);
    focusLabel.attributedText = [self attributedString:@"0 关注" word:@"关注"];
    [self addSubview:focusLabel];
    
    // 线1
    UIView *lineView1 = [[UIView alloc] init];
    _lineView1 = lineView1;
    lineView1.backgroundColor = HEX_COLOR(JA_Line);
    [self addSubview:lineView1];
    
    // 粉丝
    UILabel *fansLabel = [[UILabel alloc] init];
    _fansLabel = fansLabel;
    fansLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpFansAndFocus)];
    [fansLabel addGestureRecognizer:tap2];
    fansLabel.textColor = HEX_COLOR(JA_Title);
    fansLabel.font = JA_REGULAR_FONT(16);
    fansLabel.attributedText = [self attributedString:@"0 粉丝" word:@"粉丝"];
    [self addSubview:fansLabel];
    
    // 线2
    UIView *lineView2 = [[UIView alloc] init];
    _lineView2 = lineView2;
    lineView2.backgroundColor = HEX_COLOR(JA_Line);
    [self addSubview:lineView2];
    
    // 被赞
    UILabel *agreeLabel = [[UILabel alloc] init];
    _agreeLabel = agreeLabel;
    agreeLabel.textColor = HEX_COLOR(JA_Title);
    agreeLabel.font = JA_REGULAR_FONT(16);
    agreeLabel.attributedText = [self attributedString:@"0 获赞" word:@"获赞"];
    [self addSubview:agreeLabel];
    
    // 茉莉电台关注
    UIButton *moliFocusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _moliFocusButton = moliFocusButton;
    moliFocusButton.hidden = YES;
    [moliFocusButton setTitle:@"+关注" forState:UIControlStateNormal];
    [moliFocusButton setTitleColor:HEX_COLOR(0x1CD39B) forState:UIControlStateNormal];
    moliFocusButton.titleLabel.font = JA_REGULAR_FONT(12);
    moliFocusButton.layer.borderColor = HEX_COLOR(0x1CD39B).CGColor;
    moliFocusButton.layer.borderWidth = 1;
    moliFocusButton.layer.cornerRadius = 3;
    moliFocusButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [moliFocusButton addTarget:self action:@selector(clickmoliFocusButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:moliFocusButton];
    
    // 茉莉电台投稿
    UIButton *molicontribute = [UIButton buttonWithType:UIButtonTypeCustom];
    _molicontribute = molicontribute;
    molicontribute.hidden = YES;
    [molicontribute setTitle:@"投稿须知" forState:UIControlStateNormal];
    [molicontribute setTitleColor:HEX_COLOR(0x1CD39B) forState:UIControlStateNormal];
    molicontribute.titleLabel.font = JA_REGULAR_FONT(12);
    molicontribute.layer.borderColor = HEX_COLOR(0x1CD39B).CGColor;
    molicontribute.layer.borderWidth = 1;
    molicontribute.layer.cornerRadius = 3;
    molicontribute.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [molicontribute addTarget:self action:@selector(clickmolicontribute:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:molicontribute];
    
    // 介绍
    UILabel *introductionLabel = [[UILabel alloc] init];
    _introductionLabel = introductionLabel;
    introductionLabel.text = @"他还没有个性签名";
    introductionLabel.textColor = HEX_COLOR(0x454C57);
    introductionLabel.font = JA_LIGHT_FONT(13);
    introductionLabel.numberOfLines = 0;
    [self addSubview:introductionLabel];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self caculatorPersonalCenterCellFrame];
}

- (void)caculatorPersonalCenterCellFrame
{
    self.iconImageView.width = 75;
    self.iconImageView.height = 75;
    self.iconImageView.layer.cornerRadius = self.iconImageView.height * 0.5;
    self.iconImageView.layer.masksToBounds = YES;
    self.iconImageView.x = WIDTH_ADAPTER(20);
    
    [self.moliIdLabel sizeToFit];
    self.moliIdLabel.height = 17;
    self.moliIdLabel.x = self.iconImageView.right + 10;
    self.moliIdLabel.y = 10;
    
    [self.levelLabel sizeToFit];
    self.levelLabel.height = 14;
    self.levelLabel.width = 0;
    self.levelLabel.x = self.moliIdLabel.right + 5;
    self.levelLabel.centerY = self.moliIdLabel.centerY;
    
    [self.ageButton sizeToFit];
    self.ageButton.height = 14;
    self.ageButton.x = self.levelLabel.right + 5;
    self.ageButton.centerY = self.moliIdLabel.centerY;
    
    [self.constellationLabel sizeToFit];
    self.constellationLabel.height = 14;
    if (self.model.sex.integerValue == 0) {
        self.constellationLabel.x = self.levelLabel.right + 5;
    }else{
        
        self.constellationLabel.x = self.ageButton.right + 5;
    }
    self.constellationLabel.centerY = self.moliIdLabel.centerY;
    
    [self.focusLabel sizeToFit];
    self.focusLabel.height = 22;
    self.focusLabel.x = self.moliIdLabel.x;
    self.focusLabel.y = self.iconImageView.height * 0.5 + 10;
    
    self.lineView1.width = 1;
    self.lineView1.height = 10;
    self.lineView1.x = self.focusLabel.right + 10;
    self.lineView1.centerY = self.focusLabel.centerY;
    
    [self.fansLabel sizeToFit];
    self.fansLabel.height = 22;
    self.fansLabel.x = self.lineView1.right + 10;
    self.fansLabel.centerY = self.focusLabel.centerY;
    
    self.lineView2.width = 1;
    self.lineView2.height = 10;
    self.lineView2.x = self.fansLabel.right + 10;
    self.lineView2.centerY = self.focusLabel.centerY;
    
    [self.agreeLabel sizeToFit];
    self.agreeLabel.height = 22;
    self.agreeLabel.x = self.lineView2.right + 10;
    self.agreeLabel.centerY = self.focusLabel.centerY;
    
    self.molicontribute.width = WIDTH_ADAPTER(90);
    self.molicontribute.height = 23;
    self.molicontribute.x = self.width - self.molicontribute.width - 15;
    self.molicontribute.y = self.focusLabel.y;
    
    self.moliFocusButton.x = self.focusLabel.x;
    self.moliFocusButton.width = self.molicontribute.x - self.moliFocusButton.x - 10;
    self.moliFocusButton.height = self.molicontribute.height;
    self.moliFocusButton.y = self.molicontribute.y;
    
    self.introductionLabel.x = self.iconImageView.x;
    self.introductionLabel.y = self.iconImageView.bottom;
    self.introductionLabel.width = JA_SCREEN_WIDTH - 40;
    self.introductionLabel.height = 50;
    
    self.whiteView.y = 37.5;
    self.whiteView.width = JA_SCREEN_WIDTH;
    self.whiteView.height = self.introductionLabel.bottom + 5;

}

- (void)setModel:(JAConsumer *)model
{
    _model = model;
    
    int h = 375;
    int w = 375;
    NSString *imageurl = [model.image ja_getFitImageStringWidth:w height:h];
    [self.iconImageView ja_setImageWithURLStr:imageurl placeholder:[UIImage imageNamed:@"moren_nan"]];
    
    if ([self checkMoliDianTai:model.userId] || [self checkMoliDianTai:model.consumerId]) {
        self.focusLabel.hidden = YES;
        self.fansLabel.hidden = YES;
        self.agreeLabel.hidden = YES;
        self.lineView1.hidden = YES;
        self.lineView2.hidden = YES;
        self.molicontribute.hidden = NO;
        self.moliFocusButton.hidden = NO;
        
        self.ageButton.hidden = YES;
        self.levelLabel.hidden = YES;
        self.constellationLabel.hidden = YES;
        
    }else{
        self.molicontribute.hidden = YES;
        self.moliFocusButton.hidden = YES;
        self.focusLabel.hidden = NO;
        self.fansLabel.hidden = NO;
        self.agreeLabel.hidden = NO;
        self.lineView1.hidden = NO;
        self.lineView2.hidden = NO;
        
        self.ageButton.hidden = NO;
        self.levelLabel.hidden = NO;
        self.constellationLabel.hidden = NO;
        
        NSString *focusCount = nil;
        NSString *fansCount = nil;
        NSString *agreeCount = nil;
        if (model.userConsernCount.integerValue > 10000) {
            focusCount = [NSString stringWithFormat:@"%.1fw",(model.userConsernCount.integerValue/10000.0)];
        }else{
            focusCount = model.userConsernCount.length ? model.userConsernCount : @"0";
        }
        if (model.concernUserCount.integerValue > 10000) {
            fansCount = [NSString stringWithFormat:@"%.1fw",(model.concernUserCount.integerValue/10000.0)];
        }else{
            fansCount = model.concernUserCount.length ? model.concernUserCount : @"0";
        }
        if (model.agreeCount.integerValue > 10000) {
            agreeCount = [NSString stringWithFormat:@"%.1fw",(model.agreeCount.integerValue/10000.0)];
        }else{
            agreeCount = model.agreeCount.integerValue ? model.agreeCount : @"0";
        }
        
        NSString *focus = [NSString stringWithFormat:@"%@ 关注",focusCount];
        
        self.focusLabel.attributedText = [self attributedString:focus word:@"关注"];
        
        NSString *fans = [NSString stringWithFormat:@"%@ 粉丝",fansCount];
        self.fansLabel.attributedText = [self attributedString:fans word:@"粉丝"];
        
        NSString *agree = [NSString stringWithFormat:@"%@ 获赞",agreeCount];
        self.agreeLabel.attributedText = [self attributedString:agree word:@"获赞"];
    }
    
    // 获取年龄
    NSString *userAge = model.birthdayName.length ? model.age : @"--";
    
    // 性别、年龄
    if ([model.sex integerValue] == 1) {
//        self.ageButton.hidden = NO;
        self.constellationLabel.x = self.ageButton.right + 5;
        [self.ageButton setTitle:userAge forState:UIControlStateNormal];
        [self.ageButton setBackgroundImage:[UIImage imageNamed:@"person_man"] forState:UIControlStateNormal];
    }else if([model.sex integerValue] == 2){
//        self.ageButton.hidden = NO;
        self.constellationLabel.x = self.ageButton.right + 5;
        [self.ageButton setTitle:userAge forState:UIControlStateNormal];
        [self.ageButton setBackgroundImage:[UIImage imageNamed:@"person_woman"] forState:UIControlStateNormal];
    }else{
        self.ageButton.hidden = YES;
        self.constellationLabel.x = self.levelLabel.right + 5;
    }
    
    if (model.levelId.integerValue > 1) {
        self.levelLabel.text = [NSString stringWithFormat:@"Lv.%@",model.levelId];
    }else{
        self.levelLabel.text = @"Lv.1";
    }
    
    
    if (model.constellation.length) {
//        self.constellationLabel.hidden = NO;
        self.constellationLabel.text = model.constellation;
    }else{
        self.constellationLabel.hidden = YES;
    }
    
    self.moliIdLabel.text = [NSString stringWithFormat:@"茉莉ID:%@",model.uuid.length ? model.uuid : @"0"];
    
    NSString *userId = model.userId.length ? model.userId : model.consumerId;
    
    NSString *introductionStr = [[JAUserInfo userInfo_getUserImfoWithKey:User_id] isEqualToString:userId] ? @"你还没有个性签名" : @"他还没有个性签名";
    
    self.introductionLabel.text = model.introduce.length ? model.introduce : introductionStr;
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
}

#pragma mark - 点击事件
- (void)clickUserIcon
{
    if (self.clickIconImageBlock) {
        self.clickIconImageBlock(self.iconImageView.image,self.iconImageView);
    }
}

- (NSMutableAttributedString *)attributedString:(NSString *)text word:(NSString *)keyWord
{
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:text];
    
    // 获取关键字的位置
    NSRange rang = [text rangeOfString:keyWord];
    [attr addAttribute:NSFontAttributeName value:JA_REGULAR_FONT(12) range:rang];
    
    return attr;
}

- (void)jumpFansAndFocus
{
    if (self.clickFocusAndFansBlock) {
        self.clickFocusAndFansBlock();
    }
}

// 茉莉电台的点击事件
- (void)clickmoliFocusButton:(UIButton *)btn
{
    [self focusCustomer:btn];
}

- (void)clickmolicontribute:(UIButton *)btn
{
    [JAContributeIntroduceView showContributeViewWithLoopCount:0 text:self.rule];
}

- (void)setMoliRelationType:(NSInteger)moliRelationType
{
    _moliRelationType = moliRelationType;
    
    if (moliRelationType == 0) {
//        self.moliFocusButton.backgroundColor = HEX_COLOR(JA_BoardLineColor);
        self.moliFocusButton.backgroundColor = [UIColor clearColor];
//        [self.moliFocusButton setTitleColor:HEX_COLOR(JA_BlackSubTitle) forState:UIControlStateNormal];
        [self.moliFocusButton setTitleColor:HEX_COLOR(JA_BlackSubTitle) forState:UIControlStateNormal];
        [self.moliFocusButton setTitle:@"已关注" forState:UIControlStateNormal];
//        self.moliFocusButton.layer.borderWidth = 0;
        self.moliFocusButton.layer.borderWidth = 1;
        self.moliFocusButton.layer.borderColor = HEX_COLOR(JA_BlackSubTitle).CGColor;
    } else if(moliRelationType == 1) {
//        self.moliFocusButton.backgroundColor = HEX_COLOR(JA_BoardLineColor);
        self.moliFocusButton.backgroundColor = [UIColor clearColor];
//        [self.moliFocusButton setTitleColor:HEX_COLOR(JA_BlackSubTitle) forState:UIControlStateNormal];
        [self.moliFocusButton setTitleColor:HEX_COLOR(JA_BlackSubTitle) forState:UIControlStateNormal];
        [self.moliFocusButton setTitle:@"相互关注" forState:UIControlStateNormal];
//        self.moliFocusButton.layer.borderWidth = 0;
        self.moliFocusButton.layer.borderWidth = 1;
        self.moliFocusButton.layer.borderColor = HEX_COLOR(JA_BlackSubTitle).CGColor;
    } else {
        self.moliFocusButton.backgroundColor = [UIColor clearColor];
        [self.moliFocusButton setTitleColor:HEX_COLOR(JA_Green) forState:UIControlStateNormal];
        [self.moliFocusButton setTitle:@"+关注" forState:UIControlStateNormal];
        self.moliFocusButton.layer.borderWidth = 1;
        self.moliFocusButton.layer.borderColor = HEX_COLOR(JA_Green).CGColor;
    }
}

// 关注人
- (void)focusCustomer:(UIButton *)btn
{
    if (!IS_LOGIN) {
        [JAAPPManager app_modalLogin];
        return;
    }
    
    btn.userInteractionEnabled = NO;
    if (self.model.friendType.integerValue == 0 || self.model.friendType.integerValue == 1) {
        
        // 取消关注
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
        dic[@"concernId"] = self.model.userId.length ? self.model.userId : self.model.consumerId;
        
        
        [[JAVoicePersonApi shareInstance] voice_personalCancleFocusUseroWithParas:dic success:^(NSDictionary *result) {
            
            NSString *type = [NSString stringWithFormat:@"%@",result[@"friend"][@"friendType"]];
            self.model.friendType = type;
            self.moliRelationType = type.integerValue;
            btn.userInteractionEnabled = YES;
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"id"] = self.model.userId.length ? self.model.userId : self.model.consumerId;
            dic[@"status"] = type;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"searchRefreshFocusStatusFalse" object:dic];
            
        } failure:^(NSError *error) {
            btn.userInteractionEnabled = YES;
            [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:error.localizedDescription];
        }];
        
        return;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"concernId"] = self.model.userId.length ? self.model.userId : self.model.consumerId;
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    
    
    [[JAVoicePersonApi shareInstance] voice_personalFocusUserWithParas:dic success:^(NSDictionary *result) {
        
        NSString *type = [NSString stringWithFormat:@"%@",result[@"friend"][@"friendType"]];
        self.model.friendType = type;
        self.moliRelationType = type.integerValue;
        btn.userInteractionEnabled = YES;
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"id"] = self.model.userId.length ? self.model.userId : self.model.consumerId;
        dic[@"status"] = type;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"searchRefreshFocusStatusTrue" object:dic];
        
    } failure:^(NSError *error) {
        btn.userInteractionEnabled = YES;
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:error.localizedDescription];
    }];
}

#pragma mark - 刷新关注按钮
//- (void)refreshFocusStatusTrue:(NSNotification *)noti
//{
//    if ([self checkMoliDianTai:self.model.userId] || [self checkMoliDianTai:self.model.consumerId]) {
//        NSDictionary *dic = noti.object;
//        NSString *userId = dic[@"id"];
//        NSString *type = dic[@"status"];
//        NSString *modelUserId = self.model.userId.length ? self.model.userId : self.model.consumerId;
//        if ([userId isEqualToString:modelUserId]) {
//            
//            self.moliRelationType = type.integerValue;
//        }
//    }
//}
//
//- (void)refreshFocusStatusFalse:(NSNotification *)noti
//{
//    if ([self checkMoliDianTai:self.model.userId] || [self checkMoliDianTai:self.model.consumerId]) {
//        NSDictionary *dic = noti.object;
//        NSString *userId = dic[@"id"];
//        NSString *type = dic[@"status"];
//        NSString *modelUserId = self.model.userId.length ? self.model.userId : self.model.consumerId;
//        if ([userId isEqualToString:modelUserId]) {
//            self.moliRelationType = type.integerValue;
//        }
//    }
//}

- (BOOL)checkMoliDianTai:(NSString *)userId
{
    if ([@"1275" isEqualToString:userId] || [@"1000449" isEqualToString:userId]) {
        return YES;
    }else{
        return NO;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
