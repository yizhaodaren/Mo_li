//
//  JAVoiceReplyCell.m
//  Jasmine
//
//  Created by moli-2017 on 2017/8/30.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAVoiceReplyCell.h"
#import "JAVoiceWaveView.h"
#import "JASampleHelper.h"
#import "JAPlayAnimateView.h"
#import "KILabel.h"
#import "JAVoicePlayerManager.h"

@interface JAVoiceReplyCell ()<JAPlayerDelegate>

@property (nonatomic, weak) UIImageView *iconImageView;  // 头像
@property (nonatomic, weak) UILabel *nameLabel;         // 名字
@property (nonatomic, weak) UILabel *timeLabel;         // 时间
@property (nonatomic, weak) UILabel *operationLbel;     // 回复了你
@property (nonatomic, weak) UIImageView *unreadImageView;  // 未读标记
@property (nonatomic, weak) UIButton *recordButton;       // 回复按钮

@property (nonatomic, weak) KILabel *title_label;              // 内容标题
@property (nonatomic, weak) JAPlayAnimateView *animateView;   // 新的波形图

//@property (nonatomic, weak) UIButton *playButton;           // 播放按钮
//@property (nonatomic, weak) JAVoiceWaveView *progressView;   // 波形图
//@property (nonatomic, weak) UILabel *voiceDurationLabel;  // 音频时长

@property (nonatomic, weak) UIView *bottomView;             // 底部view
@property (nonatomic, weak) UIButton *replyPlayButton;      // 底部播放按钮
@property (nonatomic, weak) UILabel *replyTitleLabel;       // 底部内容标题

@property (nonatomic, weak) UIView *lineView;

@property (nonatomic, assign) int allCount;

@property (nonatomic, assign) CGFloat waveViewWidth;

@end

@implementation JAVoiceReplyCell

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[JAVoicePlayerManager shareInstance] removeDelegate:self];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupVoiceReplyCell];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setupVoiceReplyCell
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
    operationLbel.text = @"回复了你的帖子";
    operationLbel.textColor = HEX_COLOR(JA_BlackSubTitle);
    operationLbel.font = JA_REGULAR_FONT(JA_PersonalDetail_commentPersonalFont);
    [self.contentView addSubview:operationLbel];
    
    UIImageView *unreadImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"branch_noti_unread"]];
    _unreadImageView = unreadImageView;
    [self.contentView addSubview:unreadImageView];
    
    UIButton *recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _recordButton = recordButton;
//    [recordButton setImage:[UIImage imageNamed:@"branch_voice_reply"] forState:UIControlStateNormal];
    [recordButton addTarget:self action:@selector(jumpRecordVC) forControlEvents:UIControlEventTouchUpInside];
    [recordButton setTitle:@"回复" forState:UIControlStateNormal];
    [recordButton setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateNormal];
    recordButton.titleLabel.font = JA_REGULAR_FONT(13);
    recordButton.backgroundColor = HEX_COLOR(0x4A90E2);
//    recordButton.layer.borderColor = HEX_COLOR(0xBC5800).CGColor;
//    recordButton.layer.borderWidth = 1;
    
    [self.contentView addSubview:recordButton];
    
    JAPlayAnimateView *animateView = [[JAPlayAnimateView alloc] initWithColor:HEX_COLOR(0x6BD379) frame:CGRectZero];
    _animateView = animateView;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playCommentAndReply)];
    [self.animateView addGestureRecognizer:tap];
    self.animateView.backgroundColor = HEX_COLOR(0x6BD379);
    [self.contentView addSubview:animateView];
    
    
//    UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    _playButton = playButton;
//    [playButton addTarget:self action:@selector(playCommentAndReply:) forControlEvents:UIControlEventTouchUpInside];
//    [playButton setImage:[UIImage imageNamed:@"branch_voice_commentplay"] forState:UIControlStateNormal];
//    [playButton setImage:[UIImage imageNamed:@"branch_voice_commentpause"] forState:UIControlStateSelected];
//    [self.contentView addSubview:playButton];
//
//    JAVoiceWaveView *progressView = [[JAVoiceWaveView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH - 70, 36)];
//    _progressView = progressView;
//    progressView.maskColor = HEX_COLOR(0x54C7FC);
//    progressView.darkGrayColor = HEX_COLOR_ALPHA(0x54C7FC, 0.5);
//    [self.contentView addSubview:progressView];
    
    KILabel *title_label = [[KILabel alloc] init];
    _title_label = title_label;
    title_label.linkDetectionTypes = KILinkTypeOptionUserHandle;
    [title_label setAttributes:@{NSForegroundColorAttributeName : HEX_COLOR(0x54C7FC)} forLinkType:KILinkTypeUserHandle];
    @WeakObj(self);
    title_label.userHandleLinkTapHandler = ^(KILabel * _Nonnull label, NSString * _Nonnull string, NSRange range) {
        @StrongObj(self);
        if (self.atPersonBlock) {
            self.atPersonBlock(string, self.model.content.atUser);
        }
    };
    title_label.text = @"测试标题";
    title_label.textColor = HEX_COLOR(JA_Title);
    title_label.font = JA_REGULAR_FONT(JA_CommentDetail_commentFont);
    title_label.numberOfLines = 0;
    [self.contentView addSubview:title_label];
    
    // 时长
//    UILabel *voiceDurationLabel = [[UILabel alloc] init];
//    _voiceDurationLabel = voiceDurationLabel;
//    voiceDurationLabel.text = @"00:00";
//    voiceDurationLabel.textColor = HEX_COLOR(0x66CCFF);
//    voiceDurationLabel.font = JA_REGULAR_FONT(11);
//    voiceDurationLabel.textAlignment = NSTextAlignmentCenter;
//    [self.contentView addSubview:voiceDurationLabel];
    
    UIView *bottomView = [[UIView alloc] init];
    _bottomView = bottomView;
    bottomView.backgroundColor = HEX_COLOR(0xF5F5F5);
    [self.contentView addSubview:bottomView];
    
    UIButton *replyPlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _replyPlayButton = replyPlayButton;
    [replyPlayButton setImage:[UIImage imageNamed:@"branch_voice_smallPlay"] forState:UIControlStateNormal];
    [replyPlayButton setImage:[UIImage imageNamed:@"branch_voice_smallPlay"] forState:UIControlStateSelected];
    [bottomView addSubview:replyPlayButton];
    
    UILabel *replyTitleLabel = [[UILabel alloc] init];
    _replyTitleLabel = replyTitleLabel;
    replyTitleLabel.text = @"测试回复标题";
    replyTitleLabel.textColor = HEX_COLOR(0x4A4A4A);
    replyTitleLabel.font = JA_REGULAR_FONT(JA_CommentDetail_replyFont);
    [bottomView addSubview:replyTitleLabel];
    
    UIView *lineView = [[UIView alloc] init];
    _lineView = lineView;
    lineView.backgroundColor = HEX_COLOR(JA_Line);
    [self.contentView addSubview:lineView];
    
    _waveViewWidth = [JASampleHelper getViewWidthWithType:JADisplayTypeNotification];
    _allCount = [JASampleHelper getAllCountWithViewWidth:_waveViewWidth];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playNotification:) name:JAPlayNotification object:nil];
    [[JAVoicePlayerManager shareInstance] addDelegate:self];
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
    if (iPhone4 || iPhone5) {
        
        self.nameLabel.width = self.nameLabel.width > 90 ? 90 : self.nameLabel.width;
    }else{
        self.nameLabel.width = self.nameLabel.width > 120 ? 120 : self.nameLabel.width;
    }
    self.nameLabel.height = 20;
    self.nameLabel.x = self.iconImageView.right + 10;
    self.nameLabel.y = 13;
    
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
    
    [self.recordButton sizeToFit];
    self.recordButton.width = 40;
    self.recordButton.height = 20;
    self.recordButton.x = self.contentView.width - self.recordButton.width - 20;
    self.recordButton.y = 14;
    self.recordButton.layer.cornerRadius = self.recordButton.height * 0.5;
    
    self.animateView.width = 210;
    self.animateView.height = 35;
    self.animateView.x = self.timeLabel.x;
    self.animateView.y = self.timeLabel.bottom + 15;
    
//    self.playButton.width = 35;
//    self.playButton.height = self.playButton.width;
//    self.playButton.x = 15;
//    self.playButton.y = self.iconImageView.bottom + 15;
//
//    self.progressView.height = 36;
//    self.progressView.x = self.playButton.right + 5;
//    self.progressView.width = JA_SCREEN_WIDTH - self.progressView.x - 15;
//    self.progressView.centerY = self.playButton.centerY;
    
    self.title_label.x = self.nameLabel.x;
    self.title_label.width = JA_SCREEN_WIDTH - self.title_label.x - 15;
    [self.title_label sizeToFit];
    self.title_label.width = JA_SCREEN_WIDTH - self.title_label.x - 15;
    self.title_label.y = self.model.content.audioUrl.length ? self.animateView.bottom + 9 : self.iconImageView.bottom + 15;
    
//    self.voiceDurationLabel.width = 35;
//    self.voiceDurationLabel.height = 18;
//    self.voiceDurationLabel.y = self.title_label.y;
//    self.voiceDurationLabel.centerX = self.playButton.centerX;
    
    self.bottomView.x = self.animateView.x;
    self.bottomView.y = self.title_label.bottom + 10;
    self.bottomView.width = JA_SCREEN_WIDTH - self.animateView.x - 15;
    self.bottomView.height = 30;
    self.bottomView.layer.cornerRadius = 5;
    self.bottomView.layer.masksToBounds = YES;
    
    self.replyPlayButton.width = 20;
    self.replyPlayButton.height = self.replyPlayButton.width;
    self.replyPlayButton.x = 8;
    self.replyPlayButton.y = 5;
    
    [self.replyTitleLabel sizeToFit];
    self.replyTitleLabel.x = self.replyPlayButton.right + 5;
    self.replyTitleLabel.width = self.bottomView.width - self.replyTitleLabel.x;
    self.replyTitleLabel.centerY = self.replyPlayButton.centerY;
    
    self.lineView.width = self.contentView.width;
    self.lineView.height = 1;
    self.lineView.y = self.contentView.height - 1;
}

- (void)setModel:(JANotiModel *)model
{
    _model = model;
    
    if (model.user.isAnonymous) {
//        self.nameLabel.text = @"匿名用户";
//        self.nameLabel.text = model.user.anonymousName;
        self.nameLabel.text = model.user.nick;  // 服务器返回这个匿名的名称了
        self.iconImageView.image = [UIImage imageNamed:@"anonymous_head"];
    }else{
        int h = 35;
        int w = h;
        NSString *url = [model.user.img ja_getFitImageStringWidth:w height:h];
        [self.iconImageView ja_setImageWithURLStr:url];
        
        self.nameLabel.text = model.user.nick;
        
    }

    self.timeLabel.text = [NSString distanceTimeWithBeforeTime:model.time.doubleValue];
    
    if ([model.operation isEqualToString:@"atuser"]) {
        self.operationLbel.text = model.msgContent;
    }else{
        self.operationLbel.text = @"回复了你";
    }
    
    if ([model.operation isEqualToString:@"atuser"]) {
        self.recordButton.hidden = YES;
    }else{
        self.recordButton.hidden = NO;
    }
    
    self.title_label.text = model.content.content;
    
    
    if ([model.operation isEqualToString:@"atuser"]) {
        self.bottomView.hidden = YES;
    }else{
        self.bottomView.hidden = NO;
        NSString *str = [model.content.type isEqualToString:@"reply"] ? @"我的回复：" : @"我的主帖：";
        
        NSString *titleStr = model.content.subjoin.subjoin.content.length ? model.content.subjoin.subjoin.content : model.content.subjoin.content;
        
        self.replyTitleLabel.text = [NSString stringWithFormat:@"%@%@",str,[titleStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    }
    
    
    if (model.readState) {  // 0 未读  1 已读
        self.unreadImageView.hidden = YES;
    }else{
        self.unreadImageView.hidden = NO;
    }
    
    self.animateView.time = [NSString getShowTime:model.content.time];
    [self.animateView setPlayLoadingViewHidden:YES];
    if ([self.model.content.type isEqualToString:@"reply"]) {  // 表示回复
        
        // 判断是否有音波图
        if (model.content.audioUrl.length) {  // 有
            
            self.animateView.hidden = NO;
            // 语音
            JAVoiceReplyModel *playreplyM = [JAVoicePlayerManager shareInstance].replyModel;
            if ([playreplyM.voiceReplyId isEqualToString:self.model.content.typeId]) {
                self.model.playReplyState = playreplyM.playState;
            } else {
                self.model.playReplyState = 0;
            }
            if (model.playReplyState == 1) {
                self.animateView.playButton.selected = YES;
            } else {
                self.animateView.playButton.selected = NO;
                
                if (model.playReplyState == 0) {
                    self.animateView.playButton.selected = NO;
                    [self.animateView resetVolumeAnimate];
                    [self resetVoiceTime:model.content.time];
                    
                } else if (model.playReplyState == 2) {
                    JAVoiceReplyModel *replyModel = [JAVoicePlayerManager shareInstance].replyModel;
                    if ([replyModel.voiceReplyId isEqualToString:self.model.content.typeId]) {
                        self.animateView.playButton.selected = NO;
                        [self.animateView beginVolumeAnimate:[JAVoicePlayerManager shareInstance].playProgress];
                        [self setCurrentVoiceTime];
                    }
                } else if (model.playReplyState == 3) {
                    [self.animateView setPlayLoadingViewHidden:NO];
                }
            }
            
        }else{    // 无
            
            self.animateView.hidden = YES;
        }
        
    }else{
        // 语音
        // 判断是否有音波图
        if (model.content.audioUrl.length) {  // 有
            self.animateView.hidden = NO;

            // 设置波形图颜色
//            int type = [model.content.typeId integerValue] % 8;
//            NSDictionary *colorDic = [JAAPPManager app_waveViewColorWithType:type];
//            if (colorDic) {
//                unsigned long wave_color = strtoul([colorDic[@"reply_wave_color"] UTF8String],0,0);
//                self.animateView.backgroundColor = HEX_COLOR(wave_color);
//            }
            
            JAVoiceCommentModel *playcommentM = [JAVoicePlayerManager shareInstance].commentModel;
            if ([playcommentM.voiceCommendId isEqualToString:self.model.content.typeId]) {
                self.model.playCommentState = playcommentM.playState;
            } else {
                self.model.playCommentState = 0;
            }
            if (model.playCommentState == 1) {
                self.animateView.playButton.selected = YES;
            } else {
                self.animateView.playButton.selected = NO;
                
                if (model.playCommentState == 0) {
                    self.animateView.playButton.selected = NO;
                    [self.animateView resetVolumeAnimate];
                    [self resetVoiceTime:model.content.time];
                    
                } else if (model.playCommentState == 2) {
                    JAVoiceCommentModel *commentModel = [JAVoicePlayerManager shareInstance].commentModel;
                    if ([commentModel.voiceCommendId isEqualToString:self.model.content.typeId]) {
                        self.animateView.playButton.selected = NO;
                        [self.animateView beginVolumeAnimate:[JAVoicePlayerManager shareInstance].playProgress];
                        [self setCurrentVoiceTime];
                    }
                } else if (model.playCommentState == 3) {
                    [self.animateView setPlayLoadingViewHidden:NO];
                }
            }
            
        }else{
            
            self.animateView.hidden = YES;
        }
    }
    
}

#pragma mark - 重置时间
- (void)resetVoiceTime:(NSString *)time {

    self.animateView.time = [NSString getShowTime:time];
}
// 倒计时
- (void)setCurrentVoiceTime {
     if ([self.model.content.type isEqualToString:@"reply"]) {  // 表示回复
         JAVoiceReplyModel *replyModel = [JAVoicePlayerManager shareInstance].replyModel;
         if ([replyModel.voiceReplyId isEqualToString:self.model.content.typeId]) {
             NSTimeInterval curDuration = [NSString getSeconds:replyModel.time] - [JAVoicePlayerManager shareInstance].player.progress;
             if (curDuration > 0) {
                 NSString *time = [NSString stringWithFormat:@"%02d:%02d",(int)curDuration/60,(int)curDuration%60];
                 self.animateView.time = [NSString getShowTime:time];
             }
        }
    }else{
        JAVoiceCommentModel *commentModel = [JAVoicePlayerManager shareInstance].commentModel;
        if ([commentModel.voiceCommendId isEqualToString:self.model.content.typeId]) {
            NSTimeInterval curDuration = [NSString getSeconds:commentModel.time] - [JAVoicePlayerManager shareInstance].player.progress;
            if (curDuration > 0) {
                NSString *time = [NSString stringWithFormat:@"%02d:%02d",(int)curDuration/60,(int)curDuration%60];
                self.animateView.time = [NSString getShowTime:time];
            }
        }
    }
    
}

- (void)jumpPersonCenterVC
{
    if (self.jumpPersonalCenterBlock) {
        self.jumpPersonalCenterBlock(self);
    }
}

- (void)jumpRecordVC
{
    if (self.jumpRecordBlock) {
        self.jumpRecordBlock(self);
    }
}

- (void)playCommentAndReply
{
//    btn.selected = !btn.selected;
    
    if (self.playCommentOrReplyBlock) {
        self.playCommentOrReplyBlock(self);
    }
}

#pragma mark - 收到通知
- (void)playNotification:(NSNotification *)noti {
    [self.animateView setPlayLoadingViewHidden:YES];

    if ([self.model.content.type isEqualToString:@"reply"]) {  // 表示回复
        
        JAVoiceReplyModel *replyM = [JAVoicePlayerManager shareInstance].replyModel;
 
        if ([replyM.voiceReplyId isEqualToString:self.model.content.typeId]) {
            self.model.playReplyState = replyM.playState;
        } else {
            self.model.playReplyState = 0;
        }
        
        // 语音
        if (self.model.playReplyState == 1) {
            self.animateView.playButton.selected = YES;
        } else {
            self.animateView.playButton.selected = NO;
            
            
            if (self.model.playReplyState == 0) {
                [self resetVoiceTime:self.model.content.time];
                [self.animateView resetVolumeAnimate];
            } else if (self.model.playReplyState == 2) {
//                 [self setCurrentVoiceTime];
            } else if (self.model.playReplyState == 3) {
                [self.animateView setPlayLoadingViewHidden:NO];
            }
        }
    }else{
        JAVoiceCommentModel *commentM = [JAVoicePlayerManager shareInstance].commentModel;

        if ([commentM.voiceCommendId isEqualToString:self.model.content.typeId]) {
            self.model.playCommentState = commentM.playState;
        } else {
            self.model.playCommentState = 0;
        }
        
        // 语音
        if (self.model.playCommentState == 1) {
            self.animateView.playButton.selected = YES;
        } else {
            self.animateView.playButton.selected = NO;
            if (self.model.playCommentState == 0) {
                [self resetVoiceTime:self.model.content.time];
                [self.animateView resetVolumeAnimate];
            } else if (self.model.playCommentState == 2) {
//                 [self setCurrentVoiceTime];
            } else if (self.model.playCommentState == 3) {
                [self.animateView setPlayLoadingViewHidden:NO];
            }
        }
    }  
}

#pragma mark - JAPlayerDelegate
- (void)audioPlayerDidCurrentTime:(NSTimeInterval)time duration:(NSTimeInterval)duration {

    if ([self.model.content.type isEqualToString:@"reply"]) {  // 表示回复
        JAVoiceReplyModel *replyModel = [JAVoicePlayerManager shareInstance].replyModel;
        if ([replyModel.voiceReplyId isEqualToString:self.model.content.typeId] && replyModel.playState == 1) {
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
        
    }else{
        
        JAVoiceCommentModel *commentM = [JAVoicePlayerManager shareInstance].commentModel;
        if ([commentM.voiceCommendId isEqualToString:self.model.content.typeId] && commentM.playState == 1) {
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
    
}

@end
