//
//  JACommonCommentCell.m
//  Jasmine
//
//  Created by moli-2017 on 2017/8/29.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JACommonCommentCell.h"
#import "JAVoiceCommonApi.h"
#import "DMHeartFlyView.h"
#import "JASampleHelper.h"
#import "JAPlayAnimateView.h"
#import "JAVoicePlayerManager.h"
#import "JAPersonTagView.h"

#import "JANewPlaySingleTool.h"

@interface JACommonCommentCell ()<JAPlayerDelegate,JAEmitterViewDelegate>

@property (nonatomic, weak) UIImageView *leftImageView;   // 神回复

@property (nonatomic, weak) UIImageView *iconImageView;   // 头像
@property (nonatomic, weak) UILabel *floorLabel;  // 楼层label
@property (nonatomic, weak) UILabel *timeLabel;      // 时间

@property (nonatomic, weak) UIButton *pointButton;   // 三个点  (按钮不展示)

@property (nonatomic, weak) UILabel *nameLabel;          // 名字1
@property (nonatomic, weak) UILabel *arrowLabel;           // 回复箭头
@property (nonatomic, weak) UILabel *beReplyNameLabel; // 名字2

@property (nonatomic, weak) JAPersonTagView *tagView;

@property (nonatomic, weak) JAPlayAnimateView *animateView;   // 新的波形图

@property (nonatomic, weak) UIView *bottomView;         // 底部  -- 评论底部
@property (nonatomic, weak) UIButton *replyPlayButton;   // 回复的播放按钮  -- 评论底部
@property (nonatomic, weak) UILabel *replyNameLabel;    // 回复者的名字  -- 评论底部
@property (nonatomic, weak) JAPersonTagView *replyNameTagView;
@property (nonatomic, weak) UILabel *replyTitleLabel;    // 回复的标题  -- 评论底部
@property (nonatomic, weak) UIButton *allReplyButton;    // 查看全部回复  -- 评论底部

@property (nonatomic, weak) UIView *lineView;        // 线

@property (nonatomic, assign) int allCount;

@property (nonatomic, strong) NSString *agreeMethod;   // 神策数据（点赞方式）

@property (nonatomic, assign) NSTimeInterval frontTime;

@property (nonatomic, assign) CGFloat waveViewWidth;

@property (nonatomic, weak) UIButton *goBackButton;
@end

@implementation JACommonCommentCell

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[JAVoicePlayerManager shareInstance] removeDelegate:self];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupCommonCommentCell];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILongPressGestureRecognizer *longG = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longG_commentCell:)];
        [self.contentView addGestureRecognizer:longG];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playSingleStatusChange_refreshUI) name:@"STKAudioPlayerSingle_statusChange" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playSingleProcess_refreshUI) name:@"STKAudioPlayerSingle_process" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playSingleFinish_refreshUI) name:@"STKAudioPlayerSingle_finish" object:nil];
    }
    return self;
}

- (void)longG_commentCell:(UIGestureRecognizer *)longG
{
    if (longG.state == UIGestureRecognizerStateBegan) {
        if (self.pointClickBlock) {
            self.pointClickBlock(self);
        }
    }
}

- (void)setupCommonCommentCell
{
    UIImageView *leftImageView = [[UIImageView alloc] init];
    _leftImageView = leftImageView;
    leftImageView.image = [UIImage imageNamed:@"shenhuifu"];
    [self.contentView addSubview:leftImageView];
    
    UIImageView *iconImageView = [[UIImageView alloc] init];
    _iconImageView = iconImageView;
    iconImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpPersonalVc)];
    [iconImageView addGestureRecognizer:tap1];
    [self.contentView addSubview:iconImageView];
    
    // 回复者
    UILabel *nameLabel = [[UILabel alloc] init];
    _nameLabel = nameLabel;
    nameLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpPersonalVc)];
    [nameLabel addGestureRecognizer:tap2];
    nameLabel.text = @" ";
    nameLabel.textColor = HEX_COLOR(0x576B95);
    nameLabel.font = JA_REGULAR_FONT(JA_PersonalDetail_commentPersonalFont);
    [self.contentView addSubview:nameLabel];
    
    UILabel *arrowLabel = [[UILabel alloc] init];
    _arrowLabel = arrowLabel;
    arrowLabel.hidden = YES;
    arrowLabel.text = @"回复";
    arrowLabel.textColor = HEX_COLOR(0x4A4A4A);
    arrowLabel.font = JA_REGULAR_FONT(JA_PersonalDetail_commentPersonalFont);
    [self.contentView addSubview:arrowLabel];
    
    // 被回复者
    UILabel *beReplyNameLabel = [[UILabel alloc] init];
    _beReplyNameLabel = beReplyNameLabel;
    beReplyNameLabel.hidden = YES;
    beReplyNameLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap22 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpBeReplyPersonalVc)];
    [beReplyNameLabel addGestureRecognizer:tap22];
    beReplyNameLabel.text = @" ";
    beReplyNameLabel.textColor = HEX_COLOR(0x576B95);
    beReplyNameLabel.font = JA_REGULAR_FONT(JA_PersonalDetail_commentPersonalFont);
    [self.contentView addSubview:beReplyNameLabel];
    
    UILabel *floorLabel = [[UILabel alloc] init];
    _floorLabel = floorLabel;
    floorLabel.text = @" ";
    floorLabel.textColor = HEX_COLOR(0xC6C6C6);
    floorLabel.font = JA_REGULAR_FONT(12);
    [self.contentView addSubview:floorLabel];
    
    UILabel *timeLabel = [[UILabel alloc] init];
    _timeLabel = timeLabel;
    timeLabel.text = @" ";
    timeLabel.textColor = HEX_COLOR(JA_BlackSubSubTitle);
    timeLabel.font = JA_REGULAR_FONT(12);
    [self.contentView addSubview:timeLabel];
    
    // 点赞
    JAEmitterView *likeButton = [JAEmitterView buttonWithType:UIButtonTypeCustom];
    _likeButton = likeButton;
    [likeButton setTitle:@"" forState:UIControlStateNormal];
    [likeButton setImage:[UIImage imageNamed:@"branch_smallAgree_no"] forState:UIControlStateNormal];
    [likeButton setImage:[UIImage imageNamed:@"branch_smallAgree_no"] forState:UIControlStateHighlighted];
    [likeButton setImage:[UIImage imageNamed:@"branch_smallAgree_sel"] forState:UIControlStateSelected];
    [likeButton setImage:[UIImage imageNamed:@"branch_smallAgree_sel"] forState:UIControlStateSelected|UIControlStateHighlighted];
    [likeButton setTitleColor:HEX_COLOR(JA_BlackSubTitle) forState:UIControlStateNormal];
    likeButton.titleLabel.font = JA_REGULAR_FONT(11);
    likeButton.imageEdgeInsets = UIEdgeInsetsMake(0, -2, 0, 2);
    likeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 2, 0, -2);
    likeButton.beginAngle = -65;
    likeButton.direction = 0;
    likeButton.delegate = self;
    [self.contentView addSubview:likeButton];
    
    // 波形图
    JAPlayAnimateView *animateView = [[JAPlayAnimateView alloc] initWithColor:HEX_COLOR(0x6BD379) frame:CGRectZero];
    _animateView = animateView;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playComment)];
    [self.animateView addGestureRecognizer:tap];
    self.animateView.backgroundColor = HEX_COLOR(0x6BD379);
    [self.contentView addSubview:animateView];
    
    
    // 内容
    KILabel *title_label = [[KILabel alloc] init];
    _title_label = title_label;
    title_label.text = @" ";
    title_label.textColor = HEX_COLOR(0x363636);
    title_label.font = JA_REGULAR_FONT(JA_CommentDetail_commentFont);
    title_label.numberOfLines = 0;

    title_label.linkDetectionTypes = KILinkTypeOptionUserHandle;
    [title_label setAttributes:@{NSForegroundColorAttributeName : HEX_COLOR(0x54C7FC)} forLinkType:KILinkTypeHashtag];
    [title_label setAttributes:@{NSForegroundColorAttributeName : HEX_COLOR(0x54C7FC)} forLinkType:KILinkTypeUserHandle];
    @WeakObj(self);
    title_label.userHandleLinkTapHandler = ^(KILabel * _Nonnull label, NSString * _Nonnull string, NSRange range) {
        @StrongObj(self);
        if (self.commentAtPersonBlock) {
            self.commentAtPersonBlock(string, self.comment_Model.atList);
        }
        if (self.replyAtPersonBlock) {
            self.replyAtPersonBlock(string, self.reply_Model.atList);
        }
    };
    
    [self.contentView addSubview:title_label];
    
    // 底部回复
    UIView *bottomView = [[UIView alloc] init];
    _bottomView = bottomView;
    UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpCommentDetailVc)];
    [bottomView addGestureRecognizer:tap3];
    bottomView.backgroundColor = HEX_COLOR(0xF6F6F6);
    [self.contentView addSubview:bottomView];
    
    // 播放
    UIButton *replyPlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _replyPlayButton = replyPlayButton;
    [replyPlayButton setImage:[UIImage imageNamed:@"branch_voice_smallPlay"] forState:UIControlStateNormal];
    [replyPlayButton setImage:[UIImage imageNamed:@"branch_voice_smallPlay"] forState:UIControlStateSelected];
    [bottomView addSubview:replyPlayButton];
    
    // 回复者
    UILabel *replyNameLabel = [[UILabel alloc] init];
    _replyNameLabel = replyNameLabel;
    replyNameLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpReplyPersonalVc)];
    [replyNameLabel addGestureRecognizer:tap4];
    replyNameLabel.text = @" ";
    replyNameLabel.textColor = HEX_COLOR(0x576B95);
    replyNameLabel.font = JA_REGULAR_FONT(JA_PersonalDetail_replyPersonalFont);
    [bottomView addSubview:replyNameLabel];
    
    // 回复内容
    UILabel *replyTitleLabel = [[UILabel alloc] init];
    _replyTitleLabel = replyTitleLabel;
    replyTitleLabel.text = @" ";
    replyTitleLabel.textColor = HEX_COLOR(0x363636);
    replyTitleLabel.font = JA_REGULAR_FONT(JA_CommentDetail_replyFont);
    [bottomView addSubview:replyTitleLabel];
    
    // 全部回复按钮
    UIButton *allReplyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _allReplyButton = allReplyButton;
    allReplyButton.userInteractionEnabled = NO;
    allReplyButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [allReplyButton setTitle:@" " forState:UIControlStateNormal];
    [allReplyButton setTitleColor:HEX_COLOR(0x576B95) forState:UIControlStateNormal];
    allReplyButton.titleLabel.font = JA_REGULAR_FONT(14);
    [bottomView addSubview:allReplyButton];
    
    // 线
    UIView *lineView = [[UIView alloc] init];
    _lineView = lineView;
    lineView.backgroundColor = HEX_COLOR(JA_Line);
    [self.contentView addSubview:lineView];
    
    JAPersonTagView *tagView = [[JAPersonTagView alloc] init];
    _tagView = tagView;
    [self.contentView addSubview:tagView];
    [tagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.nameLabel.mas_centerY).offset(0);
        make.left.equalTo(self.nameLabel.mas_right).offset(5);
    }];
    
    JAPersonTagView *replyNameTagView = [[JAPersonTagView alloc] init];
    _replyNameTagView = replyNameTagView;
    [self.contentView addSubview:replyNameTagView];
    [replyNameTagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.replyNameLabel.mas_centerY).offset(0);
        make.left.equalTo(self.replyNameLabel.mas_right).offset(5);
    }];
    
    UIButton *goBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _goBackButton = goBackButton;
    goBackButton.backgroundColor = HEX_COLOR(0xDFFFBF);
    [goBackButton setTitle:@"返回浏览位置" forState:UIControlStateNormal];
    [goBackButton setTitleColor:HEX_COLOR(0x9b9b9b) forState:UIControlStateNormal];
    goBackButton.titleLabel.font = JA_REGULAR_FONT(13);
    [goBackButton addTarget:self action:@selector(clickGoBack:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:goBackButton];
}

- (void)clickGoBack:(UIButton *)btn
{
    if ([btn.currentTitle isEqualToString:@"返回浏览位置"]) {
        
        if (self.goBackBrowseLocation) {
            self.goBackBrowseLocation();
        }
    }else{
        if (self.goBackBeginLocation) {
            self.goBackBeginLocation();
        }
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
            [self clickAgree:button];
        }
    }else{
        [self clickAgree:button];
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
        [self clickAgree:button];
    }
}

#pragma mark - 波形图的监听
- (void)playSingleStatusChange_refreshUI
{
    NSInteger musicType = [JANewPlaySingleTool shareNewPlaySingleTool].musicType;
    
    if (self.reply_Model) {
        if (musicType == JANewPlaySingleToolType_reply && [[JANewPlaySingleTool shareNewPlaySingleTool].currentMusic_reply.replyId isEqualToString:self.reply_Model.replyId]) {
            NSInteger status = [JANewPlaySingleTool shareNewPlaySingleTool].playType;
            if (status == 0) {
                self.animateView.playButton.selected = NO;
                [self.animateView setPlayLoadingViewHidden:YES];
            }else if (status == 1){
                self.animateView.playButton.selected = YES;
                [self.animateView setPlayLoadingViewHidden:YES];
            }else if (status == 2){
                self.animateView.playButton.selected = NO;
                [self.animateView setPlayLoadingViewHidden:YES];
            }else if (status == 3){
                [self.animateView setPlayLoadingViewHidden:NO];
            }
        }else{
            self.animateView.playButton.selected = NO;
            [self.animateView setPlayLoadingViewHidden:YES];
        }
    }
    
    if (self.comment_Model) {
        if (musicType == JANewPlaySingleToolType_comment && [[JANewPlaySingleTool shareNewPlaySingleTool].currentMusic_comment.commentId isEqualToString:self.comment_Model.commentId]) {
            NSInteger status = [JANewPlaySingleTool shareNewPlaySingleTool].playType;
            if (status == 0) {
                self.animateView.playButton.selected = NO;
                [self.animateView setPlayLoadingViewHidden:YES];
            }else if (status == 1){
                self.animateView.playButton.selected = YES;
                [self.animateView setPlayLoadingViewHidden:YES];
            }else if (status == 2){
                self.animateView.playButton.selected = NO;
                [self.animateView setPlayLoadingViewHidden:YES];
            }else if (status == 3){
                [self.animateView setPlayLoadingViewHidden:NO];
            }
        }else{
            self.animateView.playButton.selected = NO;
            [self.animateView setPlayLoadingViewHidden:YES];
        }
    }
}

- (void)playSingleProcess_refreshUI
{
    if ([JANewPlaySingleTool shareNewPlaySingleTool].totalDuration <= 0) {
        return;
    }
    NSInteger musicType = [JANewPlaySingleTool shareNewPlaySingleTool].musicType;
    if (self.comment_Model) {
        if (musicType == JANewPlaySingleToolType_comment && [[JANewPlaySingleTool shareNewPlaySingleTool].currentMusic_comment.commentId isEqualToString:self.comment_Model.commentId]) {
            // 计算进度
            CGFloat p = [JANewPlaySingleTool shareNewPlaySingleTool].currentDuration / [JANewPlaySingleTool shareNewPlaySingleTool].totalDuration;
            [self.animateView beginVolumeAnimate:p];
            NSTimeInterval curDuration = [NSString getSeconds:self.comment_Model.time] - [JANewPlaySingleTool shareNewPlaySingleTool].currentDuration;
            if (curDuration > 0) {
                self.animateView.time = [NSString getShowTime:[NSString stringWithFormat:@"%02d:%02d",(int)curDuration/60,(int)curDuration%60]];
            }
        }else{
            [self.animateView resetVolumeAnimate];
            self.animateView.time = [NSString getShowTime:self.comment_Model.time];
        }
    }
    
    if (self.reply_Model) {
        if (musicType == JANewPlaySingleToolType_reply && [[JANewPlaySingleTool shareNewPlaySingleTool].currentMusic_reply.replyId isEqualToString:self.reply_Model.replyId]) {
            // 计算进度
            CGFloat p = [JANewPlaySingleTool shareNewPlaySingleTool].currentDuration / [JANewPlaySingleTool shareNewPlaySingleTool].totalDuration;
            [self.animateView beginVolumeAnimate:p];
            NSTimeInterval curDuration = [NSString getSeconds:self.reply_Model.time] - [JANewPlaySingleTool shareNewPlaySingleTool].currentDuration;
            if (curDuration > 0) {
                self.animateView.time = [NSString getShowTime:[NSString stringWithFormat:@"%02d:%02d",(int)curDuration/60,(int)curDuration%60]];
            }
        }else{
            [self.animateView resetVolumeAnimate];
            self.animateView.time = [NSString getShowTime:self.reply_Model.time];
        }
    }
    
}

- (void)playSingleFinish_refreshUI
{
    [self.animateView resetVolumeAnimate];
    self.animateView.playButton.selected = NO;
    [self.animateView setPlayLoadingViewHidden:YES];
    if (self.reply_Model) {
        
        self.animateView.time = [NSString getShowTime:self.reply_Model.time];
    }
    if (self.comment_Model) {
        
        self.animateView.time = [NSString getShowTime:self.comment_Model.time];
    }
}

#pragma mark - 设置评论的model
- (void)setComment_Model:(JANewCommentModel *)comment_Model
{
    _comment_Model = comment_Model;
    
    self.leftImageView.frame = comment_Model.leftImageFrame;
    self.iconImageView.frame = comment_Model.iconFrame;
    self.iconImageView.layer.cornerRadius = self.iconImageView.height * 0.5;
    self.iconImageView.layer.masksToBounds = YES;
    self.pointButton.frame = comment_Model.pointFrame;
    self.nameLabel.frame = comment_Model.nameFrame;
    self.floorLabel.frame = comment_Model.floorFrame;
    self.timeLabel.frame = comment_Model.timeFrame;
    self.arrowLabel.frame = comment_Model.arrowFrame;
    self.beReplyNameLabel.frame = comment_Model.beReplyNameFrame;
    self.likeButton.frame = comment_Model.agreeFrame;
    self.animateView.frame = comment_Model.annimateFrame;
    self.title_label.frame = comment_Model.titleFrame;
    self.bottomView.frame = comment_Model.bottomBeReplyFrame;
    self.replyPlayButton.frame = comment_Model.replyPlayFrame;
    self.replyNameLabel.frame = comment_Model.replyNameFrame;
    self.replyTitleLabel.frame = comment_Model.replyTitleFrame;
    self.allReplyButton.frame = comment_Model.allReplyFrame;
    self.lineView.frame = comment_Model.lineFrame;
    
    self.tagView.isCircle = comment_Model.user.isCircleAdmin;
    self.tagView.isFloor = [comment_Model.user.userId isEqualToString:comment_Model.storyUserId];
    self.tagView.level = comment_Model.user.circleLevel;
    
    JANewReplyModel *reply = comment_Model.replyList.firstObject;
    self.replyNameTagView.isCircle = reply.user.isCircleAdmin;
    self.replyNameTagView.isFloor = [reply.user.userId isEqualToString:comment_Model.storyUserId];
    self.replyNameTagView.level = reply.user.circleLevel;
    
    // 3.1
    self.goBackButton.frame = comment_Model.goBackButtonFrame;
    
    [self layoutIfNeeded];
    [self setNeedsLayout];
    
    if (comment_Model.needActionButton == 1) {
        self.goBackButton.hidden = NO;
        [self.goBackButton setTitle:@"返回浏览位置" forState:UIControlStateNormal];
    }else if (comment_Model.needActionButton == 2){
        self.goBackButton.hidden = NO;
        [self.goBackButton setTitle:@"回到顶楼" forState:UIControlStateNormal];
    }else{
        self.goBackButton.hidden = YES;
    }
    
    if (comment_Model.sort.integerValue == 1) { // 12.19周五 之前是判断的是>0,因为精华帖可能要排序,服务端改推荐 sort另有用途，要改为判断 == 1
        self.leftImageView.hidden = YES;
    }else{
        self.leftImageView.hidden = YES;
    }
    
    if (self.animateView.width == 0 && self.animateView.height == 0) {
        self.animateView.hidden = YES;
    }else{
        self.animateView.hidden = NO;
    }
    
    int h = 35;
    int w = h;
    NSString *url = [comment_Model.user.avatar ja_getFitImageStringWidth:w height:h];
    if (comment_Model.user.isAnonymous) {
        self.iconImageView.image = [UIImage imageNamed:@"anonymous_head"];
    }else{
        
        [self.iconImageView ja_setImageWithURLStr:url];
    }
    self.nameLabel.text = comment_Model.user.userName;
    
    self.floorLabel.text = [NSString stringWithFormat:@"第%@楼 |",comment_Model.floorNum];
    self.timeLabel.text = [NSString distanceTimeWithBeforeTime:comment_Model.createTime.doubleValue];
    
    
    if (comment_Model.agreeCount.integerValue > 10000) {
        NSString *str = [NSString stringWithFormat:@"%.1fw",comment_Model.agreeCount.integerValue / 10000.0];
        [self.likeButton setTitle:str forState:UIControlStateNormal];
    }else{
        [self.likeButton setTitle:comment_Model.agreeCount forState:UIControlStateNormal];
    }
    
    
    if (!comment_Model.isAgree) {
        self.likeButton.selected = NO;
    }else{
        self.likeButton.selected = YES;
    }
    
    self.title_label.text = comment_Model.content;
    
    self.animateView.time = [NSString getShowTime:comment_Model.time];
    
    if (comment_Model.replyList.count) {
        self.bottomView.hidden = NO;
        self.replyNameTagView.hidden = NO;
        JANewReplyModel *reply = comment_Model.replyList.firstObject;
        self.replyNameLabel.text = reply.user.userName;
        
        self.replyTitleLabel.text = [NSString stringWithFormat:@":%@",reply.content];
        [self.allReplyButton setTitle:[NSString stringWithFormat:@"查看全部%@条回复",comment_Model.replyCount] forState:UIControlStateNormal];
    }else{
        self.bottomView.hidden = YES;
        self.replyNameTagView.hidden = YES;
    }
    
    self.lastAgreeState = self.likeButton.selected;
  
    // 波形图的赋值
    if ([JANewPlaySingleTool shareNewPlaySingleTool].musicType == JANewPlaySingleToolType_comment && [[JANewPlaySingleTool shareNewPlaySingleTool].currentMusic_comment.commentId isEqualToString:self.comment_Model.commentId]) {
        
        if ([JANewPlaySingleTool shareNewPlaySingleTool].totalDuration > 0) {
            
            // 计算进度
            CGFloat p = [JANewPlaySingleTool shareNewPlaySingleTool].currentDuration / [JANewPlaySingleTool shareNewPlaySingleTool].totalDuration;
            [self.animateView beginVolumeAnimate:p];
            NSTimeInterval curDuration = [NSString getSeconds:self.comment_Model.time] - [JANewPlaySingleTool shareNewPlaySingleTool].currentDuration;
            if (curDuration > 0) {
                self.animateView.time = [NSString getShowTime:[NSString stringWithFormat:@"%02d:%02d",(int)curDuration/60,(int)curDuration%60]];
            }
        }else{
            [self.animateView resetVolumeAnimate];
            self.animateView.time = [NSString getShowTime:self.comment_Model.time];
        }
        
        NSInteger status = [JANewPlaySingleTool shareNewPlaySingleTool].playType;
        if (status == 0) {
            self.animateView.playButton.selected = NO;
            [self.animateView setPlayLoadingViewHidden:YES];
        }else if (status == 1){
            self.animateView.playButton.selected = YES;
            [self.animateView setPlayLoadingViewHidden:YES];
        }else if (status == 2){
            self.animateView.playButton.selected = NO;
            [self.animateView setPlayLoadingViewHidden:YES];
        }else if (status == 3){
            [self.animateView setPlayLoadingViewHidden:NO];
        }
        
    }else{
        [self.animateView resetVolumeAnimate];
        self.animateView.time = [NSString getShowTime:self.comment_Model.time];
        self.animateView.playButton.selected = NO;
        [self.animateView setPlayLoadingViewHidden:YES];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.replyTitleLabel.x = self.replyNameLabel.right + self.replyNameTagView.width + 5;
    self.replyTitleLabel.width = self.bottomView.width - self.replyTitleLabel.x;
    
    self.arrowLabel.x = self.nameLabel.right + self.tagView.width + 5;
    self.beReplyNameLabel.x = self.arrowLabel.right + 3;
}

#pragma mark - 设置回复的model
- (void)setReply_Model:(JANewReplyModel *)reply_Model
{
    _reply_Model = reply_Model;
    self.leftImageView.frame = reply_Model.leftImageFrame;
    self.iconImageView.frame = reply_Model.iconFrame;
    self.iconImageView.layer.cornerRadius = self.iconImageView.height * 0.5;
    self.iconImageView.layer.masksToBounds = YES;
    self.pointButton.frame = reply_Model.pointFrame;
    self.nameLabel.frame = reply_Model.nameFrame;
//    self.nameTagLabel.frame = reply_Model.nameTagFrame;
    self.floorLabel.frame = reply_Model.floorFrame;
    self.timeLabel.frame = reply_Model.timeFrame;
    self.arrowLabel.frame = reply_Model.arrowFrame;
    self.beReplyNameLabel.frame = reply_Model.beReplyNameFrame;
    self.likeButton.frame = reply_Model.agreeFrame;
    self.animateView.frame = reply_Model.annimateFrame;
    self.title_label.frame = reply_Model.titleFrame;
    self.bottomView.frame = reply_Model.bottomBeReplyFrame;
    self.replyPlayButton.frame = reply_Model.replyPlayFrame;
    self.replyNameLabel.frame = reply_Model.replyNameFrame;
//    self.replyNameTagLabel.frame = reply_Model.replyNameTagFrame;
    self.replyTitleLabel.frame = reply_Model.replyTitleFrame;
    self.allReplyButton.frame = reply_Model.allReplyFrame;
    self.lineView.frame = reply_Model.lineFrame;
//    self.circleTagLabel.frame = reply_Model.circleTagFrame;
    
    self.replyNameTagView.hidden = YES;
    
    self.tagView.isCircle = reply_Model.user.isCircleAdmin;
    self.tagView.isFloor = [reply_Model.user.userId isEqualToString:reply_Model.storyUserId];
    self.tagView.level = reply_Model.user.circleLevel;
    
    [self layoutIfNeeded];
    [self setNeedsLayout];
    
    int h = 25;
    int w = h;
    NSString *url = [reply_Model.user.avatar ja_getFitImageStringWidth:w height:h];
    
    if (reply_Model.user.isAnonymous) {
        self.iconImageView.image = [UIImage imageNamed:@"anonymous_head"];
    } else {
        [self.iconImageView ja_setImageWithURLStr:url];
    }
    self.nameLabel.text = reply_Model.user.userName;
    
    self.beReplyNameLabel.text = reply_Model.replyUser.userName;
    
    self.timeLabel.text = [NSString distanceTimeWithBeforeTime:reply_Model.createTime.doubleValue];
    
    self.title_label.text = reply_Model.content;
    
    self.animateView.time = [NSString getShowTime:reply_Model.time];
    
    // 波形图的赋值
    if ([JANewPlaySingleTool shareNewPlaySingleTool].musicType == JANewPlaySingleToolType_reply && [[JANewPlaySingleTool shareNewPlaySingleTool].currentMusic_reply.replyId isEqualToString:self.reply_Model.replyId]) {
        
        if ([JANewPlaySingleTool shareNewPlaySingleTool].totalDuration > 0) {
            
            // 计算进度
            CGFloat p = [JANewPlaySingleTool shareNewPlaySingleTool].currentDuration / [JANewPlaySingleTool shareNewPlaySingleTool].totalDuration;
            [self.animateView beginVolumeAnimate:p];
            NSTimeInterval curDuration = [NSString getSeconds:self.reply_Model.time] - [JANewPlaySingleTool shareNewPlaySingleTool].currentDuration;
            if (curDuration > 0) {
                self.animateView.time = [NSString getShowTime:[NSString stringWithFormat:@"%02d:%02d",(int)curDuration/60,(int)curDuration%60]];
            }
        }else{
            [self.animateView resetVolumeAnimate];
            self.animateView.time = [NSString getShowTime:self.reply_Model.time];
        }
        
        NSInteger status = [JANewPlaySingleTool shareNewPlaySingleTool].playType;
        if (status == 0) {
            self.animateView.playButton.selected = NO;
            [self.animateView setPlayLoadingViewHidden:YES];
        }else if (status == 1){
            self.animateView.playButton.selected = YES;
            [self.animateView setPlayLoadingViewHidden:YES];
        }else if (status == 2){
            self.animateView.playButton.selected = NO;
            [self.animateView setPlayLoadingViewHidden:YES];
        }else if (status == 3){
            [self.animateView setPlayLoadingViewHidden:NO];
        }
        
    }else{
        [self.animateView resetVolumeAnimate];
        self.animateView.time = [NSString getShowTime:self.reply_Model.time];
        self.animateView.playButton.selected = NO;
        [self.animateView setPlayLoadingViewHidden:YES];
    }
}
#pragma mark - 设置cell类型
- (void)setCellType:(VoiceCommentType)cellType
{
    _cellType = cellType;

    if (cellType == VoiceCommentType_reply) {

        self.likeButton.hidden = YES;
        self.bottomView.hidden = YES;
        self.arrowLabel.hidden = NO;
        self.beReplyNameLabel.hidden = NO;

    }
}


#pragma mark - 单双击点赞
// 单击点赞
- (void)clickAgree:(JAEmitterView *)sender
{
    if (!IS_LOGIN) {
        [JAAPPManager app_modalLogin];
        return;
    }
    
    sender.selected = !sender.selected;
    
    if (self.refreshCommentOrReplyAgreeStatus) {
        self.refreshCommentOrReplyAgreeStatus(sender.selected);
    }
    
    if (self.comment_Model) {
        
        NSInteger agreeCount = [self.comment_Model.agreeCount integerValue];
        
        if (sender.selected) {
            self.comment_Model.agreeCount = [NSString stringWithFormat:@"%zd",++agreeCount];
            self.agreeMethod = @"点击按钮喜欢";
        } else {
            
            self.comment_Model.agreeCount = [NSString stringWithFormat:@"%zd",--agreeCount];
        }
        NSString *agreeStr = [NSString stringWithFormat:@"%@",self.comment_Model.agreeCount];
        [self.likeButton setTitle:agreeStr forState:UIControlStateNormal];
    }

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(myDelayedMethod) object:self];
    [self performSelector:@selector(myDelayedMethod) withObject:self afterDelay:0.3];
}

- (void)myDelayedMethod
{
    
    if (self.likeButton.selected != self.lastAgreeState) {
        self.lastAgreeState = self.likeButton.selected;
        // 根据返回结果修改模型中 isAgree的值 和点赞数
        if (_cellType == VoiceCommentType_reply) {
//            self.replyModel.isAgree = self.likeButton.selected;
        }else{
            self.comment_Model.isAgree = self.likeButton.selected;
        }
        [self zanAction];
        
        // 神策数据
        if (self.likeButton.selected) {
            NSString *string = _cellType == VoiceCommentType_reply ? JA_REPLY_TYPE : JA_COMMENT_TYPE;
            id model = _cellType == VoiceCommentType_reply ? self.reply_Model : self.comment_Model;
            [self sensorsAnalyticsWithLikeType:string model:model method:self.agreeMethod];
        }
    }
}
#pragma mark - 网络请求
// 点赞
- (void)zanAction
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    dic[@"actionType"] = @"agree";
    
    if (_cellType == VoiceCommentType_reply) {
        dic[@"typeId"] = self.reply_Model.replyId;
        dic[@"type"] = @"reply";
    }else{
        dic[@"typeId"] = self.comment_Model.commentId;
        dic[@"type"] = @"comment";
    }
    
    [[JAVoiceCommonApi shareInstance] voice_agreeWithParas:dic success:^(NSDictionary *result) {
        
    } failure:^(NSError *error) {
        
    }];
}


#pragma mark - 点击事件
- (void)clickRight_point:(UIButton *)btn
{
    if (self.pointClickBlock) {
        self.pointClickBlock(self);
    }
}

- (void)jumpPersonalVc
{
    if (self.jumpPersonalViewControlBlock) {
        self.jumpPersonalViewControlBlock(self);
    }
}

- (void)jumpBeReplyPersonalVc // 跳转被回复者的个人主页
{
    if (self.jumpBeReplyPersonalViewControlBlock) {
        self.jumpBeReplyPersonalViewControlBlock(self);
    }
}

- (void)playComment
{

    if (self.playCommentBlock) {
        self.playCommentBlock(self);
    }
}

- (void)jumpCommentDetailVc
{
    if (self.jumpReplyViewControlBlock) {
        self.jumpReplyViewControlBlock(self);
    }
}

- (void)jumpReplyPersonalVc
{
    if (self.jumpReplyPersonalViewControlBlock) {
        self.jumpReplyPersonalViewControlBlock(self);
    }
}

// 神策数据
- (void)sensorsAnalyticsWithLikeType:(NSString *)type model:(id)model method:(NSString *)method
{
    NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
    
    if ([type isEqualToString:JA_STORY_TYPE]) {
        
        JANewVoiceModel *voiceM = (JANewVoiceModel *)model;
        // 计算时间
        NSArray *timeArr = [voiceM.time componentsSeparatedByString:@":"];
        NSString *min = timeArr.firstObject;
        NSString *sec = timeArr.lastObject;
        NSInteger sen_time = min.integerValue * 60 + sec.integerValue;
        
        senDic[JA_Property_ContentId] = voiceM.storyId;
        senDic[JA_Property_ContentTitle] = voiceM.content;
        senDic[JA_Property_ContentType] = @"主帖";
        senDic[JA_Property_Anonymous] = @(voiceM.user.isAnonymous);
        senDic[JA_Property_RecordDuration] = @(sen_time);
        senDic[JA_Property_PostId] = voiceM.user.userId;
        senDic[JA_Property_PostName] = voiceM.user.userName;
        senDic[JA_Property_LikeMethod] = method;
        senDic[JA_Property_SourcePage] = voiceM.sourceName;
        senDic[JA_Property_RecommendType] = voiceM.recommendType;
        
    }else if([type isEqualToString:JA_COMMENT_TYPE]){
        
        JANewCommentModel *commentM = (JANewCommentModel *)model;
        // 计算时间
        NSArray *timeArr = [commentM.time componentsSeparatedByString:@":"];
        NSString *min = timeArr.firstObject;
        NSString *sec = timeArr.lastObject;
        NSInteger sen_time = min.integerValue * 60 + sec.integerValue;
        
        senDic[JA_Property_ContentId] = commentM.commentId;
        senDic[JA_Property_ContentTitle] = commentM.content;
        senDic[JA_Property_ContentType] = @"一级回复";
        senDic[JA_Property_Anonymous] = @(commentM.user.isAnonymous);
        senDic[JA_Property_RecordDuration] = @(sen_time);
        senDic[JA_Property_PostId] = commentM.user.userId;
        senDic[JA_Property_PostName] = commentM.user.userName;
        senDic[JA_Property_LikeMethod] = method;
//        senDic[JA_Property_SourcePage] = commentM.sourceName;
//        senDic[JA_Property_RecommendType] = commentM.recommendType;
        
    }else if ([type isEqualToString:JA_REPLY_TYPE]){
        
        JANewReplyModel *replyM = (JANewReplyModel *)model;
        // 计算时间
        NSArray *timeArr = [replyM.time componentsSeparatedByString:@":"];
        NSString *min = timeArr.firstObject;
        NSString *sec = timeArr.lastObject;
        NSInteger sen_time = min.integerValue * 60 + sec.integerValue;
        
        senDic[JA_Property_ContentId] = replyM.replyId;
        senDic[JA_Property_ContentTitle] = replyM.content;
        senDic[JA_Property_ContentType] = @"二级回复";
        senDic[JA_Property_Anonymous] = @(replyM.user.isAnonymous);
        senDic[JA_Property_RecordDuration] = @(sen_time);
        senDic[JA_Property_PostId] = replyM.user.userId;
        senDic[JA_Property_PostName] = replyM.user.userName;
        senDic[JA_Property_LikeMethod] = method;
//        senDic[JA_Property_SourcePage] = replyM.sourceName;
//        senDic[JA_Property_RecommendType] = replyM.recommendType;
    }
    [JASensorsAnalyticsManager sensorsAnalytics_clickAgree:senDic];
}

@end
