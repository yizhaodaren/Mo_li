//
//  JAVoiceReplyCell.m
//  Jasmine
//
//  Created by moli-2017 on 2017/8/30.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAVoiceInviteCell.h"
#import "JAVoiceWaveView.h"
#import "JASampleHelper.h"
#import "KILabel.h"
#import "JAPlayLoadingView.h"
#import "JAVoicePlayerManager.h"

@interface JAVoiceInviteCell ()<JAPlayerDelegate>

@property (nonatomic, weak) UIImageView *iconImageView;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UILabel *timeLabel;
@property (nonatomic, weak) UILabel *operationLbel;
@property (nonatomic, weak) UIImageView *unreadImageView;
@property (nonatomic, weak) UIButton *recordButton;

@property (nonatomic, weak) UIButton *playButton;
@property (nonatomic, weak) JAVoiceWaveView *progressView;
@property (nonatomic, weak) KILabel *title_label;
@property (nonatomic, weak) UILabel *voiceDurationLabel;  // 音频时长

@property (nonatomic, weak) UIView *lineView;
@property (nonatomic, assign) int allCount;

@property (nonatomic, assign) CGFloat waveViewWidth;

// v2.5.5
@property (nonatomic, strong) JAPlayLoadingView *playLoadingView;

@end

@implementation JAVoiceInviteCell

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[JAVoicePlayerManager shareInstance] removeDelegate:self];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupVoiceInviteCell];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setupVoiceInviteCell
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
    operationLbel.text = @"邀请你回复帖子";
    operationLbel.textColor = HEX_COLOR(JA_BlackSubTitle);
    operationLbel.font = JA_REGULAR_FONT(JA_PersonalDetail_commentPersonalFont);
    [self.contentView addSubview:operationLbel];
    
    UIImageView *unreadImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"branch_noti_unread"]];
    _unreadImageView = unreadImageView;
    [self.contentView addSubview:unreadImageView];
    
//    UIButton *recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    _recordButton = recordButton;
//    [recordButton setImage:[UIImage imageNamed:@"branch_voice_reply"] forState:UIControlStateNormal];
//    [recordButton addTarget:self action:@selector(jumpRecordVC) forControlEvents:UIControlEventTouchUpInside];
//    [self.contentView addSubview:recordButton];
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
//    recordButton.layer.cornerRadius = 4;
    [self.contentView addSubview:recordButton];
    
    
    UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _playButton = playButton;
    [playButton addTarget:self action:@selector(playComment:) forControlEvents:UIControlEventTouchUpInside];
    [playButton setImage:[UIImage imageNamed:@"branch_voice_commentplay"] forState:UIControlStateNormal];
    [playButton setImage:[UIImage imageNamed:@"branch_voice_commentpause"] forState:UIControlStateSelected];
    [self.contentView addSubview:playButton];
    
    self.playLoadingView = [JAPlayLoadingView playLoadingViewWithType:1];
    self.playLoadingView.centerX = 35/2.0;
    self.playLoadingView.centerY = 35/2.0;
    [self.playButton addSubview:self.playLoadingView];
    
    JAVoiceWaveView *progressView = [[JAVoiceWaveView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH - 70, 36)];
    _progressView = progressView;
    progressView.maskColor = HEX_COLOR(0x54C7FC);
    progressView.darkGrayColor = HEX_COLOR_ALPHA(0x54C7FC, 0.5);
    [self.contentView addSubview:progressView];
    
    KILabel *title_label = [[KILabel alloc] init];
    _title_label = title_label;
    title_label.linkDetectionTypes = KILinkTypeOptionHashtag | KILinkTypeOptionUserHandle;
    [title_label setAttributes:@{NSForegroundColorAttributeName : HEX_COLOR(0x54C7FC)} forLinkType:KILinkTypeHashtag];
    [title_label setAttributes:@{NSForegroundColorAttributeName : HEX_COLOR(0x54C7FC)} forLinkType:KILinkTypeUserHandle];
    @WeakObj(self);
    title_label.hashtagLinkTapHandler = ^(KILabel * _Nonnull label, NSString * _Nonnull string, NSRange range) {
        @StrongObj(self);
        if (self.topicDetailBlock) {
            self.topicDetailBlock(string);
        }
    };
    title_label.userHandleLinkTapHandler = ^(KILabel * _Nonnull label, NSString * _Nonnull string, NSRange range) {
        @StrongObj(self);
        if (self.atPersonBlock) {
            self.atPersonBlock(string, self.model.content.atUser);
        }
    };
    title_label.text = @" ";
    title_label.textColor = HEX_COLOR(JA_Title);
    title_label.font = JA_REGULAR_FONT(JA_CommentDetail_commentFont);
    title_label.numberOfLines = 0;
    [self.contentView addSubview:title_label];
    
    // 时长
    UILabel *voiceDurationLabel = [[UILabel alloc] init];
    _voiceDurationLabel = voiceDurationLabel;
    voiceDurationLabel.text = @"0s";
    voiceDurationLabel.textColor = HEX_COLOR(0x66CCFF);
    voiceDurationLabel.font = JA_REGULAR_FONT(11);
    voiceDurationLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:voiceDurationLabel];
    
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
    
    self.nameLabel.x = self.iconImageView.right + 10;
    self.nameLabel.y = 13;
    self.nameLabel.height = 20;
    
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
    
//    [self.recordButton sizeToFit];
//    self.recordButton.x = self.contentView.width - self.recordButton.width - 20;
//    self.recordButton.y = 14;
    [self.recordButton sizeToFit];
    self.recordButton.width = 40;
    self.recordButton.height = 20;
    self.recordButton.x = self.contentView.width - self.recordButton.width - 20;
    self.recordButton.y = 14;
    self.recordButton.layer.cornerRadius = self.recordButton.height * 0.5;
    
    self.playButton.width = 35;
    self.playButton.height = self.playButton.width;
    self.playButton.x = 15;
    self.playButton.y = self.iconImageView.bottom + 15;
    
    self.progressView.height = 36;
    self.progressView.x = self.playButton.right + 5;
    self.progressView.width = JA_SCREEN_WIDTH - self.progressView.x - 15;
    self.progressView.centerY = self.playButton.centerY;
    
    self.title_label.x = self.progressView.x + 5;
    self.title_label.width = JA_SCREEN_WIDTH - self.title_label.x - 15;
    [self.title_label sizeToFit];
//    self.title_label.height = 17;
    self.title_label.width = JA_SCREEN_WIDTH - self.title_label.x - 15;
    self.title_label.y = self.model.content.audioUrl.length ? self.progressView.bottom + 9 : self.iconImageView.bottom + 15;
    
    self.voiceDurationLabel.width = 35;
    self.voiceDurationLabel.height = 18;
    self.voiceDurationLabel.y = self.title_label.y;
    self.voiceDurationLabel.centerX = self.playButton.centerX;
    
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
    
    self.title_label.text = model.content.content;
    
    if (model.readState) {  // 0 未读  1 已读
        self.unreadImageView.hidden = YES;
    }else{
        self.unreadImageView.hidden = NO;
    }
    
    if ([model.operation isEqualToString:@"atuser"]) {
        self.recordButton.hidden = YES;
    }else{
        self.recordButton.hidden = NO;
    }
    
    self.voiceDurationLabel.text = model.content.time;
    
    if (model.content.audioUrl.length) {
        self.progressView.hidden = NO;
        self.playButton.hidden = NO;
        // 设置波形图颜色
        int type = model.displayPeakLevelQueue.count%8;
        NSDictionary *colorDic = [JAAPPManager app_waveViewColorWithType:type];
        if (colorDic) {
            unsigned long vernier_color = strtoul([colorDic[@"vernier_color"] UTF8String],0,0);
            unsigned long wave_color = strtoul([colorDic[@"wave_color"] UTF8String],0,0);
            self.progressView.maskColor = HEX_COLOR(wave_color);
            self.progressView.darkGrayColor = HEX_COLOR_ALPHA(wave_color, 0.5);
            self.progressView.sliderIV.drawColor = HEX_COLOR(vernier_color);
        }
        
        // 语音
        JAVoiceModel *playvoiceModel = [JAVoicePlayerManager shareInstance].voiceModel;
        if ([playvoiceModel.voiceId isEqualToString:self.model.content.typeId]) {
            self.model.playState = playvoiceModel.playState;
        }else{
            self.model.playState = 0;
        }
        [self updateUIWithData:self.model];
    }else{
        self.progressView.hidden = YES;
        self.playButton.hidden = YES;
    }
}

#pragma mark - 重置时间
- (void)resetVoiceTime:(NSString *)time {
    NSArray *timeArray = [time componentsSeparatedByString:@":"];
    if (timeArray.count == 2) {
        int minute = [timeArray[0] intValue];
        int second = [timeArray[1] intValue];
        self.voiceDurationLabel.text = [NSString stringWithFormat:@"%02d:%02d",minute,second];
    }
}
// 倒计时
- (void)setCurrentVoiceTime {
    JAVoiceModel *voiceModel = [JAVoicePlayerManager shareInstance].voiceModel;
    if ([voiceModel.voiceId isEqualToString:self.model.content.typeId]) {
        NSTimeInterval curDuration = [NSString getSeconds:voiceModel.time] - [JAVoicePlayerManager shareInstance].player.progress;
        if (curDuration > 0) {
            self.voiceDurationLabel.text = [NSString stringWithFormat:@"%02d:%02d",(int)curDuration/60,(int)curDuration%60];
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

- (void)playComment:(UIButton *)btn
{
//    btn.selected = btn.selected;
    
    if (self.playCommentBlock) {
        self.playCommentBlock(self);
    }
}

- (void)updateUIWithData:(JANotiModel *)data {
    // 语音
    [self.playLoadingView setPlayLoadingViewHidden:YES];
    
    if (self.model.playState == 1) {
        self.playButton.selected = YES;
        
    } else {
        self.playButton.selected = NO;
        
        if (self.model.playState == 0) {
            // 显示半个游标
            self.progressView.sliderIV.x = -3;
            [self.model.currentPeakLevelQueue removeAllObjects];
            if (!self.model.displayPeakLevelQueue.count) {
                return;
            }
            for (int i=0; i<_allCount; i++) {
                [self.model.currentPeakLevelQueue addObject:self.model.displayPeakLevelQueue[i]];
            }
            [self.progressView setPeakLevelQueue:self.model.currentPeakLevelQueue];
            [self resetVoiceTime:self.model.content.time];
        } else if (self.model.playState == 2) {
            JAVoiceModel *voiceModel = [JAVoicePlayerManager shareInstance].voiceModel;
            if ([voiceModel.voiceId isEqualToString:self.model.content.typeId]) {
                CGFloat time = [JAVoicePlayerManager shareInstance].player.progress;
                NSInteger index = (NSInteger)(time * 10 + 1);
                CGFloat percent = (index * 4) / (_waveViewWidth);
                if (percent>=0.5) {
                    percent = 0.5;
                }
                // 移动滑动杆
                [self.progressView setSliderOffsetX:percent];
                
                int cutIndex = percent * self.model.currentPeakLevelQueue.count;
                [self.progressView setPeakLevelQueue:self.model.currentPeakLevelQueue cutIndex:cutIndex];
                
                [self setCurrentVoiceTime];
            }
        } else if (self.model.playState == 3) {
            [self.playLoadingView setPlayLoadingViewHidden:NO];
        }
    }
}

#pragma mark -
- (void)playNotification:(NSNotification *)noti {
    
    JAVoiceModel *voiceModel = [JAVoicePlayerManager shareInstance].voiceModel;
    if ([voiceModel.voiceId isEqualToString:self.model.content.typeId]) {
        self.model.playState = voiceModel.playState;
    }else{
        self.model.playState = 0;
    }
    [self updateUIWithData:self.model];
}

#pragma mark - JAPlayerDelegate
- (void)audioPlayerDidCurrentTime:(NSTimeInterval)time duration:(NSTimeInterval)duration {
    JAVoiceModel *voiceModel = [JAVoicePlayerManager shareInstance].voiceModel;
    if ([voiceModel.voiceId isEqualToString:self.model.content.typeId] && voiceModel.playState == 1) {
        [self setCurrentVoiceTime];
        
        NSInteger index = (NSInteger)(time * 10 + 1);
        CGFloat percent = (index * 4) / (_waveViewWidth);
        if (percent>=0.5) {
            percent = 0.5;
            index = index+_allCount/2; // 跳过半个波形的宽度
            if (index < self.model.displayPeakLevelQueue.count) {
                [self.model.currentPeakLevelQueue enqueue:self.model.displayPeakLevelQueue[index] maxCount:_allCount];
            }
        }
        // 移动滑动杆
        [self.progressView setSliderOffsetX:percent];
        
        int cutIndex = percent * self.model.currentPeakLevelQueue.count;
        [self.progressView setPeakLevelQueue:self.model.currentPeakLevelQueue cutIndex:cutIndex];
    }
}

@end


