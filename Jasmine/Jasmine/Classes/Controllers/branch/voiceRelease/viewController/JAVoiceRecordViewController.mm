//
//  JAVoiceReocrdViewController.m
//  Jasmine
//
//  Created by xujin on 30/08/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JAVoiceRecordViewController.h"
#import "JAVoiceReleaseViewController.h"
#import "JATimelineView.h"
#import "JARecordWaveView.h"
#import "JAVoiceWaveView.h"
#import "JASliderThumbView.h"
#import "NSMutableArray+Queue.h"
#import "JAPermissionHelper.h"
#import "JAVoiceLocalViewController.h"
#import "JAUserApiRequest.h"
#import "JAContributeViewController.h"
#import "JAContributeIntroduceView.h"

#import "EZAudioPlayer.h"
#import "EZMicrophone.h"
#import "LameConver.h"
#import "RMAudioProcess.h"
#import "EZAudioUtilities.h"
#import "JAVoicePlayerManager.h"
#import "JANewPlaySingleTool.h"
#import "JANewPlayTool.h"

#define BUFFERSIZE (1024*10*4)
#define MAX_WAV_CNT (2048)

static const NSInteger kMaxRecordTime = 60*5;
const NSString* API_KEY = @"zYLGnhBoToHu4s2gGcHzB9go";
const NSString* SECRET_KEY = @"dfFdyGDHxuLGbd4tf4h698otTK26OoCC";
const NSString* APP_ID = @"10336427";
static const NSInteger nrSampleRate = 32000;

typedef NS_ENUM(NSInteger, JARecordStyle) {
    JARecordStyleRecord,
    JARecordStyleListen,
    JARecordStyleCrop
};

@interface JABorderButton : UIButton

@end

@implementation JABorderButton

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (highlighted) {
        self.layer.borderColor = [HEX_COLOR(0xD1D1D2) CGColor];
    } else {
        self.layer.borderColor = [HEX_COLOR(0xF4F4F4) CGColor];
    }
}

@end

@interface JAVoiceRecordViewController ()<EZMicrophoneDelegate, EZAudioPlayerDelegate> {

    BOOL isRecording,isMicOn,isMusicOn;
    BOOL hasRecordData;
    BOOL hasRecord5sData;
    BOOL isUpload;
    NSInteger minSeconds;
}

@property (nonatomic, assign) BOOL hasChecked; // 已经检测过低分贝和是否识别出文字
@property (nonatomic, assign) BOOL lowVoice;

@property (nonatomic, strong) UIButton *recordButton;
@property (nonatomic, strong) UIButton *pauseRecordButton;
@property (nonatomic, strong) UIButton *listenButton;
@property (nonatomic, strong) UIButton *rerecordButton;
@property (nonatomic, strong) UIButton *noticeButton;

@property (nonatomic, strong) UILabel *leftLabel;
@property (nonatomic, strong) UILabel *centerLabel;
@property (nonatomic, strong) UILabel *rightLabel;
@property (nonatomic, strong) UILabel *recordTimeLabel;

@property (nonatomic, strong) JARecordWaveView *mWaveFormView;
@property (nonatomic, strong) JAVoiceWaveView *voiceWaveView;

@property (nonatomic, assign) JARecordStyle currentRecordStyle;
@property (nonatomic, strong) CADisplayLink *meterUpdateDisplayLink;

@property (nonatomic, strong) NSMutableArray *peakLevelQueue; //录制显示
@property (nonatomic, strong) NSMutableArray *allPeakLevelQueue;
@property (nonatomic, strong) NSMutableArray *currentPeakLevelQueue;
@property (nonatomic, strong) NSMutableArray *displayPeakLevelQueue;
@property (nonatomic, strong) JATimelineView *timelineView;

@property (nonatomic, assign) BOOL isContinueReplay;
@property (nonatomic, assign) int allCount;
@property (nonatomic, assign) CGPoint originalOffset;

@property(nonatomic, strong) NSFileHandle *fileHandler;
//@property(nonatomic, strong) BDSEventManager *asrEventManager;
@property(nonatomic, assign) BOOL longSpeechFlag;
@property (nonatomic, strong) UIButton *rightButton;

@property (nonatomic, strong) EZAudioPlayer * ezPlayer;
@property (nonatomic, strong) EZMicrophone * ezMic;
@property (nonatomic, strong) NSString * nrFilePath;
@property (nonatomic, strong) LameConver *conver;
@property (nonatomic, assign) SInt64 totalFrames;
@property (nonatomic, assign) NSTimeInterval duration;

// 降噪和增益
@property (nonatomic, assign) RMAudioProcess audioProcess;
@property (nonatomic, assign) AudioBufferList * nrBufferList;
@property (nonatomic, assign) char * pNRBuffer;
@property (nonatomic, assign) int nrBufferUsedSize;
@property (nonatomic, assign) char * wavForm;
@property (nonatomic, assign) int wavUsedSize;
@property (nonatomic, assign) int maxCount; // 录音时view最多样本数

@end

@implementation JAVoiceRecordViewController

- (BOOL)fd_interactivePopDisabled {
    return YES;
}

- (void)dealloc {
    if (_wavForm) {
        free(_wavForm);
        _wavForm = NULL;
    }
    
    if (_pNRBuffer) {
        free(_pNRBuffer);
        _pNRBuffer = NULL;
    }
    
    if (_audioProcess) {
        [self deleteAudioProcess:_audioProcess];
        _audioProcess = NULL;
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [JAVoicePlayerManager shareInstance].isInRecord = NO;
    //设置屏幕常亮
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (UIButton *)createButton {
    JABorderButton *button = [JABorderButton buttonWithType:UIButtonTypeCustom];
//    if (iPhone4) {
//        button.layer.cornerRadius = 20;
//    } else {
//        button.layer.cornerRadius = 30;
//    }
//    button.layer.masksToBounds = YES;
//    button.layer.borderColor = [HEX_COLOR(0xf4f4f4) CGColor];
//    button.layer.borderWidth = 3;
    return button;
}

- (void)loadView {
    [super loadView];
//    [[JAVoicePlayerManager shareInstance] pause];
//    [[JAVoicePlayerManager shareInstance] cancelDelayPlayNextVoice];
//    [JAVoicePlayerManager shareInstance].isInRecord = YES;
    
    [[JANewPlayTool shareNewPlayTool] playTool_pause];
    [[JANewPlaySingleTool shareNewPlaySingleTool] playSingleTool_pause];
}

- (void)pauseAction {
    [self pauseRecordButtonAction];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //设置屏幕常亮
    [UIApplication sharedApplication].idleTimerDisabled = YES;
//    [self setNavRightTitle:@"上传音频" color:HEX_COLOR(JA_Green)];
    if (self.fromType == 1) {
        [self setCenterTitle:@"录制投稿"];
        minSeconds = 30;
    } else {
        [self setCenterTitle:@"录制主帖"];
        minSeconds = 5;
    }
    
    [self setupTopView];
    [self setupBottomView];
    [self changeViewWithStyle:JARecordStyleRecord];
    [self setRightButtonEnable:NO];
    [self setButtonDisableStatus];
    [self startUpdatingMeter];
    
    NSString *sourceRecordFile = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"record"] stringByAppendingPathExtension:@"mp3"];
    _nrFilePath = sourceRecordFile;
    [NSString ja_removeFilePath:self.nrFilePath];
    
    _conver = [[LameConver alloc] initWithFilePath:self.nrFilePath];

    _wavForm = (char*)malloc(BUFFERSIZE);
    _wavUsedSize = 0;
    
    _pNRBuffer = (char*)malloc(BUFFERSIZE);
    _nrBufferUsedSize = 0;
    
    _audioProcess = [self createAudioProcessFromConfig];
    
    self.maxCount = (int)(self.mWaveFormView.width/4.0);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetState) name:@"app_loginOut" object:nil];
}

- (void)resetState {
    [self.navigationController popViewControllerAnimated:NO];
    [self pausePlay];
    [self pauseRecordButtonAction];
    [self stopUpdatingMeter];
}

- (void)actionLeft {
    if (hasRecordData) {
        // 暂停录音
        [self pausePlay];
        [self pauseRecordButtonAction];
        if (self.fromType == 1) {
            [self showAlertViewWithTitle:@"你确定要放弃投稿吗" subTitle:@"" completion:^(BOOL complete) {
                if (complete) {
                    [self stopUpdatingMeter];
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
        } else {
            [self showAlertViewWithTitle:@"确定放弃当前录音？" subTitle:@"" completion:^(BOOL complete) {
                if (complete) {
                    NSMutableDictionary *params = [NSMutableDictionary new];
                    params[JA_Property_RecordDuration] = @((int)self.duration);
                    params[JA_Property_ContentType] = @"主帖";
                    [JASensorsAnalyticsManager sensorsAnalytics_dropRecord:params];
                    
                    [self stopUpdatingMeter];
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
        }
    } else {
        // 暂停录音
        [self pausePlay];
        [self pauseRecordButtonAction];
        [self stopUpdatingMeter];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)actionRight {
    if (!hasRecordData) {
        return;
    }
    [self releaseButtonAction];
}

- (void)setRightButtonEnable:(BOOL)enable {
    if (enable) {
        [self setNavRightTitle:@"完成" color:HEX_COLOR(JA_Green)];
    } else {
        [self setNavRightTitle:@"完成" color:HEX_COLOR(0xe2e2e2)];
    }
}

// 销毁界面，清理所有资源
- (void)stopAll {
    [self stopUpdatingMeter];
//    [self.recordEngine stopRecord];
}

- (void)setButtonEnableStatus {
//    self.listenButton.layer.borderColor = [HEX_COLOR(JA_GaryTitle) CGColor];
    self.listenButton.enabled = YES;
    
//    self.releaseButton.layer.borderColor = [HEX_COLOR(JA_GaryTitle) CGColor];
//    self.releaseButton.layer.borderWidth = 1;
    self.rerecordButton.enabled = YES;
}

- (void)setButtonDisableStatus {
//    self.listenButton.layer.borderColor = [HEX_COLOR(JA_BoardLineColor) CGColor];
    self.listenButton.enabled = NO;
//    self.releaseButton.layer.borderColor = [HEX_COLOR(JA_BoardLineColor) CGColor];
    self.rerecordButton.enabled = NO;
}

- (void)changeViewWithStyle:(JARecordStyle)style {
    self.currentRecordStyle = style;
    self.recordButton.hidden = YES;
    self.pauseRecordButton.hidden = YES;
    
    switch (style) {
        case JARecordStyleRecord:
        {
            if (isMicOn) {
                self.pauseRecordButton.hidden = NO;
                self.centerLabel.text = @"麦克风正在录音";
            } else {
                self.recordButton.hidden = NO;
                self.centerLabel.text = @"录音已暂停";
            }
            self.listenButton.hidden = NO;
            self.rerecordButton.hidden = NO;
            
            if (hasRecordData) {
                [self setButtonEnableStatus];
            } else {
                [self setButtonDisableStatus];
            }
            self.leftLabel.text = @"试听";
            self.rightLabel.text = @"重录";
        }
            break;
        default:
            break;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[JA_Property_ScreenName] = @"录音";
    [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:params];
    [(JABaseNavigationController *)self.navigationController setNavigationBarLineHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.noticeString.length) {
        [JAContributeIntroduceView showContributeViewWithLoopCount:1 text:self.noticeString];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [(JABaseNavigationController *)self.navigationController setNavigationBarLineHidden:NO];
}

#pragma mark - setupUI
- (void)setupTopView {
    CGFloat waveHeigh = WIDTH_ADAPTER(150);
    if (iPhone4) {
        waveHeigh = 100;
    }
    
    UIView *topView = [UIView new];
//    topView.backgroundColor = [UIColor redColor];
    [self.view addSubview:topView];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.offset(0);
        make.height.offset(waveHeigh+50);
    }];
    
    JATimelineView *timelineView = [[JATimelineView alloc] initWithFrame:CGRectMake(0, 20, JA_SCREEN_WIDTH, 30)];
//    timelineView.backgroundColor = [UIColor redColor];
    [self.view addSubview:timelineView];
    self.timelineView = timelineView;
    
    UIView *lineView = [UIView new];
    lineView.backgroundColor = HEX_COLOR(0xd1d1d1);
    [topView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(50);
        make.left.right.offset(0);
        make.height.offset(1);
    }];
    
    UIView *waveView = [UIView new];
    waveView.backgroundColor = [UIColor clearColor];
    [topView addSubview:waveView];
    [waveView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lineView.mas_bottom);
        make.left.offset(0);
        make.width.offset(JA_SCREEN_WIDTH);
        make.height.offset(waveHeigh);
    }];
    
    JAVoiceWaveView *voiceWaveView = [[JAVoiceWaveView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, waveHeigh)];
//    voiceWaveView.backgroundColor = [UIColor yellowColor];
    voiceWaveView.maskColor = HEX_COLOR(0x1CD39B);
    voiceWaveView.darkGrayColor = HEX_COLOR(0x1CD39B);
    voiceWaveView.sliderIV.drawColor = HEX_COLOR(0x44444);
//    voiceWaveView.sliderIV.hidden = YES;
    voiceWaveView.sliderIV.stickWidth = 1;
    voiceWaveView.sliderIV.diameter = 5;
    voiceWaveView.sliderIV.height = waveHeigh+16;
    voiceWaveView.sliderIV.y = -11;
    [waveView addSubview:voiceWaveView];
    self.voiceWaveView = voiceWaveView;
    
    UIView *lineView1 = [UIView new];
    lineView1.backgroundColor = HEX_COLOR(0xd1d1d1);
    [topView insertSubview:lineView1 belowSubview:waveView];
    [lineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(waveView.mas_bottom);
        make.left.right.offset(0);
        make.height.offset(1);
    }];
    
    self.mWaveFormView = [[JARecordWaveView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH/2.0, waveHeigh)];
    self.mWaveFormView.maskColor = HEX_COLOR(0x1CD39B);
    self.mWaveFormView.sliderIV.drawColor = HEX_COLOR(0x44444);
//    self.mWaveFormView.sliderIV.hidden = YES;
    self.mWaveFormView.sliderIV.stickWidth = 1;
    self.mWaveFormView.sliderIV.diameter = 5;
    self.mWaveFormView.sliderIV.height = waveHeigh+16;
    self.mWaveFormView.sliderIV.y = -11;
//    self.mWaveFormView.backgroundColor = [UIColor redColor];
    [waveView addSubview:self.mWaveFormView];
}

- (void)noticeAction {
    self.noticeButton.hidden = YES;
    self.recordTimeLabel.hidden = NO;
}

// 底部按钮
- (void)setupBottomView {
    self.centerLabel = [UILabel new];
    self.centerLabel.font = JA_REGULAR_FONT(12);
    self.centerLabel.textColor = HEX_COLOR(JA_BlackSubSubTitle);
    [self.view addSubview:self.centerLabel];
    [self.centerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        if (iPhone4) {
            make.bottom.offset(-5);
        } else {
            make.bottom.offset(-WIDTH_ADAPTER(33));
        }
    }];
    //    self.centerLabel.backgroundColor = [UIColor redColor];
    
    self.recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.recordButton setImage:[UIImage imageNamed:@"voice_record_btn"] forState:UIControlStateNormal];
    [self.recordButton setImage:[UIImage imageNamed:@"voice_record_btn"] forState:UIControlStateHighlighted];
    [self.recordButton addTarget:self action:@selector(recordButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.recordButton];
    [self.recordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.centerLabel.mas_centerX);
        make.bottom.equalTo(self.centerLabel.mas_top).offset(-10);
        if (iPhone4) {
            make.size.mas_equalTo(CGSizeMake(60, 60));
        } else {
            make.size.mas_equalTo(CGSizeMake(110, 110));
        }
    }];
    
    
    UIButton *noticeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [noticeButton setImage:[UIImage imageNamed:@"voice_record_notice"] forState:UIControlStateNormal];
    [noticeButton setImage:[UIImage imageNamed:@"voice_record_notice"] forState:UIControlStateHighlighted];
    [noticeButton addTarget:self action:@selector(noticeAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:noticeButton];
    [noticeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.centerLabel.mas_centerX);
        make.bottom.equalTo(self.recordButton.mas_top).offset(-13);
//        make.size.mas_equalTo(CGSizeMake(320, 100));
    }];
    self.noticeButton = noticeButton;
    
    self.pauseRecordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.pauseRecordButton setImage:[UIImage imageNamed:@"voice_record_pause_btn"] forState:UIControlStateNormal];
    [self.pauseRecordButton setImage:[UIImage imageNamed:@"voice_record_pause_btn"] forState:UIControlStateHighlighted];
    [self.pauseRecordButton addTarget:self action:@selector(pauseRecordButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.pauseRecordButton];
    [self.pauseRecordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.recordButton);
    }];
    self.pauseRecordButton.layer.borderColor = [[UIColor clearColor] CGColor];

    self.listenButton = [self createButton];
    [self.listenButton setImage:[UIImage imageNamed:@"voice_record_listen_btn"] forState:UIControlStateNormal];
    [self.listenButton setImage:[UIImage imageNamed:@"voice_record_listen_btn"] forState:UIControlStateHighlighted];
    [self.listenButton setImage:[UIImage imageNamed:@"voice_listen_pause_btn"] forState:UIControlStateSelected];
    [self.listenButton setImage:[UIImage imageNamed:@"voice_listen_pause_btn"] forState:UIControlStateSelected|UIControlStateHighlighted];
    [self.listenButton setImage:[UIImage imageNamed:@"voice_record_listen_disable"] forState:UIControlStateDisabled];
    [self.listenButton addTarget:self action:@selector(showListenView:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.listenButton];
    [self.listenButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.recordButton.mas_right).offset(WIDTH_ADAPTER(44));
        make.bottom.equalTo(self.recordButton.mas_bottom);
        
        if (iPhone4) {
            make.size.mas_equalTo(CGSizeMake(40, 40));
        } else {
            make.size.mas_equalTo(CGSizeMake(60, 60));
        }
    }];
    self.rerecordButton = [self createButton];
    
    [self.rerecordButton setImage:[UIImage imageNamed:@"voice_rerecord"] forState:UIControlStateNormal];
    [self.rerecordButton setImage:[UIImage imageNamed:@"voice_rerecord"] forState:UIControlStateHighlighted];
    [self.rerecordButton setImage:[UIImage imageNamed:@"voice_rerecord_disable"] forState:UIControlStateDisabled];
    [self.rerecordButton addTarget:self action:@selector(reRecordAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.rerecordButton];
    [self.rerecordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.recordButton.mas_left).offset(-WIDTH_ADAPTER(44));
        make.bottom.equalTo(self.recordButton.mas_bottom);
        
        if (iPhone4) {
            make.size.mas_equalTo(CGSizeMake(40, 40));
        } else {
            make.size.mas_equalTo(CGSizeMake(60, 60));
        }
        
    }];
    
    self.leftLabel = [UILabel new];
    self.leftLabel.font = JA_REGULAR_FONT(12);
    self.leftLabel.textColor = HEX_COLOR(JA_BlackSubSubTitle);
    [self.view addSubview:self.leftLabel];
    [self.leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.listenButton.mas_centerX);
//        make.centerY.equalTo(self.centerLabel.mas_centerY);
        make.top.equalTo(self.listenButton.mas_bottom).offset(10);

    }];
    //    self.leftLabel.backgroundColor = [UIColor greenColor];
    
    self.rightLabel = [UILabel new];
    self.rightLabel.font = JA_REGULAR_FONT(12);
    self.rightLabel.textColor = HEX_COLOR(JA_BlackSubSubTitle);
    [self.view addSubview:self.rightLabel];
    [self.rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.rerecordButton.mas_centerX);
//        make.centerY.equalTo(self.centerLabel.mas_centerY);
        make.top.equalTo(self.rerecordButton.mas_bottom).offset(10);
    }];
    //    self.rightLabel.backgroundColor = [UIColor redColor];
    
    // 录音时间
    self.recordTimeLabel = [UILabel new];
    self.recordTimeLabel.textColor = HEX_COLOR(JA_Green);
    self.recordTimeLabel.font = JA_LIGHT_FONT(32);
    [self.view addSubview:self.recordTimeLabel];
    [self.recordTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.recordButton.mas_top).offset(-15);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    [self.recordTimeLabel setText:[NSString stringWithFormat:@"00:00/%02d:00",(int)kMaxRecordTime/60]];
    self.recordTimeLabel.hidden = YES;
}

#pragma mark - button action
- (void)reRecordAction {
    if (!hasRecordData) {
        return;
    }
    [self pausePlay];
    [self pauseRecordButtonAction];

    [self showAlertViewWithTitle:@"提示" subTitle:@"确定要重录吗？" completion:^(BOOL complete) {
        if (complete) {
            [self confirmRerecord];
        }
        NSMutableDictionary *params = [NSMutableDictionary new];
        params[JA_Property_Rerecording] = @(complete);
        params[JA_Property_RecordDuration] = @((int)self.duration);
        params[JA_Property_AutoDialog] = @(NO);
        params[JA_Property_ContentType] = @"主帖";
        [JASensorsAnalyticsManager sensorsAnalytics_rerecording:params];
    }];
}

- (void)confirmRerecord {
    hasRecordData = NO;
    hasRecord5sData = NO;
    [self setRightButtonEnable:NO];
    [self setButtonDisableStatus];
    [self.recordTimeLabel setText:[NSString stringWithFormat:@"00:00/%02d:00",(int)kMaxRecordTime/60]];
    
    [self.currentPeakLevelQueue removeAllObjects];
    [self.displayPeakLevelQueue removeAllObjects];
    [self.peakLevelQueue removeAllObjects];
    [self.allPeakLevelQueue removeAllObjects];
    
    [self.mWaveFormView setPeakLevelQueue:self.peakLevelQueue];
    self.mWaveFormView.sliderIV.x = 0;
    [self.timelineView resetTimeProgress];

    self.originalOffset = CGPointMake(0, 0);
    
    // 重置
    self.hasChecked = NO;
    self.lowVoice = NO;

    self.totalFrames = 0;
    memset(_wavForm, 0, BUFFERSIZE);
    memset(_pNRBuffer, 0, BUFFERSIZE);
    _wavUsedSize = 0;
    _nrBufferUsedSize = 0;
    
    // 删除本地音频文件
    [NSString ja_removeFilePath:self.nrFilePath];
}

// 录音
- (void)recordButtonAction {
    if (![JAPermissionHelper hasRecordPermission]) {
        return;
    }
    [self noticeAction];
    [self pausePlay];
    
    if (!hasRecordData) {
        NSMutableDictionary *senDic = [NSMutableDictionary new];
        senDic[JA_Property_ContentType] = @"主帖";
        [JASensorsAnalyticsManager sensorsAnalytics_startRecord:senDic];
    }
    hasRecordData = YES;

    isMicOn = YES;
    [self changeViewWithStyle:JARecordStyleRecord];
   
    // 延时0.1秒开始录制 如果0.1秒内点了暂停，则取消该操作
    [self performSelector:@selector(startRec) withObject:nil afterDelay:0.2];

    if (self.originalOffset.x) {
        
        [self.timelineView.collectionView setContentOffset:self.originalOffset animated:NO];
    }
}

- (void)startRec
{
    [self.ezPlayer pause];
    _ezPlayer = nil;
    [self.conver openFileWithFilePath:self.nrFilePath];
    [self.ezMic startFetchingAudio];
}

// 暂停录音
- (void)pauseRecordButtonAction {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startRec) object:nil];
    isMicOn = NO;
    [self.ezMic stopFetchingAudio];
    _ezMic = nil;
    [self.conver closeFile];
    [self changeViewWithStyle:JARecordStyleRecord];
    [self pauseUpdatingMeter];
    self.originalOffset = self.timelineView.collectionView.contentOffset;
}


// 试听页面跳转事件
- (void)showListenView:(UIButton *)sender {
    if (!YES) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(myDelayedMethod:) object:sender];
    [self performSelector:@selector(myDelayedMethod:) withObject:sender afterDelay:0.3];
}


- (void)myDelayedMethod:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        if (self.isContinueReplay) {
            [self.ezPlayer play];
        } else {
            [self pauseRecordButtonAction];

            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
            [audioSession setActive:YES error:nil];
            
            if (self.ezPlayer.isPlaying) {
                [self.ezPlayer pause];
                _ezPlayer = nil;
            }
//            EZAudioFile *audioFile = [EZAudioFile audioFileWithURL:[NSURL fileURLWithPath:self.nrFilePath]];
//            [self.ezPlayer playAudioFile:audioFile];
            __weak id weakSelf = self;
            self.ezPlayer = [EZAudioPlayer audioPlayerWithURL:[NSURL fileURLWithPath:self.nrFilePath] delegate:weakSelf];
            [self.ezPlayer play];

            self.mWaveFormView.hidden = YES;
            self.voiceWaveView.hidden = NO;
            
            [self.displayPeakLevelQueue removeAllObjects];
            [self.currentPeakLevelQueue removeAllObjects];
            
            self.displayPeakLevelQueue = [NSMutableArray arrayWithArray:self.allPeakLevelQueue];
            
            _allCount = (int)(JA_SCREEN_WIDTH/4.0);
            if (_allCount%2 != 0) {
                _allCount -= 1;
            }
            int halfCount = _allCount/2;
            int diff = 0;
            if (self.displayPeakLevelQueue.count > _allCount) {
                diff = halfCount;
            } else if (self.displayPeakLevelQueue.count < _allCount &&
                       self.displayPeakLevelQueue.count > halfCount) {
                diff = (int)(_allCount - self.displayPeakLevelQueue.count)+halfCount;
            } else {
                diff = (int)(_allCount - self.displayPeakLevelQueue.count);
            }
            // 补充空点
            for (int i=0; i<diff; i++) {
                [self.displayPeakLevelQueue addObject:@(-1.0)];
            }
            // 获取一屏幕的样本点
            for (int i=0; i<_allCount; i++) {
                [self.currentPeakLevelQueue addObject:self.displayPeakLevelQueue[i]];
            }
            [self.voiceWaveView setPeakLevelQueue:self.currentPeakLevelQueue];
            
            [self.timelineView resetTimeProgress];
        }
        [self continueUpdatingMeter];
    } else {
        self.isContinueReplay = YES;
        [self.ezPlayer pause];
        
        [self pauseUpdatingMeter];
    }
}

- (void)pausePlay {
    self.mWaveFormView.hidden = NO;
    self.voiceWaveView.hidden = YES;

    self.isContinueReplay = NO;
    self.listenButton.selected = NO;
    
    [self.ezPlayer pause];
    _ezPlayer = nil;
    [self pauseUpdatingMeter];
}

// 发布
- (void)releaseButtonAction {
    [self pausePlay];
    [self pauseRecordButtonAction];

    if (self.duration < 5){
        [self.view ja_makeToast:[NSString stringWithFormat:@"录音时长不能小于%zds",minSeconds]];
        return;
    }
    
    if (hasRecordData) {
//        [MBProgressHUD showMessage:@"录音保存中..."];
        // 保存文件（理论上边录边写）
//        [self stopAll];
        [self stopUpdatingMeter];
        isUpload = YES;
        
        NSMutableDictionary *params = [NSMutableDictionary new];
        params[JA_Property_RecordDuration] = @((int)self.duration);
        params[JA_Property_ContentType] = @"主帖";
        [JASensorsAnalyticsManager sensorsAnalytics_endRecord:params];
    }
    if (isUpload) {
//        [MBProgressHUD hideHUD];
        
        if (self.fromType == 1) {
            JAContributeViewController *vc = [JAContributeViewController new];
            vc.time = self.duration;
            vc.allPeakLevelQueue = self.allPeakLevelQueue;
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            JAVoiceReleaseViewController *vc = [JAVoiceReleaseViewController new];
            vc.time = self.duration;
            vc.allPeakLevelQueue = self.allPeakLevelQueue;
            // v3.0.0
            vc.topicModel = self.topicModel;
            vc.circleModel = self.circleModel;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

#pragma mark - 定时器
- (void)startUpdatingMeter {
    [self.meterUpdateDisplayLink invalidate];
    self.meterUpdateDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMeters)];
    self.meterUpdateDisplayLink.frameInterval = 6;// 每秒调用10次（60/frameInterval）
//    self.meterUpdateDisplayLink.preferredFramesPerSecond = 10;// 模拟器iPhone6崩溃
    [self.meterUpdateDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    self.meterUpdateDisplayLink.paused = YES;
}

- (void)pauseUpdatingMeter {
    self.meterUpdateDisplayLink.paused = YES;
}

- (void)continueUpdatingMeter {
    self.meterUpdateDisplayLink.paused = NO;
}

- (void)stopUpdatingMeter {
    [self.meterUpdateDisplayLink invalidate];
    self.meterUpdateDisplayLink = nil;
}

- (void)updateMeters {
    /************** 试听 **************/
    if (self.listenButton.selected) {
        NSInteger index = (NSInteger)(self.ezPlayer.currentTime * 10);
        CGFloat percent = (index * 4) / (JA_SCREEN_WIDTH);
        if (percent>=0.5) {
            percent = 0.5;
            index = index+_allCount/2; // 跳过半个波形的宽度
            if (index < self.displayPeakLevelQueue.count) {
                [self.currentPeakLevelQueue enqueue:self.displayPeakLevelQueue[index] maxCount:_allCount];
            }
            CGFloat stride = index*4-JA_SCREEN_WIDTH/2.0;
            [self.timelineView.collectionView setContentOffset:CGPointMake(stride, 0) animated:NO];
        }
        // 移动滑动杆
        [self.voiceWaveView setSliderOffsetX:percent];
        [self.voiceWaveView setPeakLevelQueue:self.currentPeakLevelQueue];
        return;
    }
}

- (void)popToVC {
    [self pausePlay];
    [self pauseRecordButtonAction];
    [self stopUpdatingMeter];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - RMAudioProcess
- (RMAudioProcess)createAudioProcessFromConfig
{
    int nNREnable = 1;
    int nNRMode = 1; // 0轻微1中度2强力
    
    int nAgcEnable = 1;
    // nLevel 是值越大，表示增益后的音量越大
    int nLevel = 20; //nLevel 0-30 db  default 9db
    // nTargetDB 是值越小，表示最后效果的音量越大
    int nTargetDB = 6; // 取值1-30（6-15比较合适）
    
    int nSample = [self GetRecFileABSD].mSampleRate;
    int nChannel =  [self GetRecFileABSD].mChannelsPerFrame;
    RMAudioProcess process = createRMAudioProcess(nSample, nChannel, nNREnable, nAgcEnable);
    setRMAGCLevel(process, nLevel, nTargetDB);
    setRMNoiseReduceMode(process, nNRMode);
    
    return process;
}

- (void)deleteAudioProcess:(RMAudioProcess)process
{
    deleteRMAudioProcess(process);
}

- (int)WaveViewNeedData:(short*)pShortBuffer needCnt:(int)nCnt
{
    int nChannel = [self NrFileABSD].mChannelsPerFrame;
    int nFrameBlockSize = sizeof(short)*nChannel;
    int waveCnt = _wavUsedSize/nFrameBlockSize;
    if (nChannel == 1) {
        if (waveCnt <= nCnt) {
            memcpy(pShortBuffer, _wavForm, waveCnt*2);
        } else {
            memcpy(pShortBuffer, _wavForm + (waveCnt - nCnt)*2, nCnt*2);
        }
    } else {
        //如果是双声道，需要分离左右声道的数据
        if(waveCnt <= nCnt) {
            short * pShortWav = (short*)_wavForm;
            for(int i=0; i<waveCnt; i++) {
                pShortBuffer[i] = pShortWav[2*i];//Left
                //pShortWav[2*i+1];//Right
            }
        } else {
            short * pShortWav = (short*)(_wavForm + (waveCnt - nCnt)*nFrameBlockSize);
            for(int i=0; i<waveCnt; i++) {
                pShortBuffer[i] = pShortWav[2*i];//Left
            }
        }
    }
    return  MIN(waveCnt, nCnt);
}

#pragma mark - EZMicrophoneDelegate
- (void)microphone:(EZMicrophone *)microphone hasBufferList:(AudioBufferList *)bufferList withBufferSize:(UInt32)bufferSize withNumberOfChannels:(UInt32)numberOfChannels {
    
    if (!isMicOn) {
        return;
    }
//    NSLog(@"%@",[NSThread currentThread]);
    self.totalFrames += bufferSize;
//    [self.conver convertPcmToMp3:bufferList->mBuffers[0] toPath:self.nrFilePath];
    
    int nOut = BUFFERSIZE - _nrBufferUsedSize;
    int wavOut = BUFFERSIZE - _wavUsedSize;

    int MinBuffer = 0;
    int MinWavBuffer = 0;

    getProcessSafeBufferSize(self.audioProcess, bufferList->mBuffers[0].mDataByteSize, &MinBuffer, &MinWavBuffer);

    assert(MinBuffer <= nOut );
    assert(MinWavBuffer <= wavOut );

    processRMAudio(self.audioProcess, (char*)bufferList->mBuffers[0].mData, bufferList->mBuffers[0].mDataByteSize, _pNRBuffer+_nrBufferUsedSize, &nOut, _wavForm + _wavUsedSize, &wavOut);

    if (wavOut > 0) {
        // 真正产生一个有效的样本点
        if (numberOfChannels == 1) {
            char *momentForm = _wavForm+_wavUsedSize;
            short *shortForm = (short *)momentForm;
            CGFloat volume = ABS(shortForm[0])/32767.0;
            [self.allPeakLevelQueue addObject:[NSString stringWithFormat:@"%.2f",volume]];
            [self.peakLevelQueue enqueue:[NSString stringWithFormat:@"%.2f",volume] maxCount:self.maxCount];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            /************** 录音 **************/
            NSTimeInterval curDuration = self.duration;
            if (curDuration > 5.0) {
                if (!hasRecord5sData) {
                    hasRecord5sData = YES;
                    [self setRightButtonEnable:YES];
                }
            }
            if ((curDuration - kMaxRecordTime) >= 0.f) {
                // 超过最大时长处理，暂停录音
                [self pauseRecordButtonAction];
                return;
            }
            [self.recordTimeLabel setText:[NSString stringWithFormat:@"%02d:%02d/%02d:00",(int)curDuration/60,(int)curDuration%60,(int)kMaxRecordTime/60]];
            
            //        [self.peakLevelQueue removeAllObjects];
            //        short *_waveBuffer = (short *)malloc(sizeof(short)*MAX_WAV_CNT);
            //        int nCnt = (int)(self.mWaveFormView.width/4.0);
            //        assert(nCnt<MAX_WAV_CNT);
            //        memset(_waveBuffer, 0, MAX_WAV_CNT*2);
            //        int _waveCnt = [self WaveViewNeedData:_waveBuffer needCnt:nCnt];
            //        for (int i=0; i<_waveCnt; i++) {
            //            CGFloat volume = ABS(_waveBuffer[i])/32767.0;
            //            [self.peakLevelQueue addObject:[NSString stringWithFormat:@"%.2f",volume]];
            //        }
            
            [self.mWaveFormView setPeakLevelQueue:self.peakLevelQueue];
            
            // 移动滑动杆
            CGFloat percent = (self.allPeakLevelQueue.count * 4) / self.mWaveFormView.width;
            if (percent>=1.0) {
                percent = 1.0;
                [self.timelineView updateTimeProgress];
            }
            [self.mWaveFormView setSliderOffsetX:percent];
            
            // 前Ns是否能解析出文字
            if (!self.hasChecked && (int)curDuration == 5) {
                self.hasChecked = YES;
                //        [self cancelButtonPressed];
                //        [self recordButtonAction];
                
                float allVoiceLevel = 0.0;
                for (int i=0; i<self.allPeakLevelQueue.count; i++) {
                    float value = [self.allPeakLevelQueue[i] floatValue];
                    allVoiceLevel += value;
                }
                if (allVoiceLevel/self.allPeakLevelQueue.count <= 0.15) {
                    // 声音过小
                    self.lowVoice = YES;
                }
                //        if (!self.audio2Text.length || self.lowVoice) {
                
                if (self.lowVoice) {
                    [self pausePlay];
                    [self pauseRecordButtonAction];
                    [self showAlertViewWithTitle:@"声音太小，是否重录"
                                        subTitle:@"系统检测到您当前录音音量太小，发布后可能会影响您的信用评分"
                                 leftButtonTitle:@"取消"
                                rightButtonTitle:@"重录"
                                      completion:^(BOOL complete) {
                                          if (complete) {
                                              [self confirmRerecord];
                                          }
                                          NSMutableDictionary *params = [NSMutableDictionary new];
                                          params[JA_Property_Rerecording] = @(complete);
                                          params[JA_Property_RecordDuration] = @((int)self.duration);
                                          params[JA_Property_AutoDialog] = @(YES);
                                          params[JA_Property_ContentType] = @"主帖";
                                          [JASensorsAnalyticsManager sensorsAnalytics_rerecording:params];
                                      }];
                }
            }
        });
    }

    _nrBufferUsedSize += nOut;
    _wavUsedSize += wavOut;

    int blockSize = [self NrFileABSD].mChannelsPerFrame * sizeof(short);
    int nFrameSize = blockSize *1024;
    while (_nrBufferUsedSize >= nFrameSize) {
        memcpy(self.nrBufferList->mBuffers[0].mData, _pNRBuffer, nFrameSize);
        _nrBufferList->mBuffers[0].mDataByteSize = nFrameSize;
//        [self.nrRecorder appendDataFromBufferList:_nrBufferList withBufferSize:nFrameSize/blockSize];
        [self.conver convertPcmToMp3:_nrBufferList->mBuffers[0] toPath:self.nrFilePath];
        memmove(_pNRBuffer, _pNRBuffer +nFrameSize, _nrBufferUsedSize - nFrameSize);
        _nrBufferUsedSize -= nFrameSize;
    }

    if (_wavUsedSize>=BUFFERSIZE/2) {
        _wavUsedSize = 0;
    }
}

#pragma mark - EZAudioPlayerDelegate
//- (void)audioPlayer:(EZAudioPlayer *)audioPlayer
//    updatedPosition:(SInt64)framePosition
//        inAudioFile:(EZAudioFile *)audioFile {
//    __weak typeof (self) weakSelf = self;
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if (weakSelf.listenButton.selected) {
//            NSInteger index = (NSInteger)(self.ezPlayer.currentTime * 10);
//            CGFloat percent = (index * 4) / (JA_SCREEN_WIDTH);
//            if (percent>=0.5) {
//                percent = 0.5;
//                index = index+_allCount/2; // 跳过半个波形的宽度
//                if (index < self.displayPeakLevelQueue.count) {
//                    [self.currentPeakLevelQueue enqueue:self.displayPeakLevelQueue[index] maxCount:_allCount];
//                }
//                CGFloat stride = index*4-JA_SCREEN_WIDTH/2.0;
//                [self.timelineView.collectionView setContentOffset:CGPointMake(stride, 0) animated:NO];
//            }
//            // 移动滑动杆
//            [self.voiceWaveView setSliderOffsetX:percent];
//            [self.voiceWaveView setPeakLevelQueue:self.currentPeakLevelQueue];
//        }
//    });
//}

- (void)audioPlayer:(EZAudioPlayer *)audioPlayer reachedEndOfAudioFile:(EZAudioFile *)audioFile {
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf pausePlay];
    });
}

#pragma mark - lazy load
- (NSMutableArray *)peakLevelQueue {
    if (!_peakLevelQueue) {
        _peakLevelQueue = [NSMutableArray new];
    }
    return _peakLevelQueue;
}

- (NSMutableArray *)currentPeakLevelQueue {
    if (!_currentPeakLevelQueue) {
        _currentPeakLevelQueue = [NSMutableArray new];
    }
    return _currentPeakLevelQueue;
}

- (NSMutableArray *)allPeakLevelQueue {
    if (!_allPeakLevelQueue) {
        _allPeakLevelQueue = [NSMutableArray new];
    }
    return _allPeakLevelQueue;
}

- (NSMutableArray *)displayPeakLevelQueue {
    if (!_displayPeakLevelQueue) {
        _displayPeakLevelQueue = [NSMutableArray new];
    }
    return _displayPeakLevelQueue;
}

- (AudioStreamBasicDescription) GetRecFileABSD
{
    AudioStreamBasicDescription asbd;
    UInt32 byteSize = sizeof(short);
    asbd.mBitsPerChannel   = 8 * byteSize;
    asbd.mBytesPerFrame    = byteSize;
    asbd.mBytesPerPacket   = byteSize;
    asbd.mChannelsPerFrame = 1;
    //asbd.mFormatFlags      = kAudioFormatFlagsCanonical|kAudioFormatFlagIsNonInterleaved;
    asbd.mFormatFlags      = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked | kAudioFormatFlagIsNonInterleaved;
    asbd.mFormatID         = kAudioFormatLinearPCM;
    asbd.mFramesPerPacket  = 1;
    asbd.mSampleRate       = 32000;
    asbd.mReserved         = 0;
    return asbd;
}

- (AudioStreamBasicDescription) NrFileABSD
{
    AudioStreamBasicDescription asbd;
    UInt32 byteSize = sizeof(short);
    asbd.mBitsPerChannel   = 8 * byteSize;
    asbd.mBytesPerFrame    = byteSize;
    asbd.mBytesPerPacket   = byteSize;
    asbd.mChannelsPerFrame = 1;
    //asbd.mFormatFlags      = kAudioFormatFlagsCanonical|kAudioFormatFlagIsNonInterleaved;
    asbd.mFormatFlags      = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked | kAudioFormatFlagIsNonInterleaved;
    asbd.mFormatID         = kAudioFormatLinearPCM;
    asbd.mFramesPerPacket  = 1;
    asbd.mSampleRate       = nrSampleRate;
    asbd.mReserved         = 0;
    return asbd;
}

- (EZMicrophone*)ezMic
{
    if (!_ezMic) {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [audioSession setActive:YES error:nil];
        
        AudioStreamBasicDescription audioStreamDes = [self GetRecFileABSD];
        __weak id weakSelf = self;
        _ezMic = [EZMicrophone microphoneWithDelegate:weakSelf withAudioStreamBasicDescription:audioStreamDes];
   }
    return _ezMic;
}

- (NSTimeInterval)duration
{
    return (NSTimeInterval) self.totalFrames / nrSampleRate;
}

- (AudioBufferList*) nrBufferList
{
    if(!_nrBufferList)
    {
        _nrBufferList = [EZAudioUtilities audioBufferListWithNumberOfFrames:4096 numberOfChannels:[self NrFileABSD].mChannelsPerFrame interleaved:YES];
    }
    return _nrBufferList;
}

@end

