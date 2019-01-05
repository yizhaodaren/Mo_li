//
//  JAPersonalReplyCell.m
//  Jasmine
//
//  Created by 刘宏亮 on 2017/12/19.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAPersonalReplyCell.h"
#import "JAVoiceWaveView.h"
#import "JAEmitterView.h"
#import "JASampleHelper.h"
#import "JAPlayAnimateView.h"
#import "JAVoiceCommonApi.h"
#import "KILabel.h"

#import "JANewCommentModel.h"
#import "JANewPlaySingleTool.h"

@interface JAPersonalReplyCell ()<JAEmitterViewDelegate>

@property (nonatomic, weak) UIImageView *leftImageView;   // 神回复

@property (nonatomic, weak) UIImageView *iconImageView;  // 头像
@property (nonatomic, weak) UILabel *nameLabel;         // 名字
@property (nonatomic, weak) UILabel *timeLabel;         // 时间
@property (nonatomic, weak) JAEmitterView *likeButton; // 点赞

@property (nonatomic, weak) KILabel *title_label;              // 内容标题

@property (nonatomic, weak) JAPlayAnimateView *animateView;   // 新的波形图

@property (nonatomic, weak) UIView *bottomView;             // 底部view
@property (nonatomic, weak) UIButton *replyPlayButton;      // 底部播放按钮
@property (nonatomic, weak) UILabel *replyNameLabel;    // 回复者的名字
@property (nonatomic, weak) UILabel *replyTitleLabel;       // 底部内容标题

@property (nonatomic, weak) UIView *lineView;


@property (nonatomic, assign) BOOL lastAgreeState;// 0未点赞1已赞

@property (nonatomic, strong) NSString *agreeMethod;   // 神策数据（点赞方式）

@property (nonatomic, assign) NSTimeInterval frontTime;

//@property (nonatomic, assign) CGFloat waveViewWidth;
//@property (nonatomic, assign) int allCount;
@end

@implementation JAPersonalReplyCell

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupPersonalReplyCell];
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
        if (self.personalPointClickBlock) {
            self.personalPointClickBlock(self);
        }
    }
}

#pragma mark - 布置UI
- (void)setupPersonalReplyCell
{
    // 神回复
//    UIImageView *leftImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shenhuifu"]];
//    _leftImageView = leftImageView;
//    [self.contentView addSubview:leftImageView];
    
    // 头像
    UIImageView *iconImageView = [[UIImageView alloc] init];
    _iconImageView = iconImageView;
    iconImageView.image = [UIImage imageNamed:@"moren_nan"];
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpPersonCenterVC)];
    iconImageView.userInteractionEnabled = YES;
    [iconImageView addGestureRecognizer:tap1];
    [self.contentView addSubview:iconImageView];
    
    // 名字
    UILabel *nameLabel = [[UILabel alloc] init];
    _nameLabel = nameLabel;
    nameLabel.text = @" ";
    nameLabel.textColor = HEX_COLOR(JA_Title);
    nameLabel.font = JA_REGULAR_FONT(JA_PersonalDetail_commentPersonalFont);
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpPersonCenterVC)];
    nameLabel.userInteractionEnabled = YES;
    [nameLabel addGestureRecognizer:tap2];
    [self.contentView addSubview:nameLabel];
    
    // 时间
    UILabel *timeLabel = [[UILabel alloc] init];
    _timeLabel = timeLabel;
    timeLabel.text = @" ";
    timeLabel.textColor = HEX_COLOR(JA_BlackSubSubTitle);
    timeLabel.font = JA_REGULAR_FONT(12);
    [self.contentView addSubview:timeLabel];
    
    // 点赞
    JAEmitterView *likeButton = [JAEmitterView buttonWithType:UIButtonTypeCustom];
    _likeButton = likeButton;
    //    [likeButton addTarget:self action:@selector(clickAgree:) forControlEvents:UIControlEventTouchUpInside];
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
    
    JAPlayAnimateView *animateView = [[JAPlayAnimateView alloc] initWithColor:HEX_COLOR(0x6BD379) frame:CGRectZero];
    _animateView = animateView;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playCommentAndReply)];
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
            self.commentAtPersonBlock(string, self.model.atList);
        }
        
    };
    
    [self.contentView addSubview:title_label];
    
    // 底部
    UIView *bottomView = [[UIView alloc] init];
    _bottomView = bottomView;
    bottomView.backgroundColor = HEX_COLOR(0xF5F5F5);
    [self.contentView addSubview:bottomView];
    
    // 底部播放
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
    
    // 回复标题
    UILabel *replyTitleLabel = [[UILabel alloc] init];
    _replyTitleLabel = replyTitleLabel;
    replyTitleLabel.text = @" ";
    replyTitleLabel.textColor = HEX_COLOR(0x4A4A4A);
    replyTitleLabel.font = JA_REGULAR_FONT(JA_CommentDetail_replyFont);
    [bottomView addSubview:replyTitleLabel];
    
    // 线
    UIView *lineView = [[UIView alloc] init];
    _lineView = lineView;
    lineView.backgroundColor = HEX_COLOR(JA_Line);
    [self.contentView addSubview:lineView];
    
}

#pragma mark - 计算Frame
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self caculatorPersonalReplyCell];
}

- (void)caculatorPersonalReplyCell
{
    self.iconImageView.height = 35;
    self.iconImageView.width = self.iconImageView.height;
    self.iconImageView.x = 12;
    self.iconImageView.y = 15;
    self.iconImageView.layer.cornerRadius = self.iconImageView.width * 0.5;
    self.iconImageView.layer.masksToBounds = YES;
    
    [self.nameLabel sizeToFit];
    if (iPhone4 || iPhone5) {
        self.nameLabel.width = self.nameLabel.width > 90 ? 90 : self.nameLabel.width;
    }else{
        self.nameLabel.width = self.nameLabel.width > 120 ? 120 : self.nameLabel.width;
    }
    self.nameLabel.height = 20;
    self.nameLabel.x = self.iconImageView.right + 10;
    self.nameLabel.y = 15;
    
    [self.timeLabel sizeToFit];
    self.timeLabel.x = self.nameLabel.x;
    self.timeLabel.y = self.nameLabel.bottom + 1;
    self.timeLabel.height = 14;
    self.timeLabel.width = 150;
    
    [self.likeButton sizeToFit];
    self.likeButton.width = 60;
    self.likeButton.height = 35;
    self.likeButton.x = JA_SCREEN_WIDTH - 60;
    self.likeButton.centerY = self.iconImageView.centerY;
    
    
    self.animateView.width = 210;
    self.animateView.height = 35;
    self.animateView.x = self.timeLabel.x;
    self.animateView.y = self.timeLabel.bottom + 15;
    
    self.title_label.x = self.nameLabel.x;
    self.title_label.width = JA_SCREEN_WIDTH - self.title_label.x - 15;
    [self.title_label sizeToFit];
    self.title_label.width = JA_SCREEN_WIDTH - self.title_label.x - 15;
    self.title_label.y = self.model.audioUrl.length ? self.animateView.bottom + 10 : self.timeLabel.bottom + 12;
    
    
    self.bottomView.x = self.animateView.x;
    self.bottomView.y = self.title_label.bottom + 10;
    self.bottomView.width = JA_SCREEN_WIDTH - self.animateView.x - 15;
    self.bottomView.height = 42;
    self.bottomView.layer.cornerRadius = 5;
    self.bottomView.layer.masksToBounds = YES;
    
    self.replyPlayButton.width = 20;
    self.replyPlayButton.height = self.replyPlayButton.width;
    self.replyPlayButton.x = 10;
    self.replyPlayButton.y = 11;
    

    [self.replyNameLabel sizeToFit];
    self.replyNameLabel.x = self.replyPlayButton.hidden ? 10 :self.replyPlayButton.right + 7;
    self.replyNameLabel.centerY = self.replyPlayButton.centerY;
    
    [self.replyTitleLabel sizeToFit];
    self.replyTitleLabel.x = self.replyNameLabel.right;
    self.replyTitleLabel.width = self.bottomView.width - self.replyTitleLabel.x;
    self.replyTitleLabel.centerY = self.replyPlayButton.centerY;
    
    self.lineView.width = self.contentView.width;
    self.lineView.height = 1;
    self.lineView.y = self.contentView.height - 1;
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

#pragma mark - 赋值数据model
- (void)setModel:(JANewCommentModel *)model
{
    _model = model;
    
    if (model.sort.integerValue == 1) {
        self.leftImageView.hidden = NO;
    }else{
        self.leftImageView.hidden = YES;
    }
    
    if (model.audioUrl.length) {  // 音频有波形图
        self.animateView.hidden = NO;
    }else{
        self.animateView.hidden = YES;
    }
    
    int h = 35;
    int w = h;
    NSString *url = [model.user.avatar ja_getFitImageStringWidth:w height:h];
    
    if (model.user.isAnonymous) {
        self.iconImageView.image = [UIImage imageNamed:@"anonymous_head"];
    } else {
        [self.iconImageView ja_setImageWithURLStr:url];
    }
    self.nameLabel.text = model.user.userName;
    
    self.timeLabel.text = [NSString distanceTimeWithBeforeTime:model.createTime.doubleValue];
    
    
    if (model.agreeCount.integerValue > 10000) {
        NSString *str = [NSString stringWithFormat:@"%.1fw",model.agreeCount.integerValue / 10000.0];
        [self.likeButton setTitle:str forState:UIControlStateNormal];
    }else{
        [self.likeButton setTitle:model.agreeCount forState:UIControlStateNormal];
    }
    
    
    if (!model.isAgree) {
        self.likeButton.selected = NO;
    }else{
        self.likeButton.selected = YES;
    }
    
    self.title_label.text = model.content;
    
    self.animateView.time = [NSString getShowTime:model.time];
    
    JALightStoryModel *story = model.storyMsg;
    
    if (story) {
        if (story.storyType.integerValue == 0) {
            self.replyPlayButton.hidden = NO;
            self.replyNameLabel.x = self.replyPlayButton.right + 7;
            self.replyTitleLabel.x = self.replyNameLabel.right;
        }else{
            self.replyPlayButton.hidden = YES;
            self.replyNameLabel.x = 10;
            self.replyTitleLabel.x = self.replyNameLabel.right;
        }
        self.replyNameLabel.text = story.userName;
        self.replyTitleLabel.text = [NSString stringWithFormat:@":%@",[story.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        
    }else{
        self.replyPlayButton.hidden = YES;
        self.replyNameLabel.x = 10;
        self.replyTitleLabel.x = self.replyNameLabel.right;
        self.replyNameLabel.text = @"";
        self.replyTitleLabel.text = @"该帖已被删除";
    }
  
    self.lastAgreeState = self.likeButton.selected;
    
    // 波形图的赋值
    if ([JANewPlaySingleTool shareNewPlaySingleTool].musicType == JANewPlaySingleToolType_comment && [[JANewPlaySingleTool shareNewPlaySingleTool].currentMusic_comment.commentId isEqualToString:self.model.commentId]) {
        
        if ([JANewPlaySingleTool shareNewPlaySingleTool].totalDuration > 0) {
            
            // 计算进度
            CGFloat p = [JANewPlaySingleTool shareNewPlaySingleTool].currentDuration / [JANewPlaySingleTool shareNewPlaySingleTool].totalDuration;
            [self.animateView beginVolumeAnimate:p];
            NSTimeInterval curDuration = [NSString getSeconds:self.model.time] - [JANewPlaySingleTool shareNewPlaySingleTool].currentDuration;
            if (curDuration > 0) {
                self.animateView.time = [NSString getShowTime:[NSString stringWithFormat:@"%02d:%02d",(int)curDuration/60,(int)curDuration%60]];
            }
        }else{
            [self.animateView resetVolumeAnimate];
            self.animateView.time = [NSString getShowTime:self.model.time];
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
        self.animateView.time = [NSString getShowTime:self.model.time];
        self.animateView.playButton.selected = NO;
        [self.animateView setPlayLoadingViewHidden:YES];
    }

}

#pragma mark - 波形图的监听
- (void)playSingleStatusChange_refreshUI
{
    NSInteger musicType = [JANewPlaySingleTool shareNewPlaySingleTool].musicType;
    if (musicType == JANewPlaySingleToolType_comment && [[JANewPlaySingleTool shareNewPlaySingleTool].currentMusic_comment.commentId isEqualToString:self.model.commentId]) {
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

- (void)playSingleProcess_refreshUI
{
    if ([JANewPlaySingleTool shareNewPlaySingleTool].totalDuration <= 0) {
        return;
    }
    NSInteger musicType = [JANewPlaySingleTool shareNewPlaySingleTool].musicType;
    
    if (musicType == JANewPlaySingleToolType_comment && [[JANewPlaySingleTool shareNewPlaySingleTool].currentMusic_comment.commentId isEqualToString:self.model.commentId]) {
        // 计算进度
        CGFloat p = [JANewPlaySingleTool shareNewPlaySingleTool].currentDuration / [JANewPlaySingleTool shareNewPlaySingleTool].totalDuration;
        [self.animateView beginVolumeAnimate:p];
        NSTimeInterval curDuration = [NSString getSeconds:self.model.time] - [JANewPlaySingleTool shareNewPlaySingleTool].currentDuration;
        if (curDuration > 0) {
            self.animateView.time = [NSString getShowTime:[NSString stringWithFormat:@"%02d:%02d",(int)curDuration/60,(int)curDuration%60]];
        }
    }else{
        [self.animateView resetVolumeAnimate];
        self.animateView.time = [NSString getShowTime:self.model.time];
    }
}

- (void)playSingleFinish_refreshUI
{
    [self.animateView resetVolumeAnimate];
    self.animateView.playButton.selected = NO;
    [self.animateView setPlayLoadingViewHidden:YES];
    self.animateView.time = [NSString getShowTime:self.model.time];
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
   
    NSInteger agreeCount = [self.model.agreeCount integerValue];
    
    if (sender.selected) {
        self.model.agreeCount = [NSString stringWithFormat:@"%zd",++agreeCount];
        self.agreeMethod = @"点击按钮喜欢";
    } else {
        
        self.model.agreeCount = [NSString stringWithFormat:@"%zd",--agreeCount];
    }
    NSString *agreeStr = [NSString stringWithFormat:@"%@",self.model.agreeCount];
    [self.likeButton setTitle:agreeStr forState:UIControlStateNormal];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(myDelayedMethod) object:self];
    [self performSelector:@selector(myDelayedMethod) withObject:self afterDelay:0.3];
}

- (void)myDelayedMethod
{
    if (self.likeButton.selected != self.lastAgreeState) {
        self.lastAgreeState = self.likeButton.selected;
        // 根据返回结果修改模型中 isAgree的值 和点赞数
        self.model.isAgree = self.likeButton.selected;
        [self zanAction];
        
        // 神策数据
        if (self.likeButton.selected) {
            [self sensorsAnalyticsWithLikeType:JA_COMMENT_TYPE model:self.model method:self.agreeMethod];
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
    dic[@"typeId"] = self.model.commentId;
    dic[@"type"] = @"comment";
    
    [[JAVoiceCommonApi shareInstance] voice_agreeWithParas:dic success:^(NSDictionary *result) {
        
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - 按钮的点击
- (void)jumpPersonCenterVC
{
    if (self.jumpPersonalCenterBlock) {
        self.jumpPersonalCenterBlock(self);
    }
}

- (void)playCommentAndReply
{
    if (self.playCommentOrReplyBlock) {
        self.playCommentOrReplyBlock(self);
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
