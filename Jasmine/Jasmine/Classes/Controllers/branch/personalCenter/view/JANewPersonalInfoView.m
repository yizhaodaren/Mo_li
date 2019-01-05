//
//  JANewPersonalInfoView.m
//  Jasmine
//
//  Created by moli-2017 on 2018/7/12.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JANewPersonalInfoView.h"
#import "JAPaddingLabel.h"
#import "JAPersonalTopImageView.h"

@interface JANewPersonalInfoView ()

@property (nonatomic, weak) JAPersonalTopImageView *topImageView;

@property (nonatomic, weak) UILabel *nameLabel;    // 名字
@property (nonatomic, weak) JAPaddingLabel *officTagLabel;  // 官方标签
@property (nonatomic, weak) UIImageView *levelImageView;  // 等级图片
@property (nonatomic, weak) UIImageView *medalImageView;  // 勋章图片
@property (nonatomic, weak) UILabel *moliIdLabel;   // 茉莉id
@property (nonatomic, weak) UIButton *sexButton;  // 性别
@property (nonatomic, weak) JAPaddingLabel *constellationLabel;   // 星座
@property (nonatomic, weak) JAPaddingLabel *locationLabel;  // 地址

@property (nonatomic, weak) UILabel *introductionLabel; // 介绍

@end

@implementation JANewPersonalInfoView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupNewPersonalInfoViewUI];
    }
    return self;
}

- (void)setupNewPersonalInfoViewUI
{
    JAPersonalTopImageView *topImageView = [[JAPersonalTopImageView alloc] init];
    _topImageView = topImageView;
    topImageView.width = JA_SCREEN_WIDTH;
    topImageView.height = 228;
    [self addSubview:topImageView];
    
    UIImageView *iconImageView = [[UIImageView alloc] init];
    iconImageView.backgroundColor = [UIColor clearColor];
    iconImageView.userInteractionEnabled = YES;
    iconImageView.layer.borderWidth = 2;
    iconImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    _iconImageView = iconImageView;
    iconImageView.image = [UIImage imageNamed:@"moren_nan"];
    [self addSubview:iconImageView];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    _nameLabel = nameLabel;
    nameLabel.text = @" ";
    nameLabel.textColor = HEX_COLOR(0xffffff);
    nameLabel.font = JA_MEDIUM_FONT(20);
    [self addSubview:nameLabel];
    
    UIImageView *levelImageView = [[UIImageView alloc] init];
    _levelImageView = levelImageView;
    levelImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:levelImageView];
    
    UIImageView *medalImageView = [[UIImageView alloc] init];
    _medalImageView = medalImageView;
    [self addSubview:medalImageView];
    
    // 茉莉ID
    UILabel *moliIdLabel = [[UILabel alloc] init];
    _moliIdLabel = moliIdLabel;
    moliIdLabel.text = @"茉莉ID：0";
    moliIdLabel.textColor = HEX_COLOR(0xffffff);
    moliIdLabel.font = JA_REGULAR_FONT(12);
    [self addSubview:moliIdLabel];
    
    // 性别
    UIButton *sexButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _sexButton = sexButton;
    [sexButton setImage:[UIImage imageNamed:@"branch_new_person_man"] forState:UIControlStateNormal];
    [sexButton setImage:[UIImage imageNamed:@"branch_new_person_woman"] forState:UIControlStateSelected];
    [self addSubview:sexButton];
    
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
    constellationLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:constellationLabel];
    
    // 地址
    JAPaddingLabel *locationLabel = [[JAPaddingLabel alloc] init];
    _locationLabel = locationLabel;
    locationLabel.backgroundColor = HEX_COLOR(0x6BD379);
    locationLabel.textColor = HEX_COLOR(0xffffff);
    locationLabel.text = @"火星";
    locationLabel.font = JA_REGULAR_FONT(10);
    locationLabel.edgeInsets = UIEdgeInsetsMake(0, 3, 0, 3);
    locationLabel.layer.cornerRadius = 2;
    locationLabel.layer.masksToBounds = YES;
    locationLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:locationLabel];
    
    // 介绍
    UILabel *introductionLabel = [[UILabel alloc] init];
    _introductionLabel = introductionLabel;
    introductionLabel.text = @"他还没有个性签名";
    introductionLabel.textColor = HEX_COLOR(0x9B9B9B);
    introductionLabel.font = JA_LIGHT_FONT(13);
    introductionLabel.numberOfLines = 0;
    [self addSubview:introductionLabel];
    
    // 编辑
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _editButton = editButton;
    [editButton setTitle:@"编辑" forState:UIControlStateNormal];
    [editButton setImage:[UIImage imageNamed:@"branch_new_person_edit"] forState:UIControlStateNormal];
    [editButton setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateNormal];
    editButton.titleLabel.font = JA_MEDIUM_FONT(15);
    editButton.backgroundColor = HEX_COLOR_ALPHA(0x000000, 0.3);
    editButton.layer.cornerRadius = 4;
    editButton.layer.masksToBounds = YES;
    [self addSubview:editButton];
    
    // 关注
    UIButton *focusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _focusButton = focusButton;
    [focusButton setTitle:@"关注" forState:UIControlStateNormal];
    [focusButton setTitle:@"" forState:UIControlStateSelected];
    [focusButton setTitle:@"" forState:UIControlStateSelected | UIControlStateHighlighted];
    [focusButton setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateNormal];
    focusButton.titleLabel.font = JA_MEDIUM_FONT(15);
    [focusButton setImage:[UIImage imageNamed:@"branch_new_person_follow"] forState:UIControlStateNormal];
    [focusButton setImage:[UIImage imageNamed:@"branch_new_person_followed"] forState:UIControlStateSelected];
    [focusButton setImage:[UIImage imageNamed:@"branch_new_person_followed"] forState:UIControlStateSelected | UIControlStateHighlighted];
    focusButton.backgroundColor = HEX_COLOR_ALPHA(0x000000, 0.3);
    focusButton.layer.cornerRadius = 4;
    focusButton.layer.masksToBounds = YES;
    [self addSubview:focusButton];
    
    // 私信
    UIButton *messageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _messageButton = messageButton;
    [messageButton setImage:[UIImage imageNamed:@"branch_new_person_msg"] forState:UIControlStateNormal];
    messageButton.backgroundColor = HEX_COLOR_ALPHA(0x000000, 0.3);
    messageButton.layer.cornerRadius = 4;
    messageButton.layer.masksToBounds = YES;
    [self addSubview:messageButton];
    
    // 投稿须知
    UIButton *contributeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _contributeButton = contributeButton;
    [contributeButton setTitle:@"投稿须知" forState:UIControlStateNormal];
    [contributeButton setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateNormal];
    contributeButton.titleLabel.font = JA_MEDIUM_FONT(15);
    contributeButton.backgroundColor = HEX_COLOR_ALPHA(0x000000, 0.3);
    contributeButton.layer.cornerRadius = 4;
    contributeButton.layer.masksToBounds = YES;
    [self addSubview:contributeButton];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorNewPersonalInfoViewFrame];
}

- (void)calculatorNewPersonalInfoViewFrame
{
    // t头像
    self.iconImageView.width = 70;
    self.iconImageView.height = 70;
    self.iconImageView.x = 15;
    self.iconImageView.y = 80;
    self.iconImageView.layer.cornerRadius = self.iconImageView.height * 0.5;
    self.iconImageView.layer.masksToBounds = YES;
    // 私信
    self.messageButton.width = 38;
    self.messageButton.height = 38;
    self.messageButton.y = self.iconImageView.y;
    // 关注
    [self.focusButton sizeToFit];
    self.focusButton.width += 22;
    self.focusButton.height = 38;
    self.focusButton.y = self.iconImageView.y;
    // 编辑
    self.editButton.width = 80;
    self.editButton.height = 38;
    self.editButton.y = self.iconImageView.y;
    // 投稿须知
    self.contributeButton.width = 80;
    self.contributeButton.height = 38;
    self.contributeButton.y = self.iconImageView.y;
    
    // 茉莉电台
    if ([self checkMoliDianTai:self.model.userId] || [self checkMoliDianTai:self.model.consumerId]) {
        if ([self checkMyIdnetity]) {  // 自己
            self.editButton.hidden = NO;
            self.messageButton.hidden = YES;
            self.focusButton.hidden = YES;
            self.contributeButton.hidden = NO;
            self.contributeButton.x = self.width - 15 - self.contributeButton.width;
            self.editButton.x = self.contributeButton.x - 5 - self.editButton.width;
        }else{
            self.editButton.hidden = YES;
            self.messageButton.hidden = YES;
            self.focusButton.hidden = NO;
            self.contributeButton.hidden = NO;
            self.contributeButton.x = self.width - 15 - self.contributeButton.width;
            self.focusButton.x = self.contributeButton.x - 5 - self.focusButton.width;
        }
    }else if ([self checkMyIdnetity]){  // 自己
        self.editButton.hidden = NO;
        self.messageButton.hidden = YES;
        self.focusButton.hidden = YES;
        self.contributeButton.hidden = YES;
        self.editButton.x = self.width - 15 - self.editButton.width;
    }else{  // 别人
        self.editButton.hidden = YES;
        self.messageButton.hidden = NO;
        self.focusButton.hidden = NO;
        self.contributeButton.hidden = YES;
        self.messageButton.x = self.width - 15 - self.messageButton.width;
        self.focusButton.x = self.messageButton.x - 5 - self.focusButton.width;
    }
    
    // 名字
    [self.nameLabel sizeToFit];
    if (self.nameLabel.width > self.width * 0.7) {
        self.nameLabel.width = self.width * 0.7;
    }
    self.nameLabel.height = 20;
    self.nameLabel.x = self.iconImageView.x;
    self.nameLabel.y = self.iconImageView.bottom + 15;
    
    // 头衔
    self.levelImageView.width = 20;
    self.levelImageView.height = 20;
    self.levelImageView.x = self.nameLabel.right;
    self.levelImageView.centerY = self.nameLabel.centerY;
    
    // 勋章
    self.medalImageView.width = 20;
    self.medalImageView.height = 16;
    self.medalImageView.x = self.levelImageView.right;
    self.medalImageView.centerY = self.nameLabel.centerY;
    
    // 茉莉id
    [self.moliIdLabel sizeToFit];
    self.moliIdLabel.height = 17;
    self.moliIdLabel.x = self.nameLabel.x;
    self.moliIdLabel.y = self.nameLabel.bottom + 10;
    
    // 性别
    self.sexButton.width = 14;
    self.sexButton.height = 14;
    self.sexButton.x = self.moliIdLabel.right + 10;
    self.sexButton.centerY = self.moliIdLabel.centerY;
    
    // 星座
    self.constellationLabel.width = 40;
    self.constellationLabel.height = 14;
    self.constellationLabel.x = self.sexButton.right + 5;
    self.constellationLabel.centerY = self.sexButton.centerY;
    
    // 地址
    [self.locationLabel sizeToFit];
    self.locationLabel.width += 6;
    self.locationLabel.height = 14;
    self.locationLabel.x = self.constellationLabel.hidden ? self.sexButton.right + 5 : self.constellationLabel.right + 5;
    self.locationLabel.centerY = self.sexButton.centerY;
    
    // 介绍
    self.introductionLabel.width = self.width - 36;
    [self.introductionLabel sizeToFit];
    self.introductionLabel.width = self.width - 36;
    self.introductionLabel.x = 18;
    self.introductionLabel.y = self.topImageView.bottom + 10;
}

// 赋值
- (void)setModel:(JAConsumer *)model
{
    _model = model;
    
    // 背景
    self.topImageView.imageName = model.image;
    
    // 头像
    int h = 375;
    int w = 375;
    NSString *imageurl = [model.image ja_getFitImageStringWidth:w height:h];
    [self.iconImageView ja_setImageWithURLStr:imageurl placeholder:[UIImage imageNamed:@"moren_nan"]];
    
    // 姓名
    self.nameLabel.text = model.name;
    
    // 头衔
//    [self.levelImageView sd_setImageWithURL:[NSURL URLWithString:model.crown.smallImage]];
    [self.levelImageView ja_setImageWithURLStr:[model.crown.smallImage ja_getFitImageStringWidth:10 height:14]];
//    [self.levelImageView sd_setImageWithURL:[NSURL URLWithString:]];
    
    // 佩戴勋章
    [self.medalImageView ja_setImageWithURLStr:model.medalConfig.getImgUrl];
    
    // 茉莉id
    self.moliIdLabel.text = [NSString stringWithFormat:@"茉莉ID:%@",model.uuid.length ? model.uuid : @"0"];
    
    // 性别
    self.sexButton.selected = model.sex.integerValue == 2 ? YES : NO;
    
    // 星座
    if (model.constellation.length) {
        self.constellationLabel.hidden = NO;
        self.constellationLabel.text = model.constellation;
    }else{
        self.constellationLabel.hidden = YES;
    }
    
    // 位置
    self.locationLabel.text = model.address.length ? model.address : @"火星";
    
    // 签名
    NSString *introductionStr = [self checkMyIdnetity] ? @"你还没有个性签名" : @"他还没有个性签名";
    self.introductionLabel.text = model.introduce.length ? model.introduce : introductionStr;
    
    [self layoutIfNeeded];
    [self setNeedsLayout];
}

// t图片
- (void)setTopOffY:(CGFloat)topOffY
{
    _topOffY = topOffY;
    if (topOffY <= 0) {
        self.topImageView.frame = CGRectMake(0, topOffY, JA_SCREEN_WIDTH, 228 - topOffY);
    }else{
//        CGFloat y = topOffY > 228 ? 228 : topOffY;
        self.topImageView.frame = CGRectMake(0, 0, JA_SCREEN_WIDTH, 228);
    }
}

// 是否是茉莉君或者茉莉电台
- (BOOL)checkMoliDianTai:(NSString *)userId
{
    if ([@"1275" isEqualToString:userId] || [@"1000449" isEqualToString:userId]) {
        return YES;
    }else{
        return NO;
    }
}

- (BOOL)checkMyIdnetity
{
    // 获取本地id
    NSString *localID = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    if ([localID isEqualToString:self.model.userId] || [localID isEqualToString:self.model.consumerId]) {
        return YES;
    }else{
        return NO;
    }
}
@end
