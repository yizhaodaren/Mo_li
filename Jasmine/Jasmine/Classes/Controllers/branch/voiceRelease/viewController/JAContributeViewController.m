//
//  JAContributeViewController.m
//  Jasmine
//
//  Created by xujin on 2018/4/9.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JAContributeViewController.h"
#import "JAUserApiRequest.h"
//#import "JAStoryApi.h"
#import "BHPlaceholderTextView.h"
#import "JAChannelModel.h"
#import "XDLocationTool.h"
#import "JAVoiceApi.h"
#import "JAVoiceCommentApi.h"
#import "JAVoiceReplyApi.h"
#import "JAPersonalCenterViewController.h"
#import "NSString+URLEncode.h"
#import "NSMutableArray+Queue.h"

#import "JAUserApiRequest.h"
#import "JAVoiceWaveView.h"
#import "JASliderThumbView.h"
#import "JAZipAndUnzip.h"
#import "JAReleaseStoryCountModel.h"
#import "JASampleHelper.h"
#import "JFImagePickerController.h"
#import "JAReleasePostManager.h"
#import "JAVoiceReleaseTopicViewController.h"
#import "JACommonSearchPeopleVC.h"
#import "JADataHelper.h"
#import "JAPlayLocalVoiceManager.h"
#import "JAVoicePlayerManager.h"

static const NSInteger maxContentLength = 30;

@interface JAContributeViewController ()<
UINavigationControllerDelegate,
UIImagePickerControllerDelegate,
UIScrollViewDelegate,
AVAudioPlayerDelegate>

@property (nonatomic, assign) NSInteger imageCount;
@property (nonatomic, assign) BOOL disableButton;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) BHPlaceholderTextView *contentTextView;
@property (nonatomic, strong) UILabel *wordCountL;
@property (nonatomic, strong) UIView *waveView;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIScrollView *photoScrollView;// 多图滚动
@property (nonatomic, strong) UIButton *addPhotoButton; // 添加图片
@property (nonatomic, strong) UIImageView *locationIcon;
@property (nonatomic, strong) UILabel *locationTitleLabel;
@property (nonatomic, strong) UIButton *locationCloseButton;

@property (nonatomic, strong) JAVoiceWaveView *mWaveFormView;
@property (nonatomic, strong) NSMutableArray *currentPeakLevelQueue;
@property (nonatomic, strong) NSMutableArray *displayPeakLevelQueue;

@property (nonatomic, assign) int allCount;

@property (nonatomic, strong) MBProgressHUD *currentHUD;

@property (nonatomic, copy) NSString *content;// 描述
@property (nonatomic, copy) NSString *audioUrl;// 音频地址

// v2.6.-
@property (nonatomic, strong) CADisplayLink *meterUpdateDisplayLink;

@end

@implementation JAContributeViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)fd_interactivePopDisabled  {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.contentTextView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[JAPlayLocalVoiceManager sharePlayVoiceManager] stopLocalVoice];
    [self.contentTextView resignFirstResponder];
    [self resetPlayState];
    [self stopUpdatingMeter];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.currentPeakLevelQueue = [NSMutableArray new];
    self.displayPeakLevelQueue = [self.allPeakLevelQueue mutableCopy];
    
    [self setCenterTitle:@"添加标题"];
    [self setLeftNavigationItemImage:[UIImage imageNamed:@"branch_login_close"] highlightImage:[UIImage imageNamed:@"branch_login_close"]];
    [self setRightButtonEnable:NO];
    
    [self setupScrollView];
}

- (void)setRightButtonEnable:(BOOL)enable {
    if (enable) {
        [self setNavRightTitle:@"投递" color:HEX_COLOR(JA_Green)];
    } else {
        [self setNavRightTitle:@"投递" color:HEX_COLOR(0xe2e2e2)];
    }
}

- (void)hideKeyboard {
    [self.view endEditing:YES];
}

- (void)setupScrollView {
    self.scrollView = [UIScrollView new];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.offset(0);
        make.height.offset(JA_SCREEN_HEIGHT-64);
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.scrollView addGestureRecognizer:tap];
    
    UIView *contentView = [UIView new];
    contentView.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.offset(0);
        make.width.equalTo(self.scrollView.mas_width);
        make.height.offset(JA_SCREEN_HEIGHT-64+1);
    }];
    
    self.contentTextView = [BHPlaceholderTextView new];
    self.contentTextView.backgroundColor = [UIColor clearColor];
    self.contentTextView.placeholder = @"让茉莉君更好的了解你的故事";
    self.contentTextView.font = JA_REGULAR_FONT(15);
    self.contentTextView.placeholderColor = HEX_COLOR(JA_BlackSubTitle);
    self.contentTextView.textColor = HEX_COLOR(JA_BlackTitle);
    self.contentTextView.layoutManager.allowsNonContiguousLayout = NO;
    //    self.contentTextView.maxContentLength = maxContentLength;
    [contentView addSubview:self.contentTextView];
    [self.contentTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(14);
        make.left.offset(10);
        make.right.offset(-10);
        make.height.offset(70);
    }];
    self.contentTextView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);//设置页边距
    @WeakObj(self);
  
    self.contentTextView.textChangeBlock = ^(UITextView *textView) {
        @StrongObj(self);
        // 提示文字数目
        int caculaterCount = [self caculaterName:textView.text];
        self.wordCountL.text = [NSString stringWithFormat:@"%d/%d",caculaterCount,(int)maxContentLength];
        if (caculaterCount > maxContentLength) {
            self.wordCountL.textColor = [UIColor redColor];
        } else {
            self.wordCountL.textColor = HEX_COLOR(JA_BlackSubTitle);
        }
        
        // 控制发布按钮的样式
        NSString *inputContent = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (inputContent.length) {
            [self setRightButtonEnable:YES];
        }else{
            [self setRightButtonEnable:NO];
        }
    };
    
    self.wordCountL = [UILabel new];
    self.wordCountL.backgroundColor = [UIColor clearColor];
    self.wordCountL.font = JA_REGULAR_FONT(12);
    self.wordCountL.textColor = HEX_COLOR(JA_BlackSubTitle);
    self.wordCountL.text = [NSString stringWithFormat:@"0/%zd",maxContentLength];
    [contentView addSubview:self.wordCountL];
    [self.wordCountL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentTextView.mas_bottom).offset(10);
        //        make.bottom.equalTo(self.channelButton.mas_bottom);
        make.right.offset(-15);
        make.height.offset(20);
    }];

    UIView *lineView = [UIView new];
    lineView.backgroundColor = HEX_COLOR(JA_Line);
    [contentView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.wordCountL.mas_bottom).offset(10);
        make.left.right.offset(0);
        make.height.offset(1);
    }];
    
    UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [playButton setImage:[UIImage imageNamed:@"branch_voice_commentplay"] forState:UIControlStateNormal];
    [playButton setImage:[UIImage imageNamed:@"branch_voice_commentplay"] forState:UIControlStateHighlighted];
    [playButton setImage:[UIImage imageNamed:@"branch_voice_commentpause"] forState:UIControlStateSelected];
    [playButton setImage:[UIImage imageNamed:@"branch_voice_commentpause"] forState:UIControlStateSelected|UIControlStateHighlighted];
    [playButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:playButton];
    [playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lineView.mas_bottom).offset(10);
        make.left.offset(15);
        make.size.mas_equalTo(CGSizeMake(35, 35));
    }];
    self.playButton = playButton;
    
    UIView *waveView = [UIView new];
    //    waveView.backgroundColor = [UIColor grayColor];
    [contentView addSubview:waveView];
    [waveView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.playButton.mas_right).offset(10);
        make.centerY.equalTo(self.playButton.mas_centerY);
        make.right.offset(-15);
        make.height.offset(36);
    }];
    self.waveView = waveView;
    
    self.mWaveFormView = [[JAVoiceWaveView alloc] initWithFrame:CGRectMake(0, 6, JA_SCREEN_WIDTH-60-15, 36)];
    //    self.mWaveFormView.backgroundColor = [UIColor redColor];
    //    self.mWaveFormView.maskColor = HEX_COLOR(0x54C7FC);
    //    self.mWaveFormView.darkGrayColor = HEX_COLOR_ALPHA(0x54C7FC, 0.5);
    [waveView addSubview:self.mWaveFormView];
    //    [self.mWaveFormView mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.edges.equalTo(waveView);
    //    }];
    
    // 半个波形图可绘制的样本数
    _allCount = (int)(self.mWaveFormView.width/4.0);
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
    for (int i=0; i<MIN(_allCount, self.displayPeakLevelQueue.count); i++) {
        [self.currentPeakLevelQueue addObject:self.displayPeakLevelQueue[i]];
    }
    [self.mWaveFormView setPeakLevelQueue:self.currentPeakLevelQueue];
    
    // 设置波形图颜色
    int type = self.displayPeakLevelQueue.count%8;
    NSDictionary *colorDic = [JAAPPManager app_waveViewColorWithType:type];
    if (colorDic) {
        unsigned long vernier_color = strtoul([colorDic[@"vernier_color"] UTF8String],0,0);
        unsigned long wave_color = strtoul([colorDic[@"wave_color"] UTF8String],0,0);
        self.mWaveFormView.maskColor = HEX_COLOR(wave_color);
        self.mWaveFormView.darkGrayColor = HEX_COLOR_ALPHA(wave_color, 0.5);
        self.mWaveFormView.sliderIV.drawColor = HEX_COLOR(vernier_color);
    }
    
    UIView *lineView1 = [UIView new];
    lineView1.backgroundColor = HEX_COLOR(JA_Line);
    [contentView addSubview:lineView1];
    [lineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(playButton.mas_bottom).offset(10);
        make.left.right.offset(0);
        make.height.offset(1);
    }];
}

- (int)caculaterName:(NSString *)strtemp
{
    int strlength = 0;
    char* p = (char*)[strtemp cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[strtemp lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
        if (*p) {
            strlength++;
        }
        p++;
    }
    return (strlength+1)/2;
}

// 播放录音
- (void)playButtonAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        if (self.meterUpdateDisplayLink.paused) {
            [[JAPlayLocalVoiceManager sharePlayVoiceManager] resumeLocalVoice];
            [self continueUpdatingMeter];
        } else {
            // 暂停主播放器
            if ([JAVoicePlayerManager shareInstance].isPlaying) {
                [[JAVoicePlayerManager shareInstance] pause];
                [[JAVoicePlayerManager shareInstance] cancelDelayPlayNextVoice];
            }
            NSString *recordFile = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"record"] stringByAppendingPathExtension:@"mp3"];
            [[JAPlayLocalVoiceManager sharePlayVoiceManager] playLocalVoiceWith:recordFile];
            [JAPlayLocalVoiceManager sharePlayVoiceManager].player.delegate = self;
            [self startUpdatingMeter];
        }
    } else {
        [[JAPlayLocalVoiceManager sharePlayVoiceManager] pauseLocalVoice];
        [self pauseUpdatingMeter];
    }
}

- (void)actionLeft {
    if ([self.contentTextView isFirstResponder]) {
        [self.contentTextView resignFirstResponder];
    }
    [self showAlertViewWithTitle:nil subTitle:@"你确定要放弃投稿吗" completion:^(BOOL complete) {
        if (complete) {
            [self backToLastLastVC];
        }
    }];
}

- (void)backToLastLastVC {
    NSInteger backIndex = self.navigationController.viewControllers.count-1-2;
    if (backIndex < self.navigationController.viewControllers.count) {
        id vc = self.navigationController.viewControllers[backIndex];
        [self.navigationController popToViewController:vc animated:YES];
    }
}

- (void)actionRight
{
    NSString *inputContent = [self.contentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.content = inputContent;
    if (!inputContent.length) {
        [self.view ja_makeToast:@"声音描述不能为空"];
        return;
    }
    [self.view endEditing:YES];

    if (self.disableButton) {
        return;
    }
    self.disableButton = YES;
    self.currentHUD = [MBProgressHUD showMessage:@"提交中..." toView:self.view];
    
    // 文件写入成功后，上传到网络
    NSString *recordFile = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"record"] stringByAppendingPathExtension:@"mp3"];
    NSData *mp3Data = [NSData dataWithContentsOfFile:recordFile];
    if (mp3Data.length) {
        [[JAUserApiRequest shareInstance] ali_upLoadData:mp3Data fileType:@"mp3" finish:^(NSString *filePath) {
            if (filePath.length) {
                NSString *imageUrl = [NSString stringWithFormat:@"%@",filePath];
                self.audioUrl = imageUrl;
                
                [self releaseVoice];
            } else {
                self.disableButton = NO;
                [MBProgressHUD hideHUD];
                [self.currentHUD hideAnimated:NO];
                
                [self showAlertViewWithTitle:@"录音上传失败，是否要重试？" subTitle:@"" completion:^(BOOL complete) {
                    if (complete) {
                        [self actionRight];
                    }
                }];
            }
        }];
    }
}

// 发布
- (void)releaseVoice {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userUuid"] =[JAUserInfo userInfo_getUserImfoWithKey:User_uuid];
    params[@"audioUrl"] = self.audioUrl;
    params[@"time"] = @((int)self.time);
    params[@"content"] = self.content;// 声音描述
    [[JAVoiceApi shareInstance] voice_ContributeVoiceWithParas:params success:^(NSDictionary *result) {
        [self.currentHUD hideAnimated:NO];
        [self.view ja_makeToast:@"投稿成功" duration:1.0];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self backToLastLastVC];
        });
    } failure:^(NSError *error) {
        self.disableButton = NO;
        [self.currentHUD hideAnimated:NO];
        [self.view ja_makeToast:error.localizedDescription];
    }];
}

#pragma mark - 定时器
- (void)startUpdatingMeter {
    if (!self.meterUpdateDisplayLink) {
        self.meterUpdateDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMeters)];
        self.meterUpdateDisplayLink.frameInterval = 6;// 每秒调用10次（60/frameInterval）
        //    self.meterUpdateDisplayLink.preferredFramesPerSecond = 10;// 模拟器iPhone6崩溃
        [self.meterUpdateDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
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
    AVAudioPlayer *player = [JAPlayLocalVoiceManager sharePlayVoiceManager].player;
    NSInteger index = (NSInteger)(player.currentTime * 10 + 1);
    CGFloat percent = (index * 4) / (self.mWaveFormView.width);
    if (percent>=0.5) {
        percent = 0.5;
        index = index+_allCount/2; // 跳过半个波形的宽度
        if (index < self.displayPeakLevelQueue.count) {
            [self.currentPeakLevelQueue enqueue:self.displayPeakLevelQueue[index] maxCount:_allCount];
        }
    }
    // 移动滑动杆
    [self.mWaveFormView setSliderOffsetX:percent];
    
    int cutIndex = percent * self.currentPeakLevelQueue.count;
    [self.mWaveFormView setPeakLevelQueue:self.currentPeakLevelQueue cutIndex:cutIndex];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self resetPlayState];
    [self stopUpdatingMeter];
}

- (void)resetPlayState {
    self.playButton.selected = NO;
    self.mWaveFormView.sliderIV.x = 0;
    
    [self.currentPeakLevelQueue removeAllObjects];
    for (int i=0; i<MIN(_allCount, self.displayPeakLevelQueue.count); i++) {
        [self.currentPeakLevelQueue addObject:self.displayPeakLevelQueue[i]];
    }
    [self.mWaveFormView setPeakLevelQueue:self.currentPeakLevelQueue];
}

@end
