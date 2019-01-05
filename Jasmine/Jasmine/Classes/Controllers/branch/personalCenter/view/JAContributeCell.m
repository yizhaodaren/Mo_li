//
//  JAContributeCell.m
//  Jasmine
//
//  Created by moli-2017 on 2018/4/10.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAContributeCell.h"
#import "JAPlayAnimateView.h"
#import "JANewPlayTool.h"

@interface JAContributeCell ()

@property (nonatomic, weak) UIView *backView;
@property (nonatomic, weak) UILabel *contentLabel;
@property (nonatomic, weak) JAPlayAnimateView *animateView;   // 新的波形图
@property (nonatomic, weak) UILabel *timeLabel;         // 时间
@property (nonatomic, weak) UIView *lineView;

@property (nonatomic, assign) CGFloat currentTime;
@end

@implementation JAContributeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupContributeCell];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = HEX_COLOR(0xf9f9f9);
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playStatus_refreshUI) name:@"STKAudioPlayer_status" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playProcess_refreshUI) name:@"STKAudioPlayer_process" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinish_refreshUI) name:@"STKAudioPlayer_finish" object:nil];
    }
    return self;
}
#pragma mark - 数据模型
- (void)setStoryModel:(JANewVoiceModel *)storyModel
{
    _storyModel = storyModel;
    self.contentLabel.text = storyModel.content;
    self.timeLabel.text = [NSString timeToString:storyModel.createTime];
    
    // 设置波形图颜色
//    int type = [storyModel.storyId integerValue] % 8;
//    NSDictionary *colorDic = [JAAPPManager app_waveViewColorWithType:type];
//    if (colorDic) {
//        unsigned long wave_color = strtoul([colorDic[@"reply_wave_color"] UTF8String],0,0);
//        self.animateView.backgroundColor = HEX_COLOR(wave_color);
//    }
    
    // 波形图
    if ([[JANewPlayTool shareNewPlayTool].currentMusic.storyId isEqualToString:self.storyModel.storyId]) {
        if ([JANewPlayTool shareNewPlayTool].totalDuration > 0) {
            
            CGFloat p = [JANewPlayTool shareNewPlayTool].currentDuration / [JANewPlayTool shareNewPlayTool].totalDuration;
            [self.animateView beginVolumeAnimate:p];
            NSTimeInterval curDuration = [NSString getSeconds:self.storyModel.time] - [JANewPlayTool shareNewPlayTool].currentDuration;
            if (curDuration > 0) {
                self.animateView.time = [NSString getShowTime:[NSString stringWithFormat:@"%02d:%02d",(int)curDuration/60,(int)curDuration%60]];
            }else{
                [self.animateView resetVolumeAnimate];
                self.animateView.time = [NSString getShowTime:self.storyModel.time];
            }
        }else{
            [self.animateView resetVolumeAnimate];
            self.animateView.time = [NSString getShowTime:self.storyModel.time];
        }
        
        NSInteger status = [JANewPlayTool shareNewPlayTool].playType;
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
        self.animateView.time = [NSString getShowTime:self.storyModel.time];
        self.animateView.playButton.selected = NO;
        [self.animateView setPlayLoadingViewHidden:YES];
    }
}


#pragma mark - 波形图通知
- (void)playStatus_refreshUI   // 状态变化
{
    // 获取播放器的状态
    if ([[JANewPlayTool shareNewPlayTool].currentMusic.storyId isEqualToString:self.storyModel.storyId]) {
        NSInteger status = [JANewPlayTool shareNewPlayTool].playType;
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

- (void)playProcess_refreshUI  // 进度
{
    if ([JANewPlayTool shareNewPlayTool].totalDuration <= 0) {
        return;
    }
    if ([[JANewPlayTool shareNewPlayTool].currentMusic.storyId isEqualToString:self.storyModel.storyId]) {
        CGFloat p = [JANewPlayTool shareNewPlayTool].currentDuration / [JANewPlayTool shareNewPlayTool].totalDuration;
        
        [self.animateView beginVolumeAnimate:p];
        NSTimeInterval curDuration = [NSString getSeconds:self.storyModel.time] - [JANewPlayTool shareNewPlayTool].currentDuration;
        if (curDuration > 0) {
            self.animateView.time = [NSString getShowTime:[NSString stringWithFormat:@"%02d:%02d",(int)curDuration/60,(int)curDuration%60]];
        }
    }else{
        [self.animateView resetVolumeAnimate];
        self.animateView.time = [NSString getShowTime:self.storyModel.time];
    }
    
}

- (void)playFinish_refreshUI   // 完成
{
    // 重置波形图
    [self.animateView resetVolumeAnimate];
    self.animateView.playButton.selected = NO;
    [self.animateView setPlayLoadingViewHidden:YES];
    self.animateView.time = [NSString getShowTime:self.storyModel.time];
}

#pragma mark - UI
- (void)setupContributeCell
{
    UIView *backView = [[UIView alloc] init];
    _backView = backView;
    backView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:backView];
    
    // 标题
    UILabel *contentLabel = [[UILabel alloc] init];
    _contentLabel = contentLabel;
    contentLabel.text = @" ";
    contentLabel.textColor = HEX_COLOR(0x525252);
    contentLabel.font = JA_MEDIUM_FONT(15);
    contentLabel.numberOfLines = 0;
    [backView addSubview:contentLabel];
    
    JAPlayAnimateView *animateView = [[JAPlayAnimateView alloc] initWithColor:HEX_COLOR(0x6BD379) frame:CGRectZero];
    _animateView = animateView;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playVoice)];
    [self.animateView addGestureRecognizer:tap];
    self.animateView.backgroundColor = HEX_COLOR(0x6BD379);
    [backView addSubview:animateView];
    
    // 时间
    UILabel *timeLabel = [[UILabel alloc] init];
    _timeLabel = timeLabel;
    timeLabel.text = @" ";
    timeLabel.textColor = HEX_COLOR(JA_BlackSubTitle);
    timeLabel.font = JA_REGULAR_FONT(11);
    [backView addSubview:timeLabel];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.backView.width = self.contentView.width - 30;
    self.backView.height = self.contentView.height - 15;
    self.backView.x = 15;
    self.backView.y = 15;
    self.backView.layer.cornerRadius = 5;
    self.backView.layer.masksToBounds = YES;
    
    self.contentLabel.x = 15;
    self.contentLabel.width = self.backView.width - 30;
    [self.contentLabel sizeToFit];
    self.contentLabel.width = self.backView.width - 30;
    self.contentLabel.y = 15;
    
    self.animateView.width = 210;
    self.animateView.height = 35;
    self.animateView.x = self.contentLabel.x;
    self.animateView.y = self.contentLabel.bottom + 15;
    
    [self.timeLabel sizeToFit];
    self.timeLabel.height = 18;
    self.timeLabel.x = self.contentLabel.x;
    self.timeLabel.y = self.animateView.bottom + 10;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)playVoice
{
    if (self.playVoiceBlock) {
        self.playVoiceBlock(self);
    }
}


@end
