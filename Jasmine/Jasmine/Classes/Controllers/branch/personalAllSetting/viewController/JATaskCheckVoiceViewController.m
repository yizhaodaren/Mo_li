//
//  JATaskCheckVoiceViewController.m
//  Jasmine
//
//  Created by 刘宏亮 on 2018/4/8.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JATaskCheckVoiceViewController.h"
#import "SpectrumView.h"
#import "JAPaddingLabel.h"
#import "JAInputRecordManager.h"
#import "JAPermissionHelper.h"
#import "JAUserApiRequest.h"
#import "JAVoiceCommonApi.h"

@interface JATaskCheckVoiceViewController ()<JAInputRecordManagerDelegate>
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UILabel *topLabel;
@property (nonatomic, weak) JAPaddingLabel *contentLabel;
@property (nonatomic, weak) UIImageView *balloonImageView;
@property (nonatomic, weak) SpectrumView *spectrumView2;  // 音波动画
@property (nonatomic, weak) UILabel *statusLabel;  // 时间状态label
@property (nonatomic, strong) UILongPressGestureRecognizer *longP;
@property (nonatomic, weak) UIImageView *recordImageView;
@property (nonatomic, weak) UILabel *bottomLabel;

@property (nonatomic, assign) CGFloat voiceDuration;  // 音频总时长
@property (nonatomic, strong) JAInputRecordManager *recordManager; // 录音机

@property (nonatomic, strong) NSString *contentString;
@property (nonatomic, strong) NSString *contentId;
@property (nonatomic, assign) NSInteger checkCount;  // 测试次数
@property (nonatomic, assign) NSInteger checkTotalCount;  // 测试次数
@property (nonatomic, strong) NSString *match; // 匹配度

@property (nonatomic, assign) BOOL requestStatus;  // 接口请求状态
@end

@implementation JATaskCheckVoiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setCenterTitle:@"让茉莉听见你"];
    
    self.recordManager = [[JAInputRecordManager alloc] init];
    self.recordManager.maxTime = 60;
    self.recordManager.delegate = self;
    
    [self setupTaskCheckVoiceView];
    
    // 获取声音鉴定信息
    [self getVoiceContent];
}

- (void)getVoiceContent
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    [[JAVoiceCommonApi shareInstance] voice_getCheckVoiceContent:dic success:^(NSDictionary *result) {
        self.requestStatus = YES;
        self.checkCount = [result[@"dayTimes"] integerValue];  // 鉴别次数
        self.checkTotalCount = [result[@"voiceContent"][@"maxTimes"] integerValue]; // 鉴别总次数
        self.match = [NSString stringWithFormat:@"%@",result[@"voiceContent"][@"matchResult"]];  // 匹配度
        self.contentString = [NSString stringWithFormat:@"%@",result[@"voiceContent"][@"content"]];  // 匹配内容
        self.contentId = [NSString stringWithFormat:@"%@",result[@"voiceContent"][@"id"]];  // 内容ID
        self.contentLabel.text = self.contentString;
        self.topLabel.text = [NSString stringWithFormat:@"朗读以下内容，匹配度达到%@%%及以上可获得%@朵茉莉花",self.match,self.flower];
        
        [self.view layoutIfNeeded];
        [self.view setNeedsLayout];
        
    } failure:^(NSError *error) {
        self.requestStatus = NO;
        
        if (error.code == 200024) {
            [[UIApplication sharedApplication].delegate.window ja_makeToast:error.localizedDescription];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

// 设置UI
- (void)setupTaskCheckVoiceView
{
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    _scrollView = scrollView;
    scrollView.bounces = NO;
    [self.view addSubview:scrollView];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    _imageView = imageView;
    UIImage *image = [UIImage imageNamed:@"branch_task_checkVoice"];
    UIImage *imageNormal = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.5 - 1, image.size.width * 0.5 - 1, image.size.height * 0.5 - 1, image.size.width * 0.5 - 1) resizingMode:UIImageResizingModeStretch];
    imageView.image = imageNormal;
    [scrollView addSubview:imageView];
    
    UILabel *topLabel = [[UILabel alloc] init];
    _topLabel = topLabel;
    topLabel.text = @" ";
    topLabel.textColor = HEX_COLOR(0x51BF9F);
    topLabel.font = JA_REGULAR_FONT(12);
    topLabel.numberOfLines = 0;
    topLabel.textAlignment = NSTextAlignmentCenter;
    [scrollView addSubview:topLabel];
    
    self.contentString = @"                     ";
    
    JAPaddingLabel *contentLabel = [[JAPaddingLabel alloc] init];
    _contentLabel = contentLabel;
    contentLabel.backgroundColor = [UIColor whiteColor];
    contentLabel.text = self.contentString;
    contentLabel.textColor = HEX_COLOR(0x4A4A4A);
    contentLabel.font = JA_MEDIUM_FONT(15);
    contentLabel.textAlignment = NSTextAlignmentCenter;
    contentLabel.numberOfLines = 0;
    contentLabel.edgeInsets = UIEdgeInsetsMake(35, 35, 35, 35);
    [scrollView addSubview:contentLabel];
    
    UIImageView *balloonImageView = [[UIImageView alloc] init];
    _balloonImageView = balloonImageView;
    balloonImageView.image = [UIImage imageNamed:@"branch_task_cv_balloon"];
    [scrollView addSubview:balloonImageView];
    
    SpectrumView *spectrumView2 = [[SpectrumView alloc] init];
    _spectrumView2 = spectrumView2;
//    spectrumView2.hidden = YES;
    [scrollView addSubview:self.spectrumView2];
    
    UILabel *statusLabel = [[UILabel alloc] init];
    _statusLabel = statusLabel;
    self.statusLabel.text = @"00:00";
    self.statusLabel.textColor = HEX_COLOR(0xffffff);
    self.statusLabel.font = JA_REGULAR_FONT(16);
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.hidden = YES;
    [scrollView addSubview:self.statusLabel];
    
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [scrollView addSubview:self.indicatorView];
    
    UIImageView *recordImageView = [[UIImageView alloc] init];
    _recordImageView = recordImageView;
    [self.recordImageView setImage:[UIImage imageNamed:@"input_record_speak"]];
    self.recordImageView.userInteractionEnabled = YES;
    self.longP = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(beginRecord:)];
    self.longP.minimumPressDuration = 0.2;
    [self.recordImageView addGestureRecognizer:self.longP];
    [scrollView addSubview:self.recordImageView];
    
    UILabel *bottomLabel = [[UILabel alloc] init];
    _bottomLabel = bottomLabel;
    bottomLabel.text = @"请保持语速连续顺畅";
    bottomLabel.textColor = HEX_COLOR(0xffffff);
    bottomLabel.font = JA_REGULAR_FONT(12);
    bottomLabel.numberOfLines = 0;
    bottomLabel.textAlignment = NSTextAlignmentCenter;
    [scrollView addSubview:bottomLabel];
}

- (void)caculatorTaskCheckVoiceViewFrame
{
    self.scrollView.frame = self.view.bounds;
    
    self.imageView.frame = self.scrollView.bounds;
    
    self.topLabel.width = JA_SCREEN_WIDTH - 30;
    [self.topLabel sizeToFit];
//    self.topLabel.width = JA_SCREEN_WIDTH;
    self.topLabel.y = WIDTH_ADAPTER(198);
    self.topLabel.x = 15;
    
    self.contentLabel.width = WIDTH_ADAPTER(240);
//    self.contentLabel.height = WIDTH_ADAPTER(170);
    [self.contentLabel sizeToFit];
    self.contentLabel.centerX = self.scrollView.width * 0.5;
    self.contentLabel.y = self.topLabel.bottom + WIDTH_ADAPTER(20);
    self.contentLabel.layer.borderColor = HEX_COLOR(0x51BF9F).CGColor;
    self.contentLabel.layer.borderWidth = 2;
    self.contentLabel.layer.cornerRadius = 9;
    self.contentLabel.layer.masksToBounds = YES;
    
    self.balloonImageView.width = WIDTH_ADAPTER(63);
    self.balloonImageView.height = WIDTH_ADAPTER(81);
    self.balloonImageView.y = self.topLabel.bottom + WIDTH_ADAPTER(8);
    self.balloonImageView.centerX = self.contentLabel.x;
 
    self.spectrumView2.width = 150;
    self.spectrumView2.height = 40;
    self.spectrumView2.middleInterval = 50;
    self.spectrumView2.centerX = self.scrollView.width * 0.5;
    self.spectrumView2.y = self.contentLabel.bottom + WIDTH_ADAPTER(15);
    
    self.statusLabel.width = 45;
    self.statusLabel.height = 22;
    self.statusLabel.centerX = self.scrollView.width * 0.5;
    self.statusLabel.centerY = self.spectrumView2.centerY;
    
    // 设置指示器位置
    self.indicatorView.centerX = self.spectrumView2.centerX;
    self.indicatorView.centerY = self.spectrumView2.centerY;
    
    self.recordImageView.width = 80;
    self.recordImageView.height = self.recordImageView.width;
    self.recordImageView.centerX = self.spectrumView2.centerX;
    self.recordImageView.y = self.spectrumView2.bottom + WIDTH_ADAPTER(5);
    
    self.bottomLabel.width = JA_SCREEN_WIDTH;
    self.bottomLabel.height = 17;
    self.bottomLabel.y = self.recordImageView.bottom + WIDTH_ADAPTER(13);
    
    CGFloat height = (self.bottomLabel.bottom + 20) > (JA_SCREEN_HEIGHT - JA_StatusBarAndNavigationBarHeight) ? (self.bottomLabel.bottom + 20) : (JA_SCREEN_HEIGHT - JA_StatusBarAndNavigationBarHeight);
    self.scrollView.contentSize = CGSizeMake(0, height);
    self.imageView.height = self.scrollView.contentSize.height;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self caculatorTaskCheckVoiceViewFrame];
}

- (void)beginRecord:(UILongPressGestureRecognizer *)longP
{
    if (longP.state == UIGestureRecognizerStateBegan) {
        
        if (self.requestStatus == NO) {
            [self.view ja_makeToast:@"信息获取失败，请重试"];
            return;
        }
        
        if (self.checkCount >  (self.checkTotalCount - 1)) {
            [self.view ja_makeToast:@"抱歉，请明天再试"];
            return;
        }
        
        if (TARGET_IPHONE_SIMULATOR){
            
            [self.indicatorView startAnimating];
            [self.recordManager.iflyResults removeAllObjects];
            self.voiceDuration = 0;
            [self.recordManager inputRecordStart];   // 开始录制
            
//            [[NSNotificationCenter defaultCenter] addObserver:self
//                                                     selector:@selector(handleInterreption:)
//                                                         name:AVAudioSessionInterruptionNotification
//                                                       object:[AVAudioSession sharedInstance]];
          
        }else{
            if ([JAPermissionHelper systemPermissionsWithVoice] == BBEPermissionsStatusAuthorize) {
                [self.indicatorView startAnimating];
                [self.recordManager.iflyResults removeAllObjects];
                self.voiceDuration = 0;
                [self.recordManager performSelector:@selector(inputRecordStart) withObject:nil afterDelay:0.0f inModes:@[NSRunLoopCommonModes]];
                
//                [[NSNotificationCenter defaultCenter] addObserver:self
//                                                         selector:@selector(handleInterreption:)
//                                                             name:AVAudioSessionInterruptionNotification
//                                                           object:[AVAudioSession sharedInstance]];
              
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
}

#pragma mark -  录制试听管理者 录制的代理回调
- (void)inputRecordWithDuration:(CGFloat)duration volume:(CGFloat)volume drawVolume:(CGFloat)drawVolume
{
    // 大于1分钟 就停止
    if ((duration - 60) > 0.f) {
        // 完成录音
        [self endRecordVoice];
        return;
    }
    
    
    if (self.indicatorView.isAnimating && drawVolume > 0) {
        [self.indicatorView stopAnimating];
    }
    self.spectrumView2.level = drawVolume;
    
    
    // 绘制时间和音量动画
    NSString *time = [NSString stringWithFormat:@"%02d:%02d",(int)duration/60,(int)duration%60];
    
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
    
    // 上传音频文件 - 录音文字到服务器
    if (self.recordManager.recordFile.length) {  // 有效音频文件
        
        if (self.voiceDuration > 0) {
            
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                
                NSString *string = [self.recordManager.iflyResults componentsJoinedByString:@""];
                NSLog(@"*****%@",string);
                
                [self contentToserverWithMatch:string finishBlock:^(BOOL success, NSDictionary *result) {
                    
                    if (success) {
                        self.checkCount = [result[@"dayTimes"] integerValue];  // 鉴别次数
                        NSInteger successStatus = [result[@"checkResult"] integerValue];
                        NSInteger matchStatus = [result[@"matchResult"] integerValue];
                        
                        if (successStatus) {
                            NSString *title = [NSString stringWithFormat:@"恭喜你,匹配度高达%ld%%完成挑战！",matchStatus];
                            [self showAlertViewWithTitle:title subTitle:@"" buttonTitle:1 completion:^(BOOL complete) {
                                
                                [self.navigationController popViewControllerAnimated:YES];
                            }];
                            
                        }else{
                            if (self.checkCount > (self.checkTotalCount - 1)) {
                                [self.view ja_makeToast:@"抱歉,匹配度不足,请明天再试吧"];
                            }else{
                                NSString *title = [NSString stringWithFormat:@"抱歉,匹配度不足,你今天还有%ld次数",self.checkTotalCount-self.checkCount];
                                [self.view ja_makeToast:title];
                            }
                            
                        }
                        
                    }
                }];
               
            });
        }
       
    }else{
        [self.recordManager removeAvailFile];  // 移除无效的音频文件
        if (!self.recordManager.recordFile.length) {
            [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"无效的音频文件，请重录"];
        }
    }
    
    self.spectrumView2.hidden = YES;
    self.statusLabel.hidden = YES;
    
}

// 上传到服务器
- (void)contentToserverWithMatch:(NSString *)matchContent finishBlock:(void(^)(BOOL success, NSDictionary *result))finishBlock
{
    // 上传音频文件 到 阿里云  获取音频文件
    NSString *recordFile = self.recordManager.recordFile;
    // 上传到阿里云
    NSData *mp3Data = [NSData dataWithContentsOfFile:recordFile];
    if (mp3Data.length) {
        [MBProgressHUD showMessage:nil];
       
        [[JAUserApiRequest shareInstance] ali_upLoadData:mp3Data fileType:@"mp3" finish:^(NSString *filePath) {
            
            if (filePath.length) {
                NSString *fileUrl = [NSString stringWithFormat:@"%@",filePath];
                
                NSLog(@"%@",fileUrl);
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                if (matchContent.length) {
                    dic[@"voiceContent"] = matchContent;
                    dic[@"voiceUrl"] = fileUrl;
                }
                dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
                dic[@"contentId"] = self.contentId;
                [[JAVoiceCommonApi shareInstance] voice_checkVoiceContentToServer:dic success:^(NSDictionary *result) {
                   [MBProgressHUD hideHUD];
                    
                    
                    if (finishBlock) {
                        finishBlock(YES,result);
                    }
                    
                } failure:^(NSError *error) {
                    [MBProgressHUD hideHUD];
                    
                    [self.view ja_makeToast:error.localizedDescription];
                    
                    if (finishBlock) {
                        finishBlock(NO,nil);
                    }
                }];
                
            }
        }];
    }else{
        
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"无效的音频文件,请重录"];
    }
    
}

#pragma mark -  录制试听管理者 录制失败的代理回调
- (void)inputRecordFinishFaile
{
}
- (void)inputListenWithPlayDuration:(CGFloat)duration
{
    
}
@end
