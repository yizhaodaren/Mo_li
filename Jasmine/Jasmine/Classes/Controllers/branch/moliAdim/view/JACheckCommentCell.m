//
//  JACheckCommentCell.m
//  Jasmine
//
//  Created by moli-2017 on 2017/9/25.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JACheckCommentCell.h"
#import "JAPaddingLabel.h"
#import "JAPlayWaveView.h"
#import "JAVoiceWaveView.h"
#import "JAVoiceCommonApi.h"
#import "JAEmitterView.h"
#import "JAPlayAnimateView.h"
#import "JAVoicePlayerManager.h"

@interface JACheckCommentCell ()<JAPlayerDelegate>
@property (nonatomic, weak) UIImageView *leftImageView;   // 神回复

@property (nonatomic, weak) UIImageView *iconImageView;  // 头像
@property (nonatomic, weak) UILabel *nameLabel;         // 名字
@property (nonatomic, weak) UILabel *timeLabel;         // 时间

@property (nonatomic, weak) JAEmitterView *likeButton; // 点赞
@property (nonatomic, weak) UIButton *pointButton;   // 三个点

@property (nonatomic, weak) UILabel *title_label;              // 内容标题
@property (nonatomic, weak) JAPlayAnimateView *animateView;   // 新的波形图

@property (nonatomic, weak) UIView *bottomView;             // 底部view
@property (nonatomic, weak) UIButton *replyPlayButton;      // 底部播放按钮
@property (nonatomic, weak) UILabel *replyNameLabel;    // 回复者的名字
@property (nonatomic, weak) UILabel *replyTitleLabel;       // 底部内容标题

@property (nonatomic, weak) UIView *lineView;

@property (nonatomic, assign) BOOL lastAgreeState;// 0未点赞1已赞

@end

@implementation JACheckCommentCell
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[JAVoicePlayerManager shareInstance] removeDelegate:self];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupCellUI];
    }
    return self;
}

- (void)setupCellUI
{
    // 神回复
    UIImageView *leftImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shenhuifu"]];
    _leftImageView = leftImageView;
    [self.contentView addSubview:leftImageView];
    
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
    timeLabel.textColor = HEX_COLOR(JA_BlackSubTitle);
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
    likeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [self.contentView addSubview:likeButton];
    
    // 三个点
    UIButton *pointButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _pointButton = pointButton;
    [pointButton setImage:[UIImage imageNamed:@"person_point_black"] forState:UIControlStateNormal];
    [pointButton addTarget:self action:@selector(clickRight_point:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:pointButton];
    
    JAPlayAnimateView *animateView = [[JAPlayAnimateView alloc] initWithColor:HEX_COLOR(0x6BD379) frame:CGRectZero];
    _animateView = animateView;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playCommentAndReply)];
    [self.animateView addGestureRecognizer:tap];
    [self.contentView addSubview:animateView];
    
    // 标题
    UILabel *title_label = [[UILabel alloc] init];
    _title_label = title_label;
    title_label.text = @" ";
    title_label.textColor = HEX_COLOR(JA_Title);
    title_label.font = JA_REGULAR_FONT(JA_CommentDetail_commentFont);
    title_label.numberOfLines = 0;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playNotification:) name:JAPlayNotification object:nil];
    [[JAVoicePlayerManager shareInstance] addDelegate:self];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self caculatorReplyPostsFrame];
}

- (void)caculatorReplyPostsFrame
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
    self.likeButton.x = JA_SCREEN_WIDTH - 75 - 35;
    self.likeButton.centerY = self.iconImageView.centerY;
    
    self.pointButton.width = 50;
    self.pointButton.height = 35;
    self.pointButton.x = JA_SCREEN_WIDTH - 50;
    self.pointButton.y = self.likeButton.y;
    
    self.animateView.width = 210;
    self.animateView.height = 35;
    self.animateView.x = self.timeLabel.x;
    self.animateView.y = self.timeLabel.bottom + 15;
    
    self.title_label.x = self.nameLabel.x;
    self.title_label.width = JA_SCREEN_WIDTH - self.title_label.x - 15;
    [self.title_label sizeToFit];
    self.title_label.width = JA_SCREEN_WIDTH - self.title_label.x - 15;
    self.title_label.y = self.commentModel.audioUrl.length ? self.animateView.bottom + 10 : self.timeLabel.bottom + 12;
    
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
    self.replyNameLabel.x = self.replyPlayButton.right + 7;
    self.replyNameLabel.centerY = self.replyPlayButton.centerY;
    
    [self.replyTitleLabel sizeToFit];
    self.replyTitleLabel.x = self.replyNameLabel.right;
    self.replyTitleLabel.width = self.bottomView.width - self.replyTitleLabel.x;
    self.replyTitleLabel.centerY = self.replyPlayButton.centerY;
    
    self.lineView.width = self.contentView.width;
    self.lineView.height = 1;
    self.lineView.y = self.bottomView.bottom + 15;
}

#pragma mark - 模型数据
- (void)setCommentModel:(JAVoiceCommentModel *)commentModel
{
    _commentModel = commentModel;
    
    if (commentModel.sort.integerValue == 1) {
        self.leftImageView.hidden = NO;
    }else{
        self.leftImageView.hidden = YES;
    }
    
    if (commentModel.audioUrl.length) {  // 音频有波形图
        self.animateView.hidden = NO;
    }else{
        self.animateView.hidden = YES;
    }
    
    int h = 35;
    int w = h;
    NSString *url = [commentModel.userImage ja_getFitImageStringWidth:w height:h];
    
    if (commentModel.isAnonymous) {
        
        self.nameLabel.text = commentModel.anonymousName.length ? commentModel.anonymousName : @"匿名用户";
        self.iconImageView.image = [UIImage imageNamed:@"anonymous_head"];
    } else {
        self.nameLabel.text = commentModel.userName;
        [self.iconImageView ja_setImageWithURLStr:url];
    }
    
    self.timeLabel.text = [NSString distanceTimeWithBeforeTime:commentModel.createTime.doubleValue];
    
    
    if (commentModel.agreeCount.integerValue > 10000) {
        NSString *str = [NSString stringWithFormat:@"%.1fw",commentModel.agreeCount.integerValue / 10000.0];
        [self.likeButton setTitle:str forState:UIControlStateNormal];
    }else{
        [self.likeButton setTitle:commentModel.agreeCount forState:UIControlStateNormal];
    }
    
    
    if (!commentModel.isAgree) {
        self.likeButton.selected = NO;
    }else{
        self.likeButton.selected = YES;
    }
    
    self.title_label.text = commentModel.content;
    
    
    self.animateView.time = [NSString getShowTime:commentModel.time];
    
    if (commentModel.s2cStoryMsg) {
        
        if (commentModel.s2cStoryMsg.isAnonymous) {
            self.replyNameLabel.text = [NSString stringWithFormat:@"%@",commentModel.s2cStoryMsg.anonymousName.length ? commentModel.s2cStoryMsg.anonymousName : @"匿名用户"];
        }else{
            self.replyNameLabel.text = [NSString stringWithFormat:@"%@",commentModel.s2cStoryMsg.userName];
        }
        self.replyTitleLabel.text = [NSString stringWithFormat:@":%@",commentModel.s2cStoryMsg.content];
    }else{
        self.replyTitleLabel.text = @"该帖已被删除";
    }
    
    self.lastAgreeState = self.likeButton.selected;
    
    // 设置波形图颜色
    int type = [commentModel.voiceCommendId integerValue] % 8;
    NSDictionary *colorDic = [JAAPPManager app_waveViewColorWithType:type];
    if (colorDic) {
        unsigned long wave_color = strtoul([colorDic[@"reply_wave_color"] UTF8String],0,0);
        self.animateView.backgroundColor = HEX_COLOR(wave_color);
    }
    
    // 语音
    JAVoiceCommentModel *playcommentModel = [JAVoicePlayerManager shareInstance].commentModel;
    if ([playcommentModel.voiceCommendId isEqualToString:self.commentModel.voiceCommendId]) {
        self.commentModel.playState = playcommentModel.playState;
    } else {
        self.commentModel.playState = 0;
    }
    if (commentModel.playState == 1) {
        self.animateView.playButton.selected = YES;
    } else {
        self.animateView.playButton.selected = NO;
        
        if (commentModel.playState == 0) {
            self.animateView.playButton.selected = NO;
            [self.animateView resetVolumeAnimate];
            [self resetVoiceTime:commentModel.time];
        } else {
            JAVoiceCommentModel *model = [JAVoicePlayerManager shareInstance].commentModel;
            if ([model.voiceCommendId isEqualToString:self.commentModel.voiceCommendId]) {
                self.animateView.playButton.selected = NO;
                [self.animateView beginVolumeAnimate:[JAVoicePlayerManager shareInstance].playProgress];
                [self setCurrentVoiceTime];
            }
        }
    }
    
    [self caculatorReplyPostsFrame];
}
#pragma mark - 重置时间
- (void)resetVoiceTime:(NSString *)time
{
    self.animateView.time = [NSString getShowTime:time];
}
// 倒计时
- (void)setCurrentVoiceTime {
    JAVoiceCommentModel *commentModel = [JAVoicePlayerManager shareInstance].commentModel;
    if ([commentModel.voiceCommendId isEqualToString:self.commentModel.voiceCommendId]) {
        NSTimeInterval curDuration = [NSString getSeconds:commentModel.time] - [JAVoicePlayerManager shareInstance].player.progress;
        if (curDuration > 0) {
            NSString *time = [NSString stringWithFormat:@"%02d:%02d",(int)curDuration/60,(int)curDuration%60];
            self.animateView.time = [NSString getShowTime:time];
        }
    }
}

#pragma mark - 点击事件
#pragma mark - 按钮的点击
- (void)clickRight_point:(UIButton *)btn   // 三个点
{
    if (self.admin_personalPointClickBlock) {
        self.admin_personalPointClickBlock(self);
    }
}

- (void)jumpPersonCenterVC      // 个人中心
{
    if (self.admin_jumpPersonalCenterBlock) {
        self.admin_jumpPersonalCenterBlock(self);
    }
}

- (void)playCommentAndReply   // 播放
{
    if (self.admin_playCommentOrReplyBlock) {
        self.admin_playCommentOrReplyBlock(self);
    }
}

- (void)jumpReplyPersonalVc   // 去被回复者的个人中心
{
    if (self.admin_jumpReplyPersonalViewControlBlock) {
        self.admin_jumpReplyPersonalViewControlBlock(self);
    }
}

#pragma mark - 收到的播放通知
- (void)playNotification:(NSNotification *)noti {
    JAVoiceCommentModel *commentModel = [JAVoicePlayerManager shareInstance].commentModel;
    if ([commentModel.voiceCommendId isEqualToString:self.commentModel.voiceCommendId]) {
        self.commentModel.playState = commentModel.playState;
    } else {
        self.commentModel.playState = 0;
    }
    
    // 语音
    if (self.commentModel.playState == 1) {
        self.animateView.playButton.selected = YES;
        
    } else {
        self.animateView.playButton.selected = NO;
        
        
        if (self.commentModel.playState == 0) {
            [self resetVoiceTime:self.commentModel.time];
            [self.animateView resetVolumeAnimate];
        }else{
            [self setCurrentVoiceTime];
        }
    }
    
}

#pragma mark - JAPlayerDelegate
- (void)audioPlayerDidCurrentTime:(NSTimeInterval)time duration:(NSTimeInterval)duration {
    JAVoiceCommentModel *commentModel = [JAVoicePlayerManager shareInstance].commentModel;
    if ([commentModel.voiceCommendId isEqualToString:self.commentModel.voiceCommendId] && commentModel.playState == 1) {
        CGFloat pro = time / duration;
        [self.animateView beginVolumeAnimate:pro];
        // 开始动画
        int min = (int)(duration - time)/60;
        int sec = (int)(duration - time) %60;
        
        if (min > 0) {
            self.animateView.time = [NSString stringWithFormat:@"%d'%02d\"",min,sec];
        }else{
            self.animateView.time = [NSString stringWithFormat:@"%02d\"",sec];
        }
    }
}
@end
