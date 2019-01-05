//
//  JARecordInputView.m
//  Jasmine
//
//  Created by 刘宏亮 on 2017/12/13.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JARecordInputView.h"
#import "JAAlphaCircleView.h"
#import "SpectrumView.h"
#import "JAUnhighlightButton.h"
#import "JAPermissionHelper.h"
#import "JAPlayAnimateView.h"

#define kMinRecordSecond 2

@interface JARecordInputView ()<JAInputRecordManagerDelegate>
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UILabel *statusLabel;  // 状态label
@property (nonatomic, strong) SpectrumView *spectrumView2;  // 音波动画
@property (nonatomic, strong) UIImageView *recordImageView; // 录制
@property (nonatomic, strong) UILongPressGestureRecognizer *longP;
@property (nonatomic, strong) UILabel * speakLabel;  // 按住说
@property (nonatomic, strong) UILabel *recordSecondLabel;  // 最少需要录2秒哦

@property (nonatomic, strong) UILabel *xfLabel;  // 讯飞解析文字
@property (nonatomic, strong) JAPlayAnimateView *animateView;  // 试听控件

@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIButton *againRecordButton; // 重新录制

@property (nonatomic, assign, readwrite) JARecordStatusType recordStatus;  // 按钮的状态
@property (nonatomic, assign) JARecordStatusType frontStatus;  // 按钮的前一个状态

@end

static const NSInteger kMaxRecordTime = 60*5;

@implementation JARecordInputView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupRecordInputViewUI];
        self.backgroundColor = [UIColor whiteColor];
        
        self.frontStatus = self.recordStatus;
        
        self.clipsToBounds = YES;
        
        self.recordManager = [[JAInputRecordManager alloc] init];
        self.recordManager.delegate = self;
        
    }
    return self;
}

- (void)setupRecordInputViewUI
{
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self addSubview:self.indicatorView];
    
    //Example 2
    self.spectrumView2 = [[SpectrumView alloc] init];
    self.spectrumView2.hidden = YES;
    [self addSubview:self.spectrumView2];
    
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.text = @"00:00/05:00";
    self.statusLabel.textColor = HEX_COLOR(0x999EAD);
    self.statusLabel.font = JA_REGULAR_FONT(16);
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.hidden = YES;
    [self addSubview:self.statusLabel];
    
    self.xfLabel = [[UILabel alloc] init];
    self.xfLabel.text = @"未能识别文字,请重录";
    self.xfLabel.textColor = HEX_COLOR(0x999EAD);
    self.xfLabel.font = JA_REGULAR_FONT(12);
    self.xfLabel.textAlignment = NSTextAlignmentCenter;
    self.xfLabel.hidden = YES;
    [self addSubview:self.xfLabel];
    
    self.animateView = [[JAPlayAnimateView alloc] initWithColor:HEX_COLOR(0x6BD379) frame:CGRectZero];
    self.animateView.hidden = YES;
//    [self.animateView.playButton addTarget:self action:@selector(beginlisten:) forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(beginlisten)];
    [self.animateView addGestureRecognizer:tap];
    [self addSubview:self.animateView];
    
    self.speakLabel = [[UILabel alloc] init];
    self.speakLabel.text = @"按住说";
    self.speakLabel.textColor = HEX_COLOR(0x999EAD);
    self.speakLabel.font = JA_MEDIUM_FONT(12);
    self.speakLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.speakLabel];
    
    self.recordSecondLabel = [[UILabel alloc] init];
    self.recordSecondLabel.text = [NSString stringWithFormat:@"最少需要录%d秒哦",kMinRecordSecond];
    self.recordSecondLabel.textColor = HEX_COLOR(0x999EAD);
    self.recordSecondLabel.font = JA_REGULAR_FONT(12);
    self.recordSecondLabel.textAlignment = NSTextAlignmentCenter;
    self.recordSecondLabel.hidden = YES;
    [self addSubview:self.recordSecondLabel];
    
    self.recordImageView = [[UIImageView alloc] init];
    [self.recordImageView setImage:[UIImage imageNamed:@"input_record_speak"]];
    self.recordImageView.userInteractionEnabled = YES;
    self.longP = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(beginRecord:)];
    self.longP.minimumPressDuration = 0.2;
    [self.recordImageView addGestureRecognizer:self.longP];
    [self addSubview:self.recordImageView];
    
    self.bottomView = [[UIView alloc] init];
    self.bottomView.backgroundColor = [UIColor whiteColor];
    self.bottomView.hidden = YES;
    [self addSubview:self.bottomView];
    
    self.againRecordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.againRecordButton setTitle:@"重 录" forState:UIControlStateNormal];
    [self.againRecordButton setTitleColor:HEX_COLOR(0x999EAD) forState:UIControlStateNormal];
    self.againRecordButton.titleLabel.font = JA_REGULAR_FONT(16);
    [self.againRecordButton addTarget:self action:@selector(againRecordVoice:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.againRecordButton];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.width = JA_SCREEN_WIDTH;
    
    self.statusLabel.width = 95;
    self.statusLabel.height = 22;
    self.statusLabel.centerX = self.width * 0.5;
    self.statusLabel.y = 30;
    
    self.xfLabel.width = self.width;
    self.xfLabel.height = 22;
    self.xfLabel.centerX = self.width * 0.5;
    self.xfLabel.y = 60;
    
    self.animateView.centerX = self.width * 0.5;
    self.animateView.y = self.xfLabel.bottom + 30;
    
    self.spectrumView2.width = 200;
    self.spectrumView2.height = 40;
    self.spectrumView2.centerX = self.width * 0.5;
    self.spectrumView2.centerY = self.statusLabel.centerY;
    
    // 设置指示器位置
    self.indicatorView.centerX = JA_SCREEN_WIDTH * 0.5;
    self.indicatorView.centerY = self.statusLabel.centerY;
    
    self.recordImageView.width = 80;
    self.recordImageView.height = self.recordImageView.width;
    self.recordImageView.centerX = self.statusLabel.centerX;
    self.recordImageView.y = self.statusLabel.bottom + 30;
    
    self.recordSecondLabel.width = self.width;
    self.recordSecondLabel.height = 10;
    self.recordSecondLabel.centerX = self.width * 0.5;
    self.recordSecondLabel.y = self.recordImageView.bottom + 20;
    
    self.speakLabel.width = self.width;
    self.speakLabel.height = 10;
    self.speakLabel.centerX = self.width * 0.5;
    self.speakLabel.centerY = self.recordSecondLabel.centerY;
    
    self.bottomView.height = 40;
    self.bottomView.width = JA_SCREEN_WIDTH;
    self.bottomView.y = self.recordImageView.bottom + 20;
    
    self.againRecordButton.width = 70;
    self.againRecordButton.height = 30;
    self.againRecordButton.layer.cornerRadius = self.againRecordButton.height * 0.5;
    self.againRecordButton.layer.masksToBounds = YES;
    self.againRecordButton.layer.borderColor = HEX_COLOR(0x999EAD).CGColor;
    self.againRecordButton.layer.borderWidth = 1;
    self.againRecordButton.centerX = self.bottomView.width * 0.5;
    self.againRecordButton.centerY = self.bottomView.height * 0.5;
  
}

#pragma mark - 开始录音
- (void)beginRecord:(UILongPressGestureRecognizer *)longP
{
    if (longP.state == UIGestureRecognizerStateBegan) {
        
        if (TARGET_IPHONE_SIMULATOR){
            
            [self.indicatorView startAnimating];
            self.voiceDuration = 0;
            [self.recordManager inputRecordStart];   // 开始录制
            _allPeakLevelQueue = [NSMutableArray array];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(handleInterreption:)
                                                         name:AVAudioSessionInterruptionNotification
                                                       object:[AVAudioSession sharedInstance]];
            self.bottomView.hidden = YES;
            self.speakLabel.hidden = YES;
            self.xfLabel.hidden = YES;
            self.animateView.hidden = YES;
            self.recordSecondLabel.hidden = NO;
            self.recordImageView.hidden = NO;
            if ([self.delegate respondsToSelector:@selector(recordInputViewWithRecordButton:buttonStatus:)]) {
                [self.delegate recordInputViewWithRecordButton:self buttonStatus:self.recordStatus];
            }
        }else{
            if ([JAPermissionHelper systemPermissionsWithVoice] == BBEPermissionsStatusAuthorize) {
                [self.indicatorView startAnimating];
                self.voiceDuration = 0;
                [self.recordManager performSelector:@selector(inputRecordStart) withObject:nil afterDelay:0.0f inModes:@[NSRunLoopCommonModes]];

                _allPeakLevelQueue = [NSMutableArray array];
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(handleInterreption:)
                                                             name:AVAudioSessionInterruptionNotification
                                                           object:[AVAudioSession sharedInstance]];
                self.bottomView.hidden = YES;
                self.speakLabel.hidden = YES;
                self.xfLabel.hidden = YES;
                self.animateView.hidden = YES;
                self.recordSecondLabel.hidden = NO;
                self.recordImageView.hidden = NO;
                if ([self.delegate respondsToSelector:@selector(recordInputViewWithRecordButton:buttonStatus:)]) {
                    [self.delegate recordInputViewWithRecordButton:self buttonStatus:self.recordStatus];
                }
            }else{
                [JAPermissionHelper systemPermissionsWithVoice_getSuccess:nil getFailure:nil];
            }
        }
        
    }else if(longP.state != UIGestureRecognizerStateChanged){
        
        if (self.indicatorView.isAnimating) {
            [self.indicatorView stopAnimating];
        }
        [self endRecordVoice];
    }
}

// 结束录音
- (void)endRecordVoice
{
    [self.recordManager inputIflyStop];  // 结束识别语音
    
    if (self.recordManager.inputRecordStatus == JAInputRecordStatusTypeRecording) {
        [self.recordManager inputRecordStop];   // 结束录制
    }
    
    if (self.voiceDuration >= kMinRecordSecond) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            if (self.voiceDuration < JA_IFLY_Time) {  // 小于10秒并且有文字
                if (self.recordManager.iflyResults.count) {
                    self.xfLabel.hidden = YES;
                }else{
                    self.xfLabel.hidden = NO;
                }
            }else{
//                self.xfLabel.hidden = YES;
                self.xfLabel.hidden = NO;
                self.xfLabel.text = @"感谢你用心的回复，请为它起个标题吧";
            }
            
        });
        self.spectrumView2.hidden = YES;
        self.statusLabel.hidden = YES;
        self.recordImageView.hidden = YES;
        self.bottomView.hidden = NO;
        self.animateView.hidden = NO;
        
        int min = (int)self.voiceDuration/60;
        int sec = (int)self.voiceDuration%60;
        
        if (min > 0) {
            self.animateView.time = [NSString stringWithFormat:@"%d'%02d\"",min,sec];
        }else{
            self.animateView.time = [NSString stringWithFormat:@"%02d\"",sec];
        }
        
//        NSString *time = [NSString stringWithFormat:@"%d'%d\"",(int)self.voiceDuration/60,(int)self.voiceDuration%60];
//        self.animateView.time = time;
    }
}

#pragma mark - 监听来电
- (void)handleInterreption:(NSNotification *)sender  // 来电打断
{
    
    if (self.recordManager.inputRecordStatus == JAInputRecordStatusTypeListening) {
        // 停止试听
        [self.recordManager inputRecordListenStop];
    }
    
}


#pragma mark -  录制试听管理者 录制的代理回调
- (void)inputRecordWithDuration:(CGFloat)duration volume:(CGFloat)volume drawVolume:(CGFloat)drawVolume
{
    
    if ((duration - 60 * 5) > 0.f) {
//        // 完成录音
        [self endRecordVoice];
        return;
    }
    
    
    if (self.indicatorView.isAnimating && drawVolume > 0) {
        [self.indicatorView stopAnimating];
    }
    self.spectrumView2.level = drawVolume;
    
    drawVolume = drawVolume / 20.0;
    [self.allPeakLevelQueue addObject:[NSString stringWithFormat:@"%.2f",drawVolume]];
    
    // 绘制时间和音量动画
    NSString *time = [NSString stringWithFormat:@"%02d:%02d/%02d:00",(int)duration/60,(int)duration%60,(int)kMaxRecordTime/60];
    
    self.statusLabel.text = time;
    self.spectrumView2.hidden = NO;
    self.statusLabel.hidden = NO;
    
    if (self.indicatorView.isAnimating) {
        [self.indicatorView stopAnimating];
    }
    
    self.voiceDuration = duration;
  
}

#pragma mark -  录制试听管理者 录制完成的代理回调
- (void)inputRecordFinish
{

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (self.recordManager.recordFile.length && self.voiceDuration >= kMinRecordSecond) {  // 有效音频文件
        // 传递给外面展示上面的音频文件
        if ([self.delegate respondsToSelector:@selector(recordInputViewWithFinishButton:duration:textResult:)]) {
            NSString *durationS = [NSString stringWithFormat:@"%f",self.voiceDuration];
            [self.delegate recordInputViewWithFinishButton:self duration:durationS textResult:self.recordManager.iflyResults];
        }
    }else{
        [self.recordManager removeAvailFile];  // 移除无效的音频文件
        if (!self.recordManager.recordFile.length) {
            [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"无效的音频文件，请重录"];
        }
        if (self.voiceDuration < kMinRecordSecond) {
            NSString *str = [NSString stringWithFormat:@"最少需要录%d秒哦",kMinRecordSecond];
            [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:str];
            if (self.recordManager.iflyResults.count) {
                [self.recordManager.iflyResults removeAllObjects];
            }
        }
        if ([self.delegate respondsToSelector:@selector(recordInputViewWithFaile)]) {
            [self.delegate recordInputViewWithFaile];
        }
    }
}

#pragma mark -  录制试听管理者 录制失败的代理回调
- (void)inputRecordFinishFaile
{
    if ([self.delegate respondsToSelector:@selector(recordInputViewWithFaile)]) {
        [self.delegate recordInputViewWithFaile];
    }
}

#pragma mark -  重新录制
- (void)againRecordVoice:(UIButton *)btn
{
    [self clickPublishButton_stopListen];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.bottomView.hidden = YES;
    self.xfLabel.hidden = YES;
    self.recordSecondLabel.hidden = YES;
    self.animateView.hidden = YES;
    self.speakLabel.hidden = NO;
    self.recordImageView.hidden = NO;
    
    [self.recordManager.iflyResults removeAllObjects];
    
    if ([self.delegate respondsToSelector:@selector(recordInputViewWithCancleButton:)]) {   // 点击取消按钮
        [self.delegate recordInputViewWithCancleButton:self];
    }
}

#pragma mark -  录制试听管理者 试听进度的代理回调
- (void)inputListenWithPlayDuration:(CGFloat)duration
{
    if (duration == self.voiceDuration) {
        
        [self.recordManager inputRecordListenStop];
        self.animateView.playButton.selected = NO;
        int min = (int)self.voiceDuration/60;
        int sec = (int)self.voiceDuration%60;
        
        if (min > 0) {
            self.animateView.time = [NSString stringWithFormat:@"%d'%02d\"",min,sec];
        }else{
            self.animateView.time = [NSString stringWithFormat:@"%02d\"",sec];
        }
//        NSString *time = [NSString stringWithFormat:@"%02d:%02d",(int)self.voiceDuration/60,(int)self.voiceDuration%60];
//        self.animateView.time = time;
        [self.animateView resetVolumeAnimate];
    }else{
        // 开始动画
        int min = (int)(self.voiceDuration - duration)/60;
        int sec = (int)(self.voiceDuration - duration) %60;
        
        if (min > 0) {
            self.animateView.time = [NSString stringWithFormat:@"%d'%02d\"",min,sec];
        }else{
            self.animateView.time = [NSString stringWithFormat:@"%02d\"",sec];
        }
//        NSString *time = [NSString stringWithFormat:@"%02d:%02d",(int)(self.voiceDuration - duration)/60,(int)(self.voiceDuration - duration) %60];
//        self.animateView.time = time;
        
        [self.animateView beginVolumeAnimate:(duration / self.voiceDuration)];
    }
}

#pragma mark - 开始试听
- (void)beginlisten
{
    UIButton *btn = self.animateView.playButton;
    
    if (btn.selected) {
        btn.selected = NO;
        
//        [self.recordManager inputRecordListenStop];
//        int min = (int)self.voiceDuration/60;
//        int sec = (int)self.voiceDuration%60;
//
//        if (min > 0) {
//            self.animateView.time = [NSString stringWithFormat:@"%d'%02d\"",min,sec];
//        }else{
//            self.animateView.time = [NSString stringWithFormat:@"%02d\"",sec];
//        }
//        [self.animateView resetVolumeAnimate];
        
        [self.recordManager inputRecordListenPause];
        
    }else{
        btn.selected = YES;
//        [self.recordManager inputRecordListenBegin];
        
        if (self.recordManager.inputRecordStatus == JAInputRecordStatusTypeListenPause) {
            [self.recordManager inputRecordListenContinue];
        }else{
            [self.recordManager inputRecordListenBegin];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopDrawVoiceAnimate) name:@"stopLocalVoice" object:nil];
        }
    }
}

/// 收到通知停止试听
- (void)stopDrawVoiceAnimate
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"stopLocalVoice" object:nil];
    [self.recordManager inputRecordListenStop];
    self.animateView.playButton.selected = NO;
    int min = (int)self.voiceDuration/60;
    int sec = (int)self.voiceDuration%60;
    
    if (min > 0) {
        self.animateView.time = [NSString stringWithFormat:@"%d'%02d\"",min,sec];
    }else{
        self.animateView.time = [NSString stringWithFormat:@"%02d\"",sec];
    }
    
    [self.animateView resetVolumeAnimate];
}


#pragma mark - 对外方法
/// 唤起录制键盘
- (void)becomeRecordInputView
{
    self.recordStatus = JARecordStatusTypeResponse;
}

/// 辞去录制键盘
- (void)registRecordInputView
{
    self.recordStatus = JARecordStatusTypeNone;
}

/// 恢复录制键盘的初始按钮状态
- (void)resetInputRecord
{
    self.bottomView.hidden = YES;
    self.xfLabel.hidden = YES;
    self.animateView.hidden = YES;
    self.recordSecondLabel.hidden = YES;
    self.spectrumView2.hidden = YES;
    self.statusLabel.hidden = YES;
    self.speakLabel.hidden = NO;
    self.recordImageView.hidden = NO;
    
    [self.recordManager.iflyResults removeAllObjects];
}

/// 点击发布按钮停止试听
- (void)clickPublishButton_stopListen
{
    if (self.recordManager.inputRecordStatus == JAInputRecordStatusTypeListening || self.recordManager.inputRecordStatus == JAInputRecordStatusTypeListenPause) {
        
        [self.recordManager inputRecordListenStop];
        self.animateView.playButton.selected = NO;
        int min = (int)self.voiceDuration/60;
        int sec = (int)self.voiceDuration%60;
        
        if (min > 0) {
            self.animateView.time = [NSString stringWithFormat:@"%d'%02d\"",min,sec];
        }else{
            self.animateView.time = [NSString stringWithFormat:@"%02d\"",sec];
        }
//        NSString *time = [NSString stringWithFormat:@"%02d:%02d",(int)self.voiceDuration/60,(int)self.voiceDuration%60];
//        self.animateView.time = time;
        [self.animateView resetVolumeAnimate];
    }
}

#pragma mark - 私有方法
- (void)setRecordStatus:(JARecordStatusType)recordStatus
{
    _recordStatus = recordStatus;
    //   布局frame
    if (self.recordStatus == JARecordStatusTypeNone) {
        [UIView animateWithDuration:0.25 animations:^{
            self.height = 0;
        }];
    }else{
        [UIView animateWithDuration:0.25 animations:^{
            self.height = 252;
        }];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"JARecordInputDidChangeNotification" object:nil];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
