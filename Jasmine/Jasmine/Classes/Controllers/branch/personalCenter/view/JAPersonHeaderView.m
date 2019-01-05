//
//  JAPersonHeaderView.m
//  Jasmine
//
//  Created by 刘宏亮 on 2017/12/4.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAPersonHeaderView.h"
#import "JAPersonalCenterPhotoView.h"
#import "JANewPersonMedalView.h"
#import "JANewPersonRelationView.h"

#define kTopHeight 343  // 250 + 130 - 37
#define kInfoHeight 130
#define kPhotoheight 148

@interface JAPersonHeaderView ()

// 关注粉丝获赞view
@property (nonatomic, weak) JANewPersonRelationView *relationView;
// 勋章view
@property (nonatomic, weak) JANewPersonMedalView *medalView;
// 照片墙
@property (nonatomic, weak) JAPersonalCenterPhotoView *photoView;

@property (nonatomic, weak) UIView *lineView1;
@end

@implementation JAPersonHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupHeaderView];
    }
    return self;
}

- (void)setupHeaderView
{
    JANewPersonalInfoView *topInfoView = [[JANewPersonalInfoView alloc] init];
    _topInfoView = topInfoView;
    topInfoView.width = JA_SCREEN_WIDTH;
    topInfoView.height = 228 + 20 + 17;
    UITapGestureRecognizer *tapIcon = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickPersonIcon)];
    [topInfoView.iconImageView addGestureRecognizer:tapIcon];
    [topInfoView.editButton addTarget:self action:@selector(clickEditAction:) forControlEvents:UIControlEventTouchUpInside];
    [topInfoView.focusButton addTarget:self action:@selector(clickFollowAction:) forControlEvents:UIControlEventTouchUpInside];
    [topInfoView.messageButton addTarget:self action:@selector(clickMessageAction:) forControlEvents:UIControlEventTouchUpInside];
    [topInfoView.contributeButton addTarget:self action:@selector(clickContributeAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:topInfoView];
    
    JANewPersonRelationView *relationView = [[JANewPersonRelationView alloc] init];
    _relationView = relationView;
    relationView.width = JA_SCREEN_WIDTH;
    relationView.height = 50;
    UITapGestureRecognizer *followTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickFollowAndFans)];
    [relationView.followLabel addGestureRecognizer:followTap];
    UITapGestureRecognizer *fansTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickFollowAndFans)];
    [relationView.fansLabel addGestureRecognizer:fansTap];
    [self addSubview:relationView];
    
    JANewPersonMedalView *medalView = [[JANewPersonMedalView alloc] init];
    _medalView = medalView;
    medalView.width = JA_SCREEN_WIDTH;
    medalView.height = 50;
    medalView.hidden = YES;
    UITapGestureRecognizer *medalTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickMedalAction)];
    [medalView addGestureRecognizer:medalTap];
    [self addSubview:medalView];
    
    JAPersonalCenterPhotoView *photoView = [[JAPersonalCenterPhotoView alloc] init];
    _photoView = photoView;
    photoView.backgroundColor = HEX_COLOR(0xf9f9f9);
    photoView.hidden = YES;
    self.photoView.width = JA_SCREEN_WIDTH;
    self.photoView.height = kPhotoheight;
    [self addSubview:photoView];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGSize maxS = CGSizeMake(JA_SCREEN_WIDTH - 36, MAXFLOAT);
    NSString *text = self.personModel.introduce.length ? self.personModel.introduce:@"你还没有个性签名";
    CGFloat topH = [text boundingRectWithSize:maxS options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : JA_LIGHT_FONT(13)} context:nil].size.height;
    self.topInfoView.height = 228 + 20 + topH;
    [self.topInfoView layoutIfNeeded];
    
    if ([self checkMoliDianTai:self.personModel.userId] || [self checkMoliDianTai:self.personModel.consumerId]) {
        self.relationView.hidden = YES;
    }else{
        self.relationView.hidden = NO;
        self.relationView.y = self.topInfoView.bottom;
    }
    
    self.medalView.y = self.relationView.hidden ? self.topInfoView.bottom : self.relationView.bottom;
    
    if (self.medalView.hidden == NO) {
        self.photoView.y = self.medalView.bottom;
    }else if (self.relationView.hidden == NO){
        self.photoView.y = self.relationView.bottom;
    }else{
        self.photoView.y = self.topInfoView.bottom;
    }
}


- (void)setTopOffY:(CGFloat)topOffY
{
    _topOffY = topOffY;
    
    self.topInfoView.topOffY = topOffY;
}

- (void)setHasPhoto:(BOOL)hasPhoto
{
    _hasPhoto = hasPhoto;
    self.photoView.hidden = !hasPhoto;
}

- (void)setPersonModel:(JAConsumer *)personModel
{
    _personModel = personModel;
    self.topInfoView.model = personModel;
    
    self.relationView.model = personModel;
    
    self.photoView.userId = personModel.userId.length ? personModel.userId : personModel.consumerId;
    self.photoView.sex = personModel.sex;
    self.photoView.photoArray = self.personPhoneArray;
    
    self.medalView.hidden = personModel.medalList.count > 0 ? NO:YES;
    self.medalView.model = personModel;
 
    [self setNeedsLayout];
    [self layoutSubviews];
}

- (void)setRelationType:(NSInteger)relationType
{
    _relationType = relationType;
    
    if (!IS_LOGIN) {
        self.topInfoView.focusButton.selected = NO;
    }else{
        if (relationType == 0 || relationType == 1) {
            self.topInfoView.focusButton.selected = YES;
            
        } else {
            self.topInfoView.focusButton.selected = NO;
        }
    }
    [self.topInfoView setNeedsLayout];
    [self.topInfoView layoutIfNeeded];
}

//- (void)setRuleContribute:(NSString *)ruleContribute
//{
//    _ruleContribute = ruleContribute;
//
//    self.infoView.rule = ruleContribute;
//}

#pragma mark - 按钮的点击
// 点击个人头像
- (void)clickPersonIcon
{
    if (self.clickPersomalIconImageBlock) {
        self.clickPersomalIconImageBlock(self.topInfoView.iconImageView.image,self.topInfoView.iconImageView);
    }
}

// 点击关注和粉丝
- (void)clickFollowAndFans
{
    if (self.clickPersomalFocusAndFansBlock) {
        self.clickPersomalFocusAndFansBlock();
    }
}

// 点击编辑
- (void)clickEditAction:(UIButton *)btn
{
    if (self.clickPersonalEditAction) {
        self.clickPersonalEditAction();
    }
}
// 点击关注
- (void)clickFollowAction:(UIButton *)btn
{
    if (self.clickPersonalFollowAction) {
        self.clickPersonalFollowAction(btn);
    }
}
// 点击投稿须知
- (void)clickContributeAction:(UIButton *)btn
{
    if (self.clickPersonalContributeAction) {
        self.clickPersonalContributeAction();
    }
}
// 点击私信
- (void)clickMessageAction:(UIButton *)btn
{
    if (self.clickPersonalMessageAction) {
        self.clickPersonalMessageAction();
    }
}

- (void)clickMedalAction
{
    if (self.clickPersonalMedalAction) {
        self.clickPersonalMedalAction();
    }
}

- (BOOL)checkMoliDianTai:(NSString *)userId
{
    if ([@"1275" isEqualToString:userId] || [@"1000449" isEqualToString:userId]) {
        return YES;
    }else{
        return NO;
    }
}
@end
