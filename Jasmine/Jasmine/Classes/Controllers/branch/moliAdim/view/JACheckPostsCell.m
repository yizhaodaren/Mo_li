//
//  JACheckPostsCell.m
//  Jasmine
//
//  Created by moli-2017 on 2017/9/25.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JACheckPostsCell.h"
#import "JAPlayWaveView.h"
#import "JANewVoiceWaveView.h"
#import "JAPaddingLabel.h"
#import "JAVoicePersonApi.h"
#import "JAVoiceCommonApi.h"
#import "JASampleHelper.h"
#import "JAVoicePlayerManager.h"

@interface JACheckPostsCell ()<JAPlayerDelegate>

@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UILabel *nicknameLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *locationLabel;

//@property (nonatomic, strong) UIButton *reportButton;

@property (nonatomic, strong) JAPaddingLabel *contentLabel;
//@property (nonatomic, strong) JAPaddingLabel *channelLabel;

@property (nonatomic, strong) UIView *onePic_LabelView;
@property (nonatomic, strong) UIImageView *pic_labelView_ImageView;
@property (nonatomic, strong) JAPaddingLabel *pic_labelView_Label;

@property (nonatomic, strong) UIView *picView;
@property (nonatomic, strong) UIImageView *picView_ImageView1;
@property (nonatomic, strong) UIImageView *picView_ImageView2;
@property (nonatomic, strong) UIImageView *picView_ImageView3;

@property (nonatomic, strong) UIButton *agreeButton;
@property (nonatomic, strong) UIButton *commentButton;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UILabel *voiceTimeLabel;

@property (nonatomic, strong) UIImageView *voiceWaveViewBG; // 波形图背景

@property (nonatomic, strong) UIView *lineView;

//@property (nonatomic, strong) UIImageView *locationImageView;
//@property (nonatomic, strong) JAPlayWaveView *playWaveView;

@property (nonatomic, assign) BOOL lastAgreeState;// 0未点赞1已赞

@property (nonatomic, assign) int allCount;

@property (nonatomic, assign) CGFloat waveViewWidth;
@end

@implementation JACheckPostsCell


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[JAVoicePlayerManager shareInstance] removeDelegate:self];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = HEX_COLOR(JA_Background);
        
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
        
        UILabel *timeLabel = [UILabel new];
        timeLabel.text = @" ";
        timeLabel.textColor = HEX_COLOR(0xC6C6C6);
        timeLabel.font = JA_REGULAR_FONT(12);
        [self addSubview:timeLabel];
        self.timeLabel = timeLabel;
        
        UILabel *locationLabel = [UILabel new];
        locationLabel.textColor = HEX_COLOR(0xC6C6C6);
        locationLabel.font = JA_REGULAR_FONT(12);
        [self addSubview:locationLabel];
        locationLabel.text = @"火星";
        self.locationLabel = locationLabel;
        
//        UIButton *reportButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [reportButton setImage:[UIImage imageNamed:@"detail_right_report"] forState:UIControlStateNormal];
//        [reportButton addTarget:self action:@selector(reportAction) forControlEvents:UIControlEventTouchUpInside];
//        reportButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
//        [self addSubview:reportButton];
//        self.reportButton = reportButton;
        
        self.voiceTimeLabel = [[UILabel alloc] init];
        self.voiceTimeLabel.textColor = HEX_COLOR(0xC6C6C6);
        self.voiceTimeLabel.font = JA_MEDIUM_FONT(11);
        self.voiceTimeLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.voiceTimeLabel];
        
        UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [playButton setImage:[UIImage imageNamed:@"voice_play_btn"] forState:UIControlStateNormal];
        [playButton setImage:[UIImage imageNamed:@"voice_play_btn"] forState:UIControlStateHighlighted];
        [playButton setImage:[UIImage imageNamed:@"voice_pause_btn"] forState:UIControlStateSelected];
        [playButton setImage:[UIImage imageNamed:@"voice_pause_btn"] forState:UIControlStateSelected|UIControlStateHighlighted];
        [playButton addTarget:self action:@selector(playVoice) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:playButton];
        self.playButton = playButton;
        
        UIButton *agreeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [agreeButton setImage:[UIImage imageNamed:@"voice_agree_nor"] forState:UIControlStateNormal];
        [agreeButton setImage:[UIImage imageNamed:@"voice_agree_nor"] forState:UIControlStateHighlighted];
        [agreeButton setImage:[UIImage imageNamed:@"voice_agree_sel"] forState:UIControlStateSelected];
        [agreeButton setImage:[UIImage imageNamed:@"voice_agree_sel"] forState:UIControlStateSelected|UIControlStateHighlighted];
        [agreeButton setTitle:@"喜欢" forState:UIControlStateNormal];
        [agreeButton setTitleColor:HEX_COLOR(JA_BlackSubTitle) forState:UIControlStateNormal];
        agreeButton.titleLabel.font = JA_REGULAR_FONT(11);
        [agreeButton addTarget:self action:@selector(agreeAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:agreeButton];
        self.agreeButton = agreeButton;
        
        UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [commentButton setImage:[UIImage imageNamed:@"voice_reply"] forState:UIControlStateNormal];
        [commentButton addTarget:self action:@selector(commentAction) forControlEvents:UIControlEventTouchUpInside];
        [commentButton setTitle:@"回复" forState:UIControlStateNormal];
        [commentButton setTitleColor:HEX_COLOR(JA_BlackSubTitle) forState:UIControlStateNormal];
        commentButton.titleLabel.font = JA_REGULAR_FONT(11);
        [self addSubview:commentButton];
        self.commentButton = commentButton;
        
        // 纯文字布局
        JAPaddingLabel *describeLabel = [JAPaddingLabel new];
        describeLabel.text = @" ";
        describeLabel.backgroundColor = HEX_COLOR(0xF9F9F9);
        describeLabel.textColor = HEX_COLOR(JA_Title);
        describeLabel.textAlignment = NSTextAlignmentCenter;
        describeLabel.font = JA_REGULAR_FONT(16);
        describeLabel.numberOfLines = 3;
        describeLabel.edgeInsets = UIEdgeInsetsMake(5, 14, 5, 14);
        [self addSubview:describeLabel];
        self.contentLabel = describeLabel;
        
        // 一张图片布局
        self.onePic_LabelView = [[UIView alloc] init];
        self.onePic_LabelView.backgroundColor = HEX_COLOR(0xF9F9F9);
        [self.contentView addSubview:self.onePic_LabelView];
        
        self.pic_labelView_ImageView = [[UIImageView alloc] init];
        self.pic_labelView_ImageView.userInteractionEnabled = YES;
        self.pic_labelView_ImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.pic_labelView_ImageView.clipsToBounds = YES;
        self.pic_labelView_ImageView.backgroundColor = [UIColor blueColor];
        [self.onePic_LabelView addSubview:self.pic_labelView_ImageView];
        
        self.pic_labelView_Label = [[JAPaddingLabel alloc] init];
        self.pic_labelView_Label.textColor = HEX_COLOR(0x4A4A4A);
        self.pic_labelView_Label.font = JA_REGULAR_FONT(WIDTH_ADAPTER(16));
        self.pic_labelView_Label.edgeInsets = UIEdgeInsetsMake(WIDTH_ADAPTER(14), WIDTH_ADAPTER(14), WIDTH_ADAPTER(14), WIDTH_ADAPTER(14));
        self.pic_labelView_Label.numberOfLines = 3;
        [self.onePic_LabelView addSubview:self.pic_labelView_Label];
        
        // 多张图片
        self.picView = [[UIView alloc] init];
        self.picView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.picView];
        
        self.picView_ImageView1 = [[UIImageView alloc] init];
        self.picView_ImageView1.contentMode = UIViewContentModeScaleAspectFill;
        self.picView_ImageView1.clipsToBounds = YES;
        [self.picView addSubview:self.picView_ImageView1];
        
        self.picView_ImageView2 = [[UIImageView alloc] init];
        self.picView_ImageView2.contentMode = UIViewContentModeScaleAspectFill;
        self.picView_ImageView2.clipsToBounds = YES;
        [self.picView addSubview:self.picView_ImageView2];
        
        self.picView_ImageView3 = [[UIImageView alloc] init];
        self.picView_ImageView3.contentMode = UIViewContentModeScaleAspectFill;
        self.picView_ImageView3.clipsToBounds = YES;
        [self.picView addSubview:self.picView_ImageView3];
        
//        JAVoiceWaveView *voiceWaveView = [[JAVoiceWaveView alloc] initWithFrame:CGRectMake(0, 0, 0, 36)];
//        voiceWaveView.maskColor = HEX_COLOR(0x54C7FC);
//        voiceWaveView.darkGrayColor = HEX_COLOR_ALPHA(0x54C7FC, 0.5);
//        [self addSubview:voiceWaveView];
//        self.voiceWaveView = voiceWaveView;
//        self.voiceWaveView.sliderIV.x = -3;
        
        UIImageView *voiceWaveViewBG = [[UIImageView alloc] initWithFrame:CGRectMake(12, 0, JA_SCREEN_WIDTH-12*2, 50)];
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:voiceWaveViewBG.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(5, 5)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = voiceWaveViewBG.bounds;
        maskLayer.path = maskPath.CGPath;
        voiceWaveViewBG.layer.mask = maskLayer;
        voiceWaveViewBG.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:voiceWaveViewBG];
        self.voiceWaveViewBG = voiceWaveViewBG;
        
        JANewVoiceWaveView *voiceWaveView = [[JANewVoiceWaveView alloc] initWithFrame:CGRectMake(0, 0, voiceWaveViewBG.width, 50)];
        [self.voiceWaveViewBG addSubview:voiceWaveView];
        self.voiceWaveView.maskColor = HEX_COLOR(0xffffff);
        self.voiceWaveView.darkGrayColor = HEX_COLOR_ALPHA(0xffffff, 0.5);
        self.voiceWaveView = voiceWaveView;
        
        self.lineView = [[UIView alloc] init];
        self.lineView.backgroundColor = HEX_COLOR(JA_Line);
        [self.contentView addSubview:self.lineView];
        
        _waveViewWidth = [JASampleHelper getViewWidthWithType:JADisplayTypeCheckVoice];
        _allCount = [JASampleHelper getAllCountWithViewWidth:_waveViewWidth];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playNotification:) name:JAPlayNotification object:nil];
        [[JAVoicePlayerManager shareInstance] addDelegate:self];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.headImageView.width = 35;
    self.headImageView.height = self.headImageView.width;
    self.headImageView.x = 15;
    self.headImageView.y = 10;
    self.headImageView.layer.cornerRadius = self.headImageView.height * 0.5;
    self.headImageView.layer.masksToBounds = YES;
    
    [self.nicknameLabel sizeToFit];
    self.nicknameLabel.height = 18;
    self.nicknameLabel.x = self.headImageView.right + 12;
    self.nicknameLabel.y = 12;
    
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
    
    self.playButton.width = 60;
    self.playButton.height = self.playButton.width;
    self.playButton.centerX = self.width * 0.5;
    self.playButton.y = self.timeLabel.bottom + 11;
    
    self.voiceTimeLabel.width = 50;
    self.voiceTimeLabel.height = 11;
    self.voiceTimeLabel.centerX = JA_SCREEN_WIDTH * 0.5;
    self.voiceTimeLabel.y = self.playButton.bottom + 5;
    
    self.agreeButton.width = (self.width - 60) * 0.5;
    self.agreeButton.height = 42;
    self.agreeButton.y = self.timeLabel.bottom + 29;
    [self.agreeButton setButtonImageTitleStyle:ButtonImageTitleStyleTop padding:2];
    
    self.commentButton.width = self.agreeButton.width;
    self.commentButton.height = self.agreeButton.height;
    self.commentButton.y = self.agreeButton.y;
    self.commentButton.x = self.playButton.right;
    [self.commentButton setButtonImageTitleStyle:ButtonImageTitleStyleTop padding:2];
    
    self.contentLabel.x = 38;
    self.contentLabel.width = self.width - 2 * self.contentLabel.x;
    [self.contentLabel sizeToFit];
    self.contentLabel.width = self.width - 2 * self.contentLabel.x;
    self.contentLabel.y = self.playButton.bottom + 30;
    self.contentLabel.layer.cornerRadius = 5;
    self.contentLabel.layer.masksToBounds = YES;
    
    self.onePic_LabelView.width = JA_SCREEN_WIDTH - 2 * WIDTH_ADAPTER(12);
    self.onePic_LabelView.height = WIDTH_ADAPTER(85);
    self.onePic_LabelView.x = WIDTH_ADAPTER(12);
    self.onePic_LabelView.y = self.playButton.bottom + 30;
    
    self.pic_labelView_ImageView.width = WIDTH_ADAPTER(113);
    self.pic_labelView_ImageView.height = self.onePic_LabelView.height;
    
    self.pic_labelView_Label.width = self.onePic_LabelView.width - self.pic_labelView_ImageView.width;
    self.pic_labelView_Label.height = self.onePic_LabelView.height;
    self.pic_labelView_Label.x = self.pic_labelView_ImageView.right;

    self.picView.width = self.onePic_LabelView.width;
    self.picView.height = self.onePic_LabelView.height;
    self.picView.x = self.onePic_LabelView.x;
    self.picView.y = self.contentLabel.bottom + 15;
    
    self.picView_ImageView1.width = WIDTH_ADAPTER(113);
    self.picView_ImageView1.height = self.picView.height;
    
    self.picView_ImageView2.width = self.picView_ImageView1.width;
    self.picView_ImageView2.height = self.picView.height;
    self.picView_ImageView2.x = self.picView_ImageView1.right + WIDTH_ADAPTER(6);
    
    self.picView_ImageView3.width = self.picView_ImageView1.width;
    self.picView_ImageView3.height = self.picView.height;
    self.picView_ImageView3.x = self.picView_ImageView2.right + WIDTH_ADAPTER(6);
    
    self.voiceWaveViewBG.width = JA_SCREEN_WIDTH - 2 * 12;
    self.voiceWaveViewBG.height = 50;
    self.voiceWaveViewBG.x = 12;
    self.voiceWaveViewBG.y = self.contentLabel.bottom + 15;
    
    self.voiceWaveView.width = self.voiceWaveViewBG.width;
    self.voiceWaveView.height = self.voiceWaveViewBG.height;
    
    self.lineView.width = JA_SCREEN_WIDTH;
    self.lineView.height = 1;
    NSMutableArray *images = [[self.data.image componentsSeparatedByString:@","] mutableCopy];
    [images removeObject:@""];
    if (images.count > 1) {
        self.lineView.y = self.picView.bottom + 10;
    }else if (images.count > 0){
        self.lineView.y = self.onePic_LabelView.bottom + 10;
    }else{
        self.lineView.y = self.voiceWaveViewBG.bottom + 10;
    }
}

- (void)setData:(JAVoiceModel *)data {
    _data = data;
    if (data) {
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
        self.locationLabel.text = data.city.length?data.city:@"火星";
        self.timeLabel.text = [NSString distanceTimeWithBeforeTime:[data.createTime doubleValue]];
        [self.nicknameLabel sizeToFit];
        [self.timeLabel sizeToFit];
        
        self.voiceTimeLabel.text = [NSString getShowTime:data.time];
        
        NSString *agreeStr = [NSString stringWithFormat:@"%@",data.agreeCount];
        [self.agreeButton setTitle:agreeStr forState:UIControlStateNormal];
        
        NSString *commentStr = [NSString stringWithFormat:@"%@",data.commentCount?:@"0"];
        [self.commentButton setTitle:commentStr forState:UIControlStateNormal];
        
        NSMutableArray *images = [[self.data.image componentsSeparatedByString:@","] mutableCopy];
        [images removeObject:@""];
        if (images.count > 1) {
            self.contentLabel.hidden = NO;
            self.onePic_LabelView.hidden = YES;
            self.picView.hidden = NO;
            self.voiceWaveViewBG.hidden = YES;
            [self.picView_ImageView1 ja_setImageWithURLStr:images.firstObject];
            if (images.count > 2) {
                [self.picView_ImageView2 ja_setImageWithURLStr:images[1]];
                [self.picView_ImageView3 ja_setImageWithURLStr:images.lastObject];
            }else{
                [self.picView_ImageView2 ja_setImageWithURLStr:images.lastObject];
            }
            self.contentLabel.text = data.content;
        }else if (images.count > 0){
            self.onePic_LabelView.hidden = NO;
            self.contentLabel.hidden = YES;
            self.picView.hidden = YES;
            self.voiceWaveViewBG.hidden = YES;
            [self.pic_labelView_ImageView ja_setImageWithURLStr:images.firstObject];
            self.pic_labelView_Label.text = data.content;
        }else{
            self.contentLabel.hidden = NO;
            self.onePic_LabelView.hidden = YES;
            self.picView.hidden = YES;
            self.voiceWaveViewBG.hidden = NO;
            self.contentLabel.text = data.content;
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
        
        // 语音
        JAVoiceModel *playvoiceModel = [JAVoicePlayerManager shareInstance].voiceModel;
        if ([playvoiceModel.voiceId isEqualToString:self.data.voiceId]) {
            self.data.playState = playvoiceModel.playState;
        } else {
            self.data.playState = 0;
        }
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
            } else {
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
            }
        }
        [self.voiceWaveView setPeakLevelQueue:data.currentPeakLevelQueue];
    }
    
    [self layoutIfNeeded];
    [self setNeedsLayout];
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

- (void)reportAction
{
}

- (void)commentAction {   // 备用
    if (self.commentBlock) {
        self.commentBlock(self);
    }
}

- (void)agreeAction:(UIButton *)sender {

}

#pragma mark - 网络请求
- (void)playNotification:(NSNotification *)noti {
    //    NSDictionary *dic = [noti object];
    JAVoiceModel *voiceModel = [JAVoicePlayerManager shareInstance].voiceModel;
    if ([voiceModel.voiceId isEqualToString:self.data.voiceId]) {
        //        [JAVoicePlayerManager shareInstance].delegate = self;
        self.data.playState = voiceModel.playState;
        
    } else {
        self.data.playState = 0;
    }
    
    
    // 语音
    if (self.data.playState == 1) {
        self.playButton.selected = YES;
    } else {
        self.playButton.selected = NO;
        
        
        if (self.data.playState == 0) {
            // 显示半个游标
            self.voiceWaveView.sliderIV.x = -3;
            
            [self.data.currentPeakLevelQueue removeAllObjects];
            if (!self.data.displayPeakLevelQueue.count) {
                return;
            }
            for (int i=0; i<_allCount; i++) {
                [self.data.currentPeakLevelQueue addObject:self.data.displayPeakLevelQueue[i]];
            }
            [self.voiceWaveView setPeakLevelQueue:self.data.currentPeakLevelQueue];
            [self resetVoiceTime:self.data.time];
        }else{
            [self setCurrentVoiceTime];
        }
    }
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

#pragma mark - 时间
- (void)resetVoiceTime:(NSString *)time {
    NSArray *timeArray = [time componentsSeparatedByString:@":"];
    if (timeArray.count == 2) {
        int minute = [timeArray[0] intValue];
        int second = [timeArray[1] intValue];
        NSString *timeStr = [NSString stringWithFormat:@"%02d:%02d",minute,second];
        self.voiceTimeLabel.text = [NSString getShowTime:timeStr];
    }
}

// 倒计时
- (void)setCurrentVoiceTime {
    JAVoiceModel *voiceModel = [JAVoicePlayerManager shareInstance].voiceModel;
    if ([voiceModel.voiceId isEqualToString:self.data.voiceId]) {
        NSTimeInterval curDuration = [NSString getSeconds:voiceModel.time] - [JAVoicePlayerManager shareInstance].player.progress;
        if (curDuration > 0) {
            NSString *timeStr = [NSString stringWithFormat:@"%02d:%02d",(int)curDuration/60,(int)curDuration%60];
            self.voiceTimeLabel.text = [NSString getShowTime:timeStr];
        }
    }
}
@end
