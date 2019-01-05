//
//  JAVocieTableViewCell.m
//  Jasmine
//
//  Created by xujin on 29/08/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JAVoiceCommentHeaderView.h"
#import "JAPlayWaveView.h"
#import "JAPaddingLabel.h"
#import "JAVoiceCommonApi.h"
#import "JAVoicePersonApi.h"
#import "AppDelegateModel.h"
#import "DMHeartFlyView.h"
//#import "JAVoiceAgreeButton.h"
#import "JASampleHelper.h"
#import "JAEmitterView.h"
#import "KNPhotoBrower.h"
#import "JAPhotoModel.h"
#import "JANewPlayWaveView.h"
#import "KILabel.h"
#import "JAPlayLoadingView.h"
#import "JAVoicePlayerManager.h"

@interface JAShapeLayerImageView : UIImageView

@end

@implementation JAShapeLayerImageView

+ (Class)layerClass {
    return [CAShapeLayer class];
}

@end

@interface JAVoiceCommentHeaderView ()<JAPlayerDelegate,JAEmitterViewDelegate,KNPhotoBrowerDelegate>

@property (nonatomic, strong) UIImageView *leftImageView;

@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UILabel *nicknameLabel;
@property (nonatomic, strong) UIImageView *xiaomoliImageView;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *locationLabel;

@property (nonatomic, strong) UIButton *focusButton;


@property (nonatomic, strong) UIView *picView;
@property (nonatomic, strong) JAShapeLayerImageView *picView_ImageView1;
@property (nonatomic, strong) JAShapeLayerImageView *picView_ImageView2;
@property (nonatomic, strong) JAShapeLayerImageView *picView_ImageView3;

@property (nonatomic, strong) JAEmitterView *agreeButton;
@property (nonatomic, strong) UIButton *commentButton;
@property (nonatomic, strong) UIButton *playButton;

@property (nonatomic, strong) UILabel *durationLabel;

@property (nonatomic, weak) UIView *lineView;
//@property (nonatomic, strong) JAPlayWaveView *playWaveView;
@property (nonatomic, strong) JANewPlayWaveView *playWaveView1;

@property (nonatomic, assign) BOOL lastAgreeState;// 0未点赞1已赞

@property (nonatomic, assign) int allCount;
@property (nonatomic, assign) CGFloat waveViewWidth;

//@property (nonatomic, assign) CGPoint tapPoint;

@property (nonatomic, assign) NSInteger headerTapCount;

@property (nonatomic, strong) NSString *agreeMethod;
@property (nonatomic, strong) UIImageView *voiceWaveViewBG;

@property (nonatomic, assign) NSTimeInterval frontTime;


// v2.5.4 JAPaddingLabel修改为KILabel
@property (nonatomic, strong) KILabel *contentLabel;
@property (nonatomic, strong) UIView *labelBGView;

// v2.5.5
@property (nonatomic, strong) JAPlayLoadingView *playLoadingView;

@end

@implementation JAVoiceCommentHeaderView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[JAVoicePlayerManager shareInstance] removeDelegate:self];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        self.backgroundColor = HEX_COLOR(JA_Background);
//        self.backgroundColor = [UIColor redColor];
        
        UIImageView *leftImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"jinghua"]];
        [self addSubview:leftImageView];
        self.leftImageView = leftImageView;
        self.leftImageView.hidden = YES;
        
        UIImageView *headImageView = [UIImageView new];
        headImageView.userInteractionEnabled = YES;
        [headImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userInfoAction)]];
        [self addSubview:headImageView];
        self.headImageView = headImageView;
        
        UILabel *nicknameLabel = [UILabel new];
        nicknameLabel.text = @" ";
        nicknameLabel.textColor = HEX_COLOR(JA_Title);
        nicknameLabel.font = JA_REGULAR_FONT(13);
        nicknameLabel.userInteractionEnabled = YES;
        [nicknameLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userInfoAction)]];
        [self addSubview:nicknameLabel];
        self.nicknameLabel = nicknameLabel;
        [self.nicknameLabel sizeToFit];

        UIImageView *xiaomoliImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ximolitag"]];
        [self addSubview:xiaomoliImageView];
        xiaomoliImageView.hidden = YES;
        self.xiaomoliImageView = xiaomoliImageView;
        
        UILabel *timeLabel = [UILabel new];
        timeLabel.text = @" ";
        timeLabel.textColor = HEX_COLOR(0xc6c6c6);
        timeLabel.font = JA_REGULAR_FONT(12);
        timeLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:timeLabel];
        self.timeLabel = timeLabel;
        
        UIButton *focusButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [focusButton setTitle:@"+关注" forState:UIControlStateNormal];
        [focusButton setTitleColor:HEX_COLOR(JA_Green) forState:UIControlStateNormal];
        [focusButton setTitle:@"已关注" forState:UIControlStateSelected];
        [focusButton setTitleColor:HEX_COLOR(JA_BlackSubTitle) forState:UIControlStateSelected];
        focusButton.titleLabel.font = JA_REGULAR_FONT(11);
        focusButton.layer.borderColor = HEX_COLOR(JA_Green).CGColor;
        focusButton.layer.borderWidth = 1;
        [focusButton addTarget:self action:@selector(focusButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:focusButton];
        self.focusButton = focusButton;
        
        JAEmitterView *agreeButton = [[JAEmitterView alloc] initWithType:100];
        [agreeButton setImage:[UIImage imageNamed:@"voice_agree_nor"] forState:UIControlStateNormal];
        [agreeButton setImage:[UIImage imageNamed:@"voice_agree_nor"] forState:UIControlStateHighlighted];
        [agreeButton setImage:[UIImage imageNamed:@"voice_agree_sel"] forState:UIControlStateSelected];
        [agreeButton setImage:[UIImage imageNamed:@"voice_agree_sel"] forState:UIControlStateSelected|UIControlStateHighlighted];
        agreeButton.imageView.contentMode = UIViewContentModeCenter;
        [agreeButton setTitle:@"喜欢" forState:UIControlStateNormal];
        [agreeButton setTitleColor:HEX_COLOR(JA_BlackSubTitle) forState:UIControlStateNormal];
        agreeButton.titleLabel.font = JA_REGULAR_FONT(11);
        agreeButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        agreeButton.delegate = self;
        [self addSubview:agreeButton];
        self.agreeButton = agreeButton;
        
        // 在禁掉点赞button的时候，防止继续点击进入详情
        UIButton *zanBgButton = [UIButton buttonWithType:UIButtonTypeCustom];
        zanBgButton.frame = self.agreeButton.frame;
        [self insertSubview:zanBgButton belowSubview:self.agreeButton];
        
        UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [commentButton setImage:[UIImage imageNamed:@"voice_reply"] forState:UIControlStateNormal];
        [commentButton addTarget:self action:@selector(commentAction) forControlEvents:UIControlEventTouchUpInside];
        [commentButton setTitle:@"0" forState:UIControlStateNormal];
        [commentButton setTitleColor:HEX_COLOR(JA_BlackSubTitle) forState:UIControlStateNormal];
        commentButton.titleLabel.font = JA_REGULAR_FONT(11);
        [self addSubview:commentButton];
        self.commentButton = commentButton;
        
        UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [playButton setImage:[UIImage imageNamed:@"voice_play_btn"] forState:UIControlStateNormal];
        [playButton setImage:[UIImage imageNamed:@"voice_play_btn"] forState:UIControlStateHighlighted];
        [playButton setImage:[UIImage imageNamed:@"voice_pause_btn"] forState:UIControlStateSelected];
        [playButton setImage:[UIImage imageNamed:@"voice_pause_btn"] forState:UIControlStateSelected|UIControlStateHighlighted];
        [playButton addTarget:self action:@selector(playVoice) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:playButton];
        self.playButton = playButton;
        
        // 图片样式时的波形图
        self.playWaveView1 = [[JANewPlayWaveView alloc] initWithFrame:CGRectMake(0, 0, 35*2+48+10, 23)];
        [self insertSubview:self.playWaveView1 belowSubview:self.playButton];
        
        self.playLoadingView = [JAPlayLoadingView playLoadingViewWithType:0];
        self.playLoadingView.centerX = 48/2.0;
        self.playLoadingView.centerY = 48/2.0;
        [self.playButton addSubview:self.playLoadingView];
        
        UIView *labelBGView = [UIView new];
        labelBGView.backgroundColor = HEX_COLOR(0xF9F9F9);
        labelBGView.layer.cornerRadius = 5.0;
        labelBGView.layer.masksToBounds = YES;
        [self addSubview:labelBGView];
        self.labelBGView = labelBGView;
        
        KILabel *describeLabel = [KILabel new];
        describeLabel.text = @" ";
//        describeLabel.backgroundColor = [UIColor redColor];
        describeLabel.textColor = HEX_COLOR(0x4A4A4A);
        describeLabel.textAlignment = NSTextAlignmentCenter;
        describeLabel.font = JA_REGULAR_FONT(JA_CommentDetail_voiceFont);
        describeLabel.numberOfLines = 3;
//        describeLabel.edgeInsets = UIEdgeInsetsMake(12, 15, 12, 15);
        [labelBGView addSubview:describeLabel];
        
        describeLabel.linkDetectionTypes = KILinkTypeOptionHashtag | KILinkTypeOptionUserHandle;
        [describeLabel setAttributes:@{NSForegroundColorAttributeName : HEX_COLOR(0x54C7FC)} forLinkType:KILinkTypeHashtag];
        [describeLabel setAttributes:@{NSForegroundColorAttributeName : HEX_COLOR(0x54C7FC)} forLinkType:KILinkTypeUserHandle];
        @WeakObj(self);
        describeLabel.hashtagLinkTapHandler = ^(KILabel * _Nonnull label, NSString * _Nonnull string, NSRange range) {
            @StrongObj(self);
            if (string.length) {
                if (self.topicDetailBlock) {
                    self.topicDetailBlock(string);
                }
            }
        };
        describeLabel.userHandleLinkTapHandler = ^(KILabel * _Nonnull label, NSString * _Nonnull string, NSRange range) {
            @StrongObj(self);
            if (self.atPersonBlock) {
                self.atPersonBlock(string, self.data.atList);
            }
        };
        self.contentLabel = describeLabel;
        
        UILabel *locationLabel = [UILabel new];
        locationLabel.textColor = HEX_COLOR(0xC6C6C6);
        locationLabel.font = JA_MEDIUM_FONT(12);
        [self addSubview:locationLabel];
        locationLabel.text = @"火星";
        self.locationLabel = locationLabel;
        
        UILabel *durationLabel = [UILabel new];
        durationLabel.textColor = HEX_COLOR(0xC6C6C6);
        durationLabel.font = JA_MEDIUM_FONT(11);
        durationLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:durationLabel];
        self.durationLabel = durationLabel;
        
        UIImageView *voiceWaveViewBG = [[UIImageView alloc] initWithFrame:CGRectMake(12, 0, JA_SCREEN_WIDTH-12*2, 50)];
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:voiceWaveViewBG.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(5, 5)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = voiceWaveViewBG.bounds;
        maskLayer.path = maskPath.CGPath;
        voiceWaveViewBG.layer.mask = maskLayer;
        voiceWaveViewBG.backgroundColor = [UIColor clearColor];
        [self addSubview:voiceWaveViewBG];
        self.voiceWaveViewBG = voiceWaveViewBG;
        
        JANewVoiceWaveView *voiceWaveView = [[JANewVoiceWaveView alloc] initWithFrame:CGRectMake(0, 0, voiceWaveViewBG.width, 50)];
        self.voiceWaveView.maskColor = HEX_COLOR(0xffffff);
        self.voiceWaveView.darkGrayColor = HEX_COLOR_ALPHA(0xffffff, 0.5);
        [self.voiceWaveViewBG addSubview:voiceWaveView];
        self.voiceWaveView = voiceWaveView;
        self.voiceWaveView.sliderIV.x = -3;
        
        // 多张图片
        self.picView = [[UIView alloc] init];
        self.picView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.picView];
        
        self.picView_ImageView1 = [[JAShapeLayerImageView alloc] init];
        self.picView_ImageView1.userInteractionEnabled = YES;
//        self.picView_ImageView1.contentMode = UIViewContentModeScaleAspectFill;
        self.picView_ImageView1.clipsToBounds = YES;
        self.picView_ImageView1.tag = 0;
        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showBigPicture:)];
        [self.picView_ImageView1 addGestureRecognizer:tap1];
        [self.picView addSubview:self.picView_ImageView1];
        
        self.picView_ImageView2 = [[JAShapeLayerImageView alloc] init];
        self.picView_ImageView2.userInteractionEnabled = YES;
//        self.picView_ImageView2.contentMode = UIViewContentModeScaleAspectFill;
        self.picView_ImageView2.clipsToBounds = YES;
        self.picView_ImageView2.tag = 1;
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showBigPicture:)];
        [self.picView_ImageView2 addGestureRecognizer:tap2];
        [self.picView addSubview:self.picView_ImageView2];
        
        self.picView_ImageView3 = [[JAShapeLayerImageView alloc] init];
        self.picView_ImageView3.userInteractionEnabled = YES;
//        self.picView_ImageView3.contentMode = UIViewContentModeScaleAspectFill;
        self.picView_ImageView3.clipsToBounds = YES;
        self.picView_ImageView3.tag = 2;
        UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showBigPicture:)];
        [self.picView_ImageView3 addGestureRecognizer:tap3];
        [self.picView addSubview:self.picView_ImageView3];
    
        UIView *lineView = [[UIView alloc] init];
        _lineView = lineView;
        lineView.backgroundColor = HEX_COLOR(0xf4f4f4);
        [self insertSubview:lineView belowSubview:self.voiceWaveViewBG];
        
        _waveViewWidth = [JASampleHelper getViewWidthWithType:JADisplayTypeStory];
        _allCount = [JASampleHelper getAllCountWithViewWidth:_waveViewWidth];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playNotification:) name:JAPlayNotification object:nil];
        [[JAVoicePlayerManager shareInstance] addDelegate:self];
        
        // 单双击手势
//        UITapGestureRecognizer *waveSignTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sigleShowHeardShape:)];
//        [self addGestureRecognizer:waveSignTap];
        
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
    NSString *modelUserId = self.data.userId;
    if ([userId isEqualToString:modelUserId]) {
        self.focusButton.backgroundColor = HEX_COLOR(JA_BoardLineColor);
        [self.focusButton setTitleColor:HEX_COLOR(JA_BlackSubTitle) forState:UIControlStateNormal];
        [self.focusButton setTitle:@"已关注" forState:UIControlStateNormal];
        self.focusButton.layer.borderWidth = 0;
        self.focusButton.selected = YES;
    }
}

- (void)refreshFocusStatusFalse:(NSNotification *)noti
{
    NSDictionary *dic = noti.object;
    NSString *userId = dic[@"id"];
    NSString *modelUserId = self.data.userId;
    if ([userId isEqualToString:modelUserId]) {
        self.focusButton.selected = NO;
        self.focusButton.backgroundColor = [UIColor clearColor];
        [self.focusButton setTitleColor:HEX_COLOR(JA_Green) forState:UIControlStateNormal];
        [self.focusButton setTitle:@"+关注" forState:UIControlStateNormal];
        self.focusButton.layer.borderWidth = 1;
    }
}

#pragma mark - 点赞的代理方法
- (void)emitterViewClickSingle:(JAEmitterView *)button
{
    if (!IS_LOGIN) {
        [JAAPPManager app_modalLogin];
        return;
    }

    if (button.selected) {
        
        if ([self checkTimeMargin]) {
            [self agreeAction:button];
        }
    }else{
        
        [self agreeAction:button];
    }
}

// 判断时间间隔是否大于0.3
- (BOOL)checkTimeMargin
{
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] * 1000;
    if (interval - self.frontTime > 1300) {
        
        self.frontTime = interval;
        return YES;
    }
    self.frontTime = interval;
    return NO;
}

- (void)emitterViewClickLongSingle:(JAEmitterView *)button
{
    if (!IS_LOGIN) {
        [JAAPPManager app_modalLogin];
        return;
    }

    if (!button.selected) {
        [self agreeAction:button];
    }
}

#pragma mark - 头部的手势 -- 展示心的单双击
//- (void)sigleShowHeardShape:(UITapGestureRecognizer *)tap
//{
//    if (self.adminActionVoicePosts) {
//        self.adminActionVoicePosts(self);   // 管理员操作帖子 和 退下键盘
//    }
//    _headerTapCount++;
//
//    if (_headerTapCount > 1) {
//        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(singleHeaderTap) object:nil];
//        [self doubleHeaderTap:tap];
//    }else{
//
//        [self performSelector:@selector(singleHeaderTap) withObject:nil afterDelay:0.3];
//    }
//}

//- (void)singleHeaderTap
//{
//    [self resetHeaderTapCount]; // 清0
//
//    if (self.adminActionVoicePosts) {
//        self.adminActionVoicePosts(self);
//    }
//}
//
//- (void)doubleHeaderTap:(UITapGestureRecognizer *)tap
//{
//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resetHeaderTapCount) object:nil];
//    [self performSelector:@selector(resetHeaderTapCount) withObject:nil afterDelay:0.3];
//    [self showHeardShape:tap];
//}
//
//- (void)resetHeaderTapCount
//{
//    _headerTapCount = 0;
//}
//// 展示心
//- (void)showHeardShape:(UITapGestureRecognizer *)tap
//{
//    if (!IS_LOGIN) {
//        [JAAPPManager app_modalLogin];
//        return;
//    }
//    CGPoint touchPoint = [tap locationInView:self];
//    if (CGRectContainsPoint(self.agreeButton.frame, touchPoint) ||
//        CGRectContainsPoint(self.playButton.frame, touchPoint)) {
//        return;
//    }
//    if (!IS_LOGIN) {
//        [JAAPPManager app_modalLogin];
//        return;
//    }
//    if (!self.agreeButton.selected) {  // 没有点赞掉一次点赞接口
//
//        [self doubleClickAgreeAction:self.agreeButton];
//    }
////    CGPoint winPoint = [self convertPoint:self.tapPoint toView:[[[UIApplication sharedApplication] delegate] window]];
//    CGPoint point = [tap locationInView:tap.view];
//    CGPoint winPoint = [tap.view convertPoint:point toView:[[[UIApplication sharedApplication] delegate] window]];
//
//    DMHeartFlyView* heart = [[DMHeartFlyView alloc]initWithFrame:CGRectMake(0, 0, 70, 60)];
//    heart.userInteractionEnabled = NO;
//    [[[[UIApplication sharedApplication] delegate] window] addSubview:heart];
//    heart.center = CGPointMake(winPoint.x, winPoint.y - heart.height * 0.7);
//    [heart animateInView:[[[UIApplication sharedApplication] delegate] window]];
//}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat padding = 12;
    
    self.headImageView.width = 35;
    self.headImageView.height = self.headImageView.width;
    self.headImageView.x = padding;
    self.headImageView.y = 10;
    self.headImageView.layer.cornerRadius = self.headImageView.height * 0.5;
    self.headImageView.layer.masksToBounds = YES;
    
    if (self.nicknameLabel.width > 100) {
        self.nicknameLabel.width = 100;
    }
    self.nicknameLabel.height = 18;
    self.nicknameLabel.x = self.headImageView.right + 12;
    self.nicknameLabel.y = 12;
    
    self.xiaomoliImageView.x = self.nicknameLabel.right + 10;
    self.xiaomoliImageView.centerY = self.nicknameLabel.centerY;
    
    [self.locationLabel sizeToFit];
    if (self.locationLabel.width > 75) {
        self.locationLabel.width = 75;
    }
    self.locationLabel.height = 17;
    self.locationLabel.x = self.nicknameLabel.x;
    self.locationLabel.y = self.nicknameLabel.bottom;
    
    [self.timeLabel sizeToFit];
    self.timeLabel.height = 17;
    self.timeLabel.y = self.nicknameLabel.bottom;
    self.timeLabel.x = self.locationLabel.right + 10;
    
    self.focusButton.width = 46;
    self.focusButton.height = 22;
    self.focusButton.x = self.width - self.focusButton.width - padding;
    self.focusButton.centerY = self.headImageView.centerY;
    self.focusButton.layer.cornerRadius = self.focusButton.height * 0.5;
    
//    self.reportButton.width = 20;
//    self.reportButton.height = 6;
//    self.reportButton.centerY = self.headImageView.centerY;
//    self.reportButton.x = self.width - 15 - 20;
    
    self.playButton.width = 48;
    self.playButton.height = self.playButton.width;
    self.playButton.centerX = self.width * 0.5;
    self.playButton.y = self.timeLabel.bottom + 11;
    
    self.playWaveView1.centerX = self.playButton.centerX;
    self.playWaveView1.centerY = self.playButton.centerY;
    
    self.durationLabel.width = 50;
    self.durationLabel.height = 11;
    self.durationLabel.centerX = JA_SCREEN_WIDTH * 0.5;
    self.durationLabel.y = self.playButton.bottom + 5;
    
    self.agreeButton.width = (self.width - 60) * 0.5;
    self.agreeButton.height = 50;
    self.agreeButton.y = self.timeLabel.bottom + 18;
    [self.agreeButton setButtonImageTitleStyle:ButtonImageTitleStyleTop padding:-2];
    
    self.commentButton.width = self.agreeButton.width;
    self.commentButton.height = self.agreeButton.height;
    self.commentButton.y = self.agreeButton.y;
    self.commentButton.x = self.playButton.right;
    [self.commentButton setButtonImageTitleStyle:ButtonImageTitleStyleTop padding:-2];
   
    // v2.5.4
    self.labelBGView.x = 12;
    self.labelBGView.y = self.playButton.bottom + 28;
    self.labelBGView.width = JA_SCREEN_WIDTH-12*2;
    
    [self.contentLabel sizeToFit];
    self.contentLabel.x = 15;
    self.contentLabel.y = 15;
    self.contentLabel.width = self.labelBGView.width-30;
    
    self.labelBGView.height = self.contentLabel.height + 30;
    
    CGFloat imageW = (JA_SCREEN_WIDTH-12*2-6*2)/3.0;
    CGFloat imageH = imageW*85/113.0;
    
    self.picView.width = JA_SCREEN_WIDTH - 2 * 12;
    self.picView.height = imageH;
    self.picView.x = 12;
    self.picView.y = self.labelBGView.bottom + 15;

    self.picView_ImageView1.width = imageW;
    self.picView_ImageView1.height = imageH;
    
    self.picView_ImageView2.width = self.picView_ImageView1.width;
    self.picView_ImageView2.height = self.picView.height;
    self.picView_ImageView2.x = self.picView_ImageView1.right + 6;
    
    self.picView_ImageView3.width = self.picView_ImageView1.width;
    self.picView_ImageView3.height = self.picView.height;
    self.picView_ImageView3.x = self.picView_ImageView2.right + 6;
    
    //v2.5.5 加一像素
    [self addShapeLayer:self.picView_ImageView1];
    [self addShapeLayer:self.picView_ImageView2];
    [self addShapeLayer:self.picView_ImageView3];
    
    self.voiceWaveViewBG.x = 12;
    self.voiceWaveViewBG.width = self.width-self.voiceWaveViewBG.x*2;
    self.voiceWaveViewBG.height = 50;
    self.voiceWaveViewBG.y = self.labelBGView.bottom + 15;
    
    self.voiceWaveView.width = self.voiceWaveViewBG.width;
    self.voiceWaveView.height = self.voiceWaveViewBG.height;
    
    self.lineView.width = self.width;
    self.lineView.height = 10;
    
    NSMutableArray *images = [[self.data.image componentsSeparatedByString:@","] mutableCopy];
    [images removeObject:@""];
    if (images.count > 0) {
        self.lineView.y = self.picView.bottom + 15;
    }else{
        self.lineView.y = self.voiceWaveViewBG.bottom + 15;
    }
}

- (void)addShapeLayer:(JAShapeLayerImageView *)view {
    CAShapeLayer *border = (CAShapeLayer *)view.layer;
    border.fillColor = [UIColor clearColor].CGColor;
    border.lineWidth = 2.f;
    border.strokeColor = HEX_COLOR(0xF9F9F9).CGColor;
    border.lineCap = kCALineCapRound;
    border.path = [UIBezierPath bezierPathWithRoundedRect:view.bounds cornerRadius:view.layer.cornerRadius].CGPath;
}

- (void)setData:(JAVoiceModel *)data {
    _data = data;
    if (data) {
        
        if (data.sort.integerValue == 1) {   // 11.17周五 之前是判断的是>0,因为精华帖可能要排序，服务端改推荐 sort另有用途，要改为判断 == 1
            self.leftImageView.hidden = NO;
        }else{
            self.leftImageView.hidden = YES;
        }
        
        int h = 35;
        int w = h;
        NSString *url = [data.userImage ja_getFitImageStringWidth:w height:h];

        if (data.isAnonymous) {

            self.nicknameLabel.text = data.anonymousName.length ? data.anonymousName : @"匿名用户";
            self.headImageView.image = [UIImage imageNamed:@"anonymous_head"];
        } else {
            self.nicknameLabel.text = data.userName;
            [self.headImageView ja_setImageWithURLStr:url];
        }
        [self.nicknameLabel sizeToFit];
        
        if ([data.userId isEqualToString:@"7071"] && !data.isAnonymous) {
            self.xiaomoliImageView.hidden = NO;
        }else{
            self.xiaomoliImageView.hidden = YES;
        }
        
        self.timeLabel.text = [NSString distanceTimeWithBeforeTime:[data.createTime doubleValue]];
        [self.timeLabel sizeToFit];
        
        NSString *agreeStr = [NSString stringWithFormat:@"%@",data.agreeCount];
        if ([data.agreeCount integerValue] > 0) {
            NSString *str = [NSString stringWithFormat:@"%@",agreeStr];
            if (data.agreeCount.integerValue > 10000) {
                str = [NSString stringWithFormat:@"%.1fw",data.agreeCount.integerValue / 10000.0];
            }
            [self.agreeButton setTitle:str forState:UIControlStateNormal];
        } else {
            [self.agreeButton setTitle:@"喜欢" forState:UIControlStateNormal];
        }
   
        NSString *totalcount = [NSString stringWithFormat:@"%d",data.commentCount.intValue + data.replyCount.intValue];
        if ([totalcount integerValue] > 0) {
            if (totalcount.integerValue > 10000) {
                totalcount = [NSString stringWithFormat:@"%.1fw",totalcount.integerValue / 10000.0];
            }
        } else {
            totalcount = @"回复";
        }
        [self.commentButton setTitle:totalcount forState:UIControlStateNormal];
        
        self.contentLabel.text = data.content;
        
        self.locationLabel.text = data.city.length?data.city:@"火星";
        
        CGFloat imageW = (JA_SCREEN_WIDTH-12*2-6*2)/3.0;
        CGFloat imageH = imageW*85/113.0;
        NSMutableArray *images = [[self.data.image componentsSeparatedByString:@","] mutableCopy];
        [images removeObject:@""];
        if (images.count > 0){

            self.picView.hidden = NO;
            self.voiceWaveViewBG.hidden = YES;
            self.playWaveView1.hidden = NO;

            if (images.count > 2) {
                self.picView_ImageView1.hidden = NO;
                self.picView_ImageView2.hidden = NO;
                self.picView_ImageView3.hidden = NO;
                NSString *url = [images.firstObject ja_getFillImageStringWidth:imageW height:imageH];
                NSString *url1 = [images[1] ja_getFillImageStringWidth:imageW height:imageH];
                NSString *url2 = [images.lastObject ja_getFillImageStringWidth:imageW height:imageH];
                [self.picView_ImageView1 ja_setImageWithURLStr:url];
                [self.picView_ImageView2 ja_setImageWithURLStr:url1];
                [self.picView_ImageView3 ja_setImageWithURLStr:url2];
            }else if (images.count > 1){
                self.picView_ImageView1.hidden = NO;
                self.picView_ImageView2.hidden = NO;
                self.picView_ImageView3.hidden = YES;
                NSString *url = [images.firstObject ja_getFillImageStringWidth:imageW height:imageH];
                NSString *url1 = [images.lastObject ja_getFillImageStringWidth:imageW height:imageH];
                [self.picView_ImageView1 ja_setImageWithURLStr:url];
                [self.picView_ImageView2 ja_setImageWithURLStr:url1];
            }else{
                self.picView_ImageView1.hidden = NO;
                self.picView_ImageView2.hidden = YES;
                self.picView_ImageView3.hidden = YES;
                NSString *url = [images.firstObject ja_getFillImageStringWidth:imageW height:imageH];
                [self.picView_ImageView1 ja_setImageWithURLStr:url];
            }
        }else{
            self.picView.hidden = YES;
            self.voiceWaveViewBG.hidden = NO;
            self.playWaveView1.hidden = YES;
        }
        
        self.agreeButton.selected = data.isAgree?YES:NO;
        self.lastAgreeState = self.agreeButton.selected;

        // 设置波形图颜色
        int type = data.displayPeakLevelQueue.count%8;
        NSDictionary *colorDic = [JAAPPManager app_waveViewColorWithType:type];
        if (colorDic) {
            unsigned long wave_color = strtoul([colorDic[@"wave_color"] UTF8String],0,0);
            self.voiceWaveView.maskColor = HEX_COLOR(wave_color);
            self.voiceWaveView.darkGrayColor = HEX_COLOR_ALPHA(wave_color, 0.5);
        }
        
        JAVoiceModel *voiceModel = [JAVoicePlayerManager shareInstance].voiceModel;
        if ([voiceModel.voiceId isEqualToString:self.data.voiceId]) {
            self.data.playState = voiceModel.playState;
        } else {
            self.data.playState = 0;
        }
        [self updateUIWithData:data];
        
        if ([data.concernType integerValue] == 1) {
            self.focusButton.backgroundColor = HEX_COLOR(JA_BoardLineColor);
            [self.focusButton setTitleColor:HEX_COLOR(JA_BlackSubTitle) forState:UIControlStateNormal];
            [self.focusButton setTitle:@"已关注" forState:UIControlStateNormal];
            self.focusButton.layer.borderWidth = 0;
            self.focusButton.selected = YES;
        } else {
            self.focusButton.backgroundColor = [UIColor clearColor];
            [self.focusButton setTitleColor:HEX_COLOR(JA_Green) forState:UIControlStateNormal];
            [self.focusButton setTitle:@"+关注" forState:UIControlStateNormal];
            self.focusButton.layer.borderWidth = 1;
            self.focusButton.selected = NO;
        }
        
        if ([data.userId isEqualToString:[JAUserInfo userInfo_getUserImfoWithKey:User_id]] || data.isAnonymous) {
            
            self.focusButton.hidden = YES;
        }else{
            self.focusButton.hidden = NO;
        }
    }
}

#pragma mark - 按钮的点击
- (void)showBigPicture:(UIGestureRecognizer *)tap
{
    if (self.showPicture_registInut) {
        self.showPicture_registInut(self);
    }
    
    UIImageView *imageV = (UIImageView *)tap.view;
    NSMutableArray *arrM = [NSMutableArray array];
    // 查看大图
    NSMutableArray *images = [[self.data.image componentsSeparatedByString:@","] mutableCopy];
    [images removeObject:@""];
    for (NSInteger i = 0; i < images.count; i++) {
        KNPhotoItems *items = [[KNPhotoItems alloc] init];
        items.url = images[i];
        [arrM addObject:items];
    }
    
    KNPhotoBrower *photoBrower = [[KNPhotoBrower alloc] init];
    if ([JAUserInfo userInfo_getUserImfoWithKey:User_Admin].integerValue == JAPOWER) {
        photoBrower.actionSheetArr =  [@[@"删除",@"保存"] copy];
    }else{
        photoBrower.actionSheetArr =  [@[@"保存"] copy];
    }
    [photoBrower setIsNeedRightTopBtn:YES];
    [photoBrower setIsNeedPictureLongPress:YES];
    photoBrower.itemsArr = [arrM copy];
    photoBrower.currentIndex = imageV.tag;
    [photoBrower present];
    [photoBrower setDelegate:self];
}

#pragma mark - KNPhotoBrowerDelegate
#pragma mark - 删除帖子图片
- (void)photoBrowerRightOperationDeleteImageSuccessWithAbsoluteIndex:(NSInteger)index
{
    // 获取图片
    NSMutableArray *images = [[self.data.image componentsSeparatedByString:@","] mutableCopy];
    [images removeObject:@""];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    dic[@"id"] = self.data.voiceId;
    if (index >= 0 && index < images.count) {
    
        [images removeObject:images[index]];
        
    }
    
    if (images.count) {
        dic[@"image"] = [images componentsJoinedByString:@","];
    }else{
        dic[@"image"] = @"";
    }
    
    [[JAVoicePersonApi shareInstance] voice_adminUpdateVoicePicWithParas:dic success:^(NSDictionary *result) {
        [[UIApplication sharedApplication].delegate.window ja_makeToast:@"删除成功"];
        
        
        self.data.image = [images componentsJoinedByString:@","];
        self.data = self.data;
        
        if (self.adminActionVoicePicture) {
            self.adminActionVoicePicture(self);
        }
    } failure:^(NSError *error) {
        [[UIApplication sharedApplication].delegate.window ja_makeToast:error.localizedDescription];
    }];
    
}

- (void)userInfoAction {
    if (self.headActionBlock) {
        self.headActionBlock(self);
    }
}

- (void)playVoice {          // 播放
    if (self.playBlock) { 
        self.playBlock(self);
    }
}

//- (void)reportAction
//{
//    if (!IS_LOGIN) {
//        [JAAPPManager app_modalLogin];
//        return;
//    }
//
//    [JAActionPostsManager app_actionPopWindowsWithType:JA_STORY_TYPE typeModel:self.data action:^{
//        if (self.deleteVoiceBlock) {
//            self.deleteVoiceBlock(self);
//        }
//    } storyUserId:self.data.userId];
//}

- (void)commentAction {   // 回复
    if (self.commentBlock) {
        self.commentBlock(self);
    }
}

// 单击点赞
- (void)agreeAction:(JAEmitterView *)sender {
    
    if (!IS_LOGIN) {
        [JAAPPManager app_modalLogin];
        return;
    }
    
    sender.selected = !sender.selected;
    
    if (self.refreshAgreeStatus) {
        self.refreshAgreeStatus(sender.selected);
    }
    
    // 原来的点赞动画
//    if (sender.selected) {
//        [sender.imageView startAnimating];
//    }else{
//        [sender.imageView stopAnimating];
//    }
    
    NSInteger agreeCount = [self.data.agreeCount integerValue];
    if (sender.selected) {
        self.data.agreeCount = [NSString stringWithFormat:@"%zd",++agreeCount];
        self.agreeMethod = @"点击按钮喜欢";
    } else {
        self.data.agreeCount = [NSString stringWithFormat:@"%zd",--agreeCount];
    }
    
    NSString *agreeStr = [NSString stringWithFormat:@"%@",self.data.agreeCount];
    if ([self.data.agreeCount integerValue] > 0) {
        NSString *str = [NSString stringWithFormat:@"%@",agreeStr];
        if (self.data.agreeCount.integerValue > 10000) {
            str = [NSString stringWithFormat:@"%.1fw",self.data.agreeCount.integerValue / 10000.0];
        }
        [self.agreeButton setTitle:str forState:UIControlStateNormal];
    } else {
        [self.agreeButton setTitle:@"喜欢" forState:UIControlStateNormal];
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(myDelayedMethod) object:self];
    [self performSelector:@selector(myDelayedMethod) withObject:self afterDelay:0.3];
}

// 双击点赞
//- (void)doubleClickAgreeAction:(JAVoiceAgreeButton *)sender {
//    
//    if (!IS_LOGIN) {
//        [JAAPPManager app_modalLogin];
//        return;
//    }
//    
//    sender.selected = !sender.selected;
//    if (sender.selected) {
//        [sender.imageView startAnimating];
//    }else{
//        [sender.imageView stopAnimating];
//    }
//    
//    NSInteger agreeCount = [self.data.agreeCount integerValue];
//    if (sender.selected) {
//        self.data.agreeCount = [NSString stringWithFormat:@"%zd",++agreeCount];
//        self.agreeMethod = @"双击喜欢";
//    } else {
//        self.data.agreeCount = [NSString stringWithFormat:@"%zd",--agreeCount];
//    }
//    
//    NSString *agreeStr = [NSString stringWithFormat:@"%@点赞",self.data.agreeCount];
//    [self.agreeButton setTitle:agreeStr forState:UIControlStateNormal];
//    
//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(myDelayedMethod) object:self];
//    [self performSelector:@selector(myDelayedMethod) withObject:self afterDelay:0.3];
//}

- (void)myDelayedMethod {
    if (self.agreeButton.selected != self.lastAgreeState) {
        self.lastAgreeState = self.agreeButton.selected;
        self.data.isAgree = self.agreeButton.selected;
        [self zanAction];
        // 神策数据
        if (self.agreeButton.selected) {
            [self sensorsAnalyticsWithLikeType:JA_STORY_TYPE model:self.data method:self.agreeMethod];
        }
    }
}

- (void)focusButtonClick:(UIButton *)btn
{
    [self focusCustomer:btn];
}

- (void)resetVoiceTime:(NSString *)time {
    self.durationLabel.text = [NSString getShowTime:time];
    [self.playWaveView1 resetAnimation];
}

// 倒计时
- (void)setCurrentVoiceTime {
    JAVoiceModel *voiceModel = [JAVoicePlayerManager shareInstance].voiceModel;
    if ([voiceModel.voiceId isEqualToString:self.data.voiceId]) {
        [self.playWaveView1 startAnimation];

        NSTimeInterval curDuration = [NSString getSeconds:voiceModel.time] - [JAVoicePlayerManager shareInstance].player.progress;
        if (curDuration > 0) {
            NSString *timeS = [NSString stringWithFormat:@"%02d:%02d",(int)curDuration/60,(int)curDuration%60];
            self.durationLabel.text = [NSString getShowTime:timeS];
        }
    }
}

// 根据数据源更新UI
- (void)updateUIWithData:(JAVoiceModel *)data {
    // 语音
    [self.playLoadingView setPlayLoadingViewHidden:YES];
    if (data.playState == 1) {
        self.playButton.selected = YES;
        
    } else {
        self.playButton.selected = NO;
        if (data.playState == 0) {
            // 显示半个游标
            self.voiceWaveView.sliderIV.x = -3;
            [self.data.currentPeakLevelQueue removeAllObjects];
            if (!self.data.displayPeakLevelQueue.count) {
                return;
            }
            for (int i=0; i<_allCount; i++) {
                [self.data.currentPeakLevelQueue addObject:self.data.displayPeakLevelQueue[i]];
            }
            
            [self.voiceWaveView setPeakLevelQueue:data.currentPeakLevelQueue];
            
            [self resetVoiceTime:data.time];
        } else if (data.playState == 2) {
            JAVoiceModel *voiceModel = [JAVoicePlayerManager shareInstance].voiceModel;
            if ([voiceModel.voiceId isEqualToString:self.data.voiceId]) {
                CGFloat time = [JAVoicePlayerManager shareInstance].player.progress;
                NSInteger index = (NSInteger)(time * 10 + 1);
                CGFloat percent = (index * 4) / (_waveViewWidth);
                if (percent>=0.5) {
                    percent = 0.5;
                }
                // 移动滑动杆
                [self.voiceWaveView setSliderOffsetX:percent];
                
                int cutIndex = percent * self.data.currentPeakLevelQueue.count;
                [self.voiceWaveView setPeakLevelQueue:self.data.currentPeakLevelQueue cutIndex:cutIndex];
                
                [self setCurrentVoiceTime];
            }
        } else if (data.playState == 3) {
            [self.playLoadingView setPlayLoadingViewHidden:NO];
        }
    }
}

#pragma mark - 网络请求
// 点赞
- (void)zanAction
{
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    dic[@"type"] = @"story";
    dic[@"actionType"] = @"agree";
    dic[@"typeId"] = self.data.voiceId;
   
    [[JAVoiceCommonApi shareInstance] voice_agreeWithParas:dic success:^(NSDictionary *result) {
        
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)playNotification:(NSNotification *)noti {
    //    NSDictionary *dic = [noti object];
    JAVoiceModel *voiceModel = [JAVoicePlayerManager shareInstance].voiceModel;
    if ([voiceModel.voiceId isEqualToString:self.data.voiceId]) {
        //        [JAVoicePlayerManager shareInstance].delegate = self;
        self.data.playState = voiceModel.playState;
    
    } else {
        self.data.playState = 0;
    }
    
    [self updateUIWithData:self.data];
}

- (void)focusCustomer:(UIButton *)btn
{
    if (!IS_LOGIN) {
        [JAAPPManager app_modalLogin];
        return;
    }
    
    btn.userInteractionEnabled = NO;
    if (btn.selected) {
        
        // 取消关注
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
        dic[@"concernId"] = self.data.userId;
        
        // 神策数据
        NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
        senDic[JA_Property_BindingType] = @"取消关注";
        senDic[JA_Property_PostId] = self.data.userId;
        senDic[JA_Property_PostName] = self.data.userName;
        senDic[JA_Property_FollowMethod] = @"帖子详情页";
        [JASensorsAnalyticsManager sensorsAnalytics_followPerson:senDic];
        
        [[JAVoicePersonApi shareInstance] voice_personalCancleFocusUseroWithParas:dic success:^(NSDictionary *result) {
            
            NSString *type = [NSString stringWithFormat:@"%@",result[@"friend"][@"friendType"]];
            self.data.concernType = type;
            btn.userInteractionEnabled = YES;
            btn.selected = NO;
            self.focusButton.backgroundColor = [UIColor clearColor];
            [self.focusButton setTitleColor:HEX_COLOR(JA_Green) forState:UIControlStateNormal];
            [self.focusButton setTitle:@"+关注" forState:UIControlStateNormal];
            self.focusButton.layer.borderWidth = 1;
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"id"] = self.data.userId;
            dic[@"status"] = type;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"searchRefreshFocusStatusFalse" object:dic];
            
        } failure:^(NSError *error) {
            btn.userInteractionEnabled = YES;
            [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:error.localizedDescription];
        }];
        
        return;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"concernId"] = self.data.userId;
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    
    // 神策数据
    NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
    senDic[JA_Property_BindingType] = @"关注";
    senDic[JA_Property_PostId] = self.data.userId;
    senDic[JA_Property_PostName] = self.data.userName;
    senDic[JA_Property_FollowMethod] = @"帖子详情页";
    [JASensorsAnalyticsManager sensorsAnalytics_followPerson:senDic];
    
    [[JAVoicePersonApi shareInstance] voice_personalFocusUserWithParas:dic success:^(NSDictionary *result) {
        
        NSString *type = [NSString stringWithFormat:@"%@",result[@"friend"][@"friendType"]];
        self.data.concernType = type;
        btn.userInteractionEnabled = YES;
        self.focusButton.backgroundColor = HEX_COLOR(JA_BoardLineColor);
        [self.focusButton setTitleColor:HEX_COLOR(JA_BlackSubTitle) forState:UIControlStateNormal];
        [self.focusButton setTitle:@"已关注" forState:UIControlStateNormal];
        self.focusButton.layer.borderWidth = 0;
        btn.selected = YES;
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"id"] = self.data.userId;
        dic[@"status"] = type;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"searchRefreshFocusStatusTrue" object:dic];
        
    } failure:^(NSError *error) {
        btn.userInteractionEnabled = YES;
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:error.localizedDescription];
    }];
    
    
}

#pragma mark - JAPlayerDelegate
- (void)audioPlayerDidCurrentTime:(NSTimeInterval)time duration:(NSTimeInterval)duration {
    JAVoiceModel *voiceModel = [JAVoicePlayerManager shareInstance].voiceModel;
    if ([voiceModel.voiceId isEqualToString:self.data.voiceId] && voiceModel.playState == 1) {
        [self setCurrentVoiceTime];
      
        NSInteger index = (NSInteger)(time * 10 + 1);
        CGFloat percent = (index * 4) / (_waveViewWidth);
        if (percent>=0.5) {
            percent = 0.5;
            index = index+_allCount/2; // 跳过半个波形的宽度
            if (index < self.data.displayPeakLevelQueue.count) {
                [self.data.currentPeakLevelQueue enqueue:self.data.displayPeakLevelQueue[index] maxCount:_allCount];
            }
        }
        // 移动滑动杆
        [self.voiceWaveView setSliderOffsetX:percent];
        
        int cutIndex = percent * self.data.currentPeakLevelQueue.count;
        [self.voiceWaveView setPeakLevelQueue:self.data.currentPeakLevelQueue cutIndex:cutIndex];
    }
}

// 神策数据
- (void)sensorsAnalyticsWithLikeType:(NSString *)type model:(id)model method:(NSString *)method
{
    NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
    
    if ([type isEqualToString:JA_STORY_TYPE]) {
        
        JAVoiceModel *voiceM = (JAVoiceModel *)model;
        // 计算时间
        NSArray *timeArr = [voiceM.time componentsSeparatedByString:@":"];
        NSString *min = timeArr.firstObject;
        NSString *sec = timeArr.lastObject;
        NSInteger sen_time = min.integerValue * 60 + sec.integerValue;
        
        senDic[JA_Property_ContentId] = voiceM.voiceId;
        senDic[JA_Property_ContentTitle] = voiceM.content;
        senDic[JA_Property_ContentType] = @"主帖";
        senDic[JA_Property_Category] = [JAConfigManager shareInstance].channelDic[voiceM.categoryId];
        senDic[JA_Property_Anonymous] = @(voiceM.isAnonymous);
        senDic[JA_Property_RecordDuration] = @(sen_time);
        senDic[JA_Property_PostId] = voiceM.userId;
        senDic[JA_Property_PostName] = voiceM.userName;
        senDic[JA_Property_LikeMethod] = method;
        senDic[JA_Property_SourcePage] = voiceM.sourceName;
        senDic[JA_Property_RecommendType] = voiceM.recommendType;
        
    }else if([type isEqualToString:JA_COMMENT_TYPE]){
        
        JAVoiceCommentModel *commentM = (JAVoiceCommentModel *)model;
        // 计算时间
        NSArray *timeArr = [commentM.time componentsSeparatedByString:@":"];
        NSString *min = timeArr.firstObject;
        NSString *sec = timeArr.lastObject;
        NSInteger sen_time = min.integerValue * 60 + sec.integerValue;
        
        senDic[JA_Property_ContentId] = commentM.voiceCommendId;
        senDic[JA_Property_ContentTitle] = commentM.content;
        senDic[JA_Property_ContentType] = @"一级回复";
        senDic[JA_Property_Category] = [JAConfigManager shareInstance].channelDic[commentM.categoryId];
        senDic[JA_Property_Anonymous] = @(commentM.isAnonymous);
        senDic[JA_Property_RecordDuration] = @(sen_time);
        senDic[JA_Property_PostId] = commentM.userId;
        senDic[JA_Property_PostName] = commentM.userName;
        senDic[JA_Property_LikeMethod] = method;
        senDic[JA_Property_SourcePage] = commentM.sourceName;
        senDic[JA_Property_RecommendType] = commentM.recommendType;
        
    }else if ([type isEqualToString:JA_REPLY_TYPE]){
        
        JAVoiceReplyModel *replyM = (JAVoiceReplyModel *)model;
        // 计算时间
        NSArray *timeArr = [replyM.time componentsSeparatedByString:@":"];
        NSString *min = timeArr.firstObject;
        NSString *sec = timeArr.lastObject;
        NSInteger sen_time = min.integerValue * 60 + sec.integerValue;
        
        senDic[JA_Property_ContentId] = replyM.voiceReplyId;
        senDic[JA_Property_ContentTitle] = replyM.content;
        senDic[JA_Property_ContentType] = @"二级回复";
        senDic[JA_Property_Category] = [JAConfigManager shareInstance].channelDic[replyM.categoryId];
        senDic[JA_Property_Anonymous] = @(replyM.isAnonymous);
        senDic[JA_Property_RecordDuration] = @(sen_time);
        senDic[JA_Property_PostId] = replyM.userId;
        senDic[JA_Property_PostName] = replyM.userName;
        senDic[JA_Property_LikeMethod] = method;
        senDic[JA_Property_SourcePage] = replyM.sourceName;
        senDic[JA_Property_RecommendType] = replyM.recommendType;
    }
    [JASensorsAnalyticsManager sensorsAnalytics_clickAgree:senDic];
}
@end
