//
//  JAVocieReleaseViewController.m
//  Jasmine
//
//  Created by xujin on 31/08/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JAVoiceReleaseViewController.h"
#import "BHPlaceholderTextView.h"
#import "XDLocationTool.h"
#import "JAVoiceApi.h"
#import "JAPersonalCenterViewController.h"
#import "JAReleaseStoryCountModel.h"
#import "JASampleHelper.h"
#import "JFImagePickerController.h"
#import "JAReleasePostManager.h"
#import "JAVoiceReleaseTopicViewController.h"
#import "JACommonSearchPeopleVC.h"
#import "JADataHelper.h"
#import "JAPlayLocalVoiceManager.h"
#import "JAVoicePlayerManager.h"
#import "JASelectCircleViewController.h"
#import "JAVoiceContentView.h"
#import "JAReleaseToolView.h"
#import "JARichEditorView.h"
#import "JARichContentUtil.h"
#import "JARichTextModel.h"
#import "JANewPlaySingleTool.h"

@interface JAVoiceReleaseViewController ()<
UINavigationControllerDelegate,
UIImagePickerControllerDelegate,
UIScrollViewDelegate,
AVAudioPlayerDelegate>

@property (nonatomic, assign) NSInteger maxImageCount;
@property (nonatomic, assign) BOOL disableButton;
// v2.5.5
@property (nonatomic, strong) NSMutableArray *localImageInfoArray;
@property (nonatomic, strong) NSMutableArray *atPersonArray;
@property (nonatomic, strong) UIButton *selectCircleButton;
@property (nonatomic, strong) UIView *circleView;
@property (nonatomic, strong) JAVoiceContentView *voiceContentView;
@property (nonatomic, strong) JARichEditorView *richEditorView;
@property (nonatomic, weak) JAReleaseToolView *toolView;

@end

@implementation JAVoiceReleaseViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [AppDelegate sharedInstance].releasevc = nil;
}

- (BOOL)fd_interactivePopDisabled  {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.maxContentLength = 30;
    self.localImageInfoArray = [NSMutableArray new];
    self.atPersonArray = [NSMutableArray new];
    
    [self setCenterTitle:@"编辑帖子"];
    if (self.storyType == 0) {
        [self setRightButtonEnable:NO];
        self.maxImageCount = 3;
    } else if (self.storyType == 1) {
        [self setRightButtonEnable:NO];
        self.maxImageCount = 20;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(richText_changeRightButtonHighlight) name:@"JARichTextCell_editText_5" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(richText_changeRightButton) name:@"JARichTextCell_editText_no5" object:nil];
    }

    [self setupScrollView];
    [self setupToolView];
    [self loadLocalData];

    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (kCLAuthorizationStatusDenied != status && kCLAuthorizationStatusRestricted != status)
    {
        [self locationSwitchAction:self.toolView.locationBGView];
    }
    if (self.city.length) {
        [self.toolView showLocationTitle:self.city isOpen:YES];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyWillShowNote:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHidden) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playSingleProcess_refreshUI) name:@"STKAudioPlayerSingle_process" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playSingleFinish_refreshUI) name:@"STKAudioPlayerSingle_finish" object:nil];
    [AppDelegate sharedInstance].releasevc = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[JA_Property_ScreenName] = @"声音描述";
    [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:params];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.voiceContentView.contentTextView becomeFirstResponder];
    [self.richEditorView ja_becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[JAPlayLocalVoiceManager sharePlayVoiceManager] stopLocalVoice];
    [self.view endEditing:YES];
}

#pragma mark - PriviteMethods
- (void)loadLocalData {
    if (self.circleModel) {
        [self setCenterTitle:[NSString stringWithFormat:@"发布到%@圈",self.circleModel.circleName]];
        
//        3.1.0以前的圈子选择
//        [self.selectCircleButton setTitle:self.circleModel.circleName forState:UIControlStateNormal];
    }
    if (self.storyType == 0) {
        if (self.topicModel.title.length) {
            // v2.5.4 从话题界面进入
            self.voiceContentView.contentTextView.text = [NSString stringWithFormat:@"%@ ",self.topicModel.title];
        } else {
            // v2.5.5 从草稿箱进入
            if (self.content.length) {
                self.voiceContentView.contentTextView.text = self.content;
            }
            if (self.imageInfoArray.count) {
                // 兼容老版的草稿箱的图片数据
                [self.imageInfoArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj isKindOfClass:[NSDictionary class]]) {
                        UIImage *image;
                        NSString *partFilePath = obj[@"localimage"];
                        if (partFilePath.length) {
                            NSString *localFilePath = [NSHomeDirectory() stringByAppendingPathComponent:partFilePath];
                            image = [[UIImage alloc] initWithContentsOfFile:localFilePath];
                        }
                        NSString* localImageName = partFilePath.lastPathComponent;
                        JARichImageModel *imageModel = [JARichImageModel new];
                        imageModel.image = image;
                        imageModel.imageSize = image.size;
                        imageModel.localImageName = localImageName;
                        [self.localImageInfoArray addObject:imageModel];
                    } else {
                        [self.localImageInfoArray addObject:obj];
                    }
                }];
                [self reloadImages];
            }
        }
    } else if (self.storyType == 1) {
        if (self.topicModel.title.length) {
            // 从话题界面进入
            JARichTextModel *textModel = [JARichTextModel new];
            textModel.textContent = [NSString stringWithFormat:@"%@ ",self.topicModel.title];
            self.richEditorView.datas = [@[textModel] mutableCopy];
        } else {
            // 从草稿箱进入
            if (self.titleModel) {
                self.richEditorView.titleModel = self.titleModel;
            }
            if (self.richContentModels.count) {
                self.richEditorView.datas = self.richContentModels;
            }
        }
        [self.richEditorView.tableView reloadData];
    }
}

- (void)richText_changeRightButton
{
    [self setRightButtonEnable:NO];
}

- (void)richText_changeRightButtonHighlight
{
    [self setRightButtonEnable:YES];
}

- (void)setRightButtonEnable:(BOOL)enable {
    if (enable) {
        
        if (self.circleModel.circleId.length) {
            [self setNavRightTitle:@"发布" color:HEX_COLOR(JA_Green)];
        }else{
            [self setNavRightTitle:@"下一步" color:HEX_COLOR(JA_Green)];
        }
    } else {
        if (self.circleModel.circleId.length) {
            [self setNavRightTitle:@"发布" color:HEX_COLOR(0xe2e2e2)];
        }else{
            [self setNavRightTitle:@"下一步" color:HEX_COLOR(0xe2e2e2)];
        }
   
    }
}

- (void)hideKeyboard {
    [self.view endEditing:YES];
}

- (NSString *)convertTime:(CGFloat)totalSeconds
{
    int seconds = (int)totalSeconds % 60;
    int minutes = (int)(totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    if (hours>0) {
        return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
    } else {
        return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    }
}

#pragma mark - NaivigationBarAction
- (void)actionLeft {
    // v2.5.5
    if (self.fromType == 7) {
        // 从草稿箱进入，直接返回
        [self savePostDataAndNeedSend:NO];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    if (self.storyType == 1) {
        // 图文贴是否有内容
        if (![JARichContentUtil validataContentNotEmptyWithRichContents:self.richEditorView.datas isIgnoreImage:NO]) {
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"确定要放弃编辑吗？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *dropVoice = [UIAlertAction actionWithTitle:@"放弃编辑" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (self.storyType == 0) {
            NSMutableDictionary *params = [NSMutableDictionary new];
            params[JA_Property_RecordDuration] = @((int)self.time);
            // v2.5.5 新增
            params[JA_Property_BindingType] = @"放弃录音";
            [JASensorsAnalyticsManager sensorsAnalytics_dropPost:params];
        } else if (self.storyType == 1) {
            
        }
        
        [self backToLastLastVC];
    }];
    UIAlertAction *saveVoice = [UIAlertAction actionWithTitle:@"保存到草稿箱" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (self.storyType == 0) {
            NSMutableDictionary *params = [NSMutableDictionary new];
            params[JA_Property_RecordDuration] = @((int)self.time);
            // v2.5.5 新增
            params[JA_Property_BindingType] = @"保存到草稿箱";
            [JASensorsAnalyticsManager sensorsAnalytics_dropPost:params];
        } else if (self.storyType == 1) {
            
        }
        [self savePostDataAndNeedSend:NO];
        [self backToLastLastVC];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (self.storyType == 0) {
            NSMutableDictionary *params = [NSMutableDictionary new];
            params[JA_Property_RecordDuration] = @((int)self.time);
            // v2.5.5 新增
            params[JA_Property_BindingType] = @"取消";
            [JASensorsAnalyticsManager sensorsAnalytics_dropPost:params];
        } else if (self.storyType == 1) {
            
        }
    }];
    [alertController addAction:dropVoice];
    [alertController addAction:saveVoice];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

// 返回上上级页面
- (void)backToLastLastVC {
    if (self.storyType == 0) {
        if (self.navigationController.viewControllers.count < 3) {
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        NSInteger backIndex = self.navigationController.viewControllers.count-1-2;
        if (backIndex < self.navigationController.viewControllers.count) {
            id vc = self.navigationController.viewControllers[backIndex];
            [self.navigationController popToViewController:vc animated:YES];
        }
    } else if (self.storyType == 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)actionRight
{
    if (self.circleModel.circleId.length) {
        // 正常发帖
        [self savePostDataAndNeedSend:YES];
    }else{
        
        if ([self isCanGoOn]) {
              //选择圈子
            
            [self selectCircleButtonAction];
        }
        
    }
   
}
//如果信息都填写了
-(BOOL)isCanGoOn{
    if (self.storyType == 0) {
        NSString *inputContent = [self.voiceContentView.contentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (!inputContent.length) {
            [self.view ja_makeToast:@"声音描述不能为空"];
            return NO;
        }
        int caculaterCount = [NSString caculaterName:self.voiceContentView.contentTextView.text];
        if (caculaterCount > self.maxContentLength) {
            [self.view ja_makeToast:[NSString stringWithFormat:@"字数不能超过%d字哦",(int)self.maxContentLength]];
            return NO;
        }
    } else if (self.storyType == 1) {
        NSInteger textCount = [JARichContentUtil getTextCount:self.richEditorView.datas];
        NSString *toast = @"";
        if (textCount < 5) {
            toast = @"正文不能少于5个字哦";
        }
        if (textCount > 5000) {
            toast = @"正文不能多于5000个字哦";
        }
        if (toast.length) {
            [self.view ja_makeToast:toast];
            return NO;
        }
    }
    return YES;
}
- (void)savePostDataAndNeedSend:(BOOL)isSend {
    if (isSend) {
        if (!self.circleModel.circleId.length) {
            [self.view ja_makeToast:@"请选择要发布到的圈子"];
            return;
        }
        if (self.storyType == 0) {
            NSString *inputContent = [self.voiceContentView.contentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (!inputContent.length) {
                [self.view ja_makeToast:@"声音描述不能为空"];
                return;
            }
            int caculaterCount = [NSString caculaterName:self.voiceContentView.contentTextView.text];
            if (caculaterCount > self.maxContentLength) {
                [self.view ja_makeToast:[NSString stringWithFormat:@"字数不能超过%d字哦",(int)self.maxContentLength]];
                return;
            }
        } else if (self.storyType == 1) {
            NSInteger textCount = [JARichContentUtil getTextCount:self.richEditorView.datas];
            NSString *toast = @"";
            if (textCount < 5) {
                toast = @"正文不能少于5个字哦";
            }
            if (textCount > 5000) {
                toast = @"正文不能多于5000个字哦";
            }
            if (toast.length) {
                [self.view ja_makeToast:toast];
                return;
            }
        }
    }
    if (self.disableButton) {
        return;
    }
    [self.view endEditing:YES];
    self.disableButton = YES;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self saveDraft:isSend];
    });
}

- (void)saveDraft:(BOOL)isSend
{
    NSString *locationString = self.toolView.locationTitleLabel.text;
    NSString *isAnonymousString = self.toolView.anonymousButton.selected?@"1":nil;
    NSString *inputContent = [self.voiceContentView.contentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    JAPostDraftModel *draftModel = [JAPostDraftModel new];
    if (self.fromType == 7)  {
        // 草稿箱进入读取原来的数据
        draftModel = self.postDraftModel;
    } else {
    }
    draftModel.userId = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    NSString *city = locationString;
    
    if (![city isEqualToString:@"你在哪里?"]) {
        NSString *longitude = [NSString stringWithFormat:@"%.6f", [JAConfigManager shareInstance].location.coordinate.longitude];
        NSString *latitude = [NSString stringWithFormat:@"%.6f", [JAConfigManager shareInstance].location.coordinate.latitude];
        if (![JAConfigManager shareInstance].location) {
            longitude = @"0.0";
            latitude = @"0.0";
        }
        draftModel.longitude = longitude;
        draftModel.latitude = latitude;
        draftModel.city = [JAConfigManager shareInstance].city;
    }
    draftModel.isAnonymous = isAnonymousString;
    draftModel.sampleZip = [JASampleHelper getSampleZipStringWithAllPeakLevelQueue:self.allPeakLevelQueue];
    draftModel.createTime = [NSDate date];
    // v2.5.5
    if (isSend) {
        draftModel.dataType = 0;
    } else {
        draftModel.dataType = 1;
    }
    // v2.6.0
    [self wrapAtList:draftModel inputContent:inputContent];
    // v3.0.0
    draftModel.storyType = self.storyType;
    draftModel.circle = self.circleModel;
    
    if (self.storyType == 0) {
        if (self.localImageInfoArray.count) {
            draftModel.imageInfoArray = self.localImageInfoArray;
        }
        // 把录音文件copy到缓存目录
        NSString *uuidString = [[NSUUID UUID] UUIDString];
        NSString *recordFile = [NSString ja_getUploadVoiceFilePath:[NSString stringWithFormat:@"%@.mp3",uuidString]];
        
        NSString *sourceRecordFile = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"record"] stringByAppendingPathExtension:@"mp3"];
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        [fileMgr copyItemAtPath:[sourceRecordFile stringByReplacingOccurrencesOfString:@"%20" withString:@" "] toPath:recordFile error:nil];
        
        draftModel.localAudioUrl = [NSString stringWithFormat:@"Library/Caches/UploadVoice/%@.mp3",uuidString];// NSHomeDirectory（）重启会改变
        draftModel.audioUrl = @"";
        draftModel.time = [self convertTime:self.time];
        draftModel.content = inputContent;
    } else if (self.storyType == 1) {
        draftModel.titleModel = self.richEditorView.titleModel;
        draftModel.richContentModels = self.richEditorView.datas;
    }
    
    [draftModel updateToDB]; // 如果不存在会调用saveToDB
    if (isSend) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshVoiceModel" object:@{@"method":@(1)}];
            [[JAReleasePostManager shareInstance] asyncReleasePost:draftModel method:1];
            [self backToLastLastVC];
        });
    } else {
        // 草稿箱新增数据
        [[NSNotificationCenter defaultCenter] postNotificationName:@"JA_DraftCountChange" object:nil];
    }
}

- (void)wrapAtList:(JAPostDraftModel *)draftModel inputContent:(NSString *)inputContent {
    __block NSMutableArray *atList = [NSMutableArray new];
    if (self.storyType == 0) {
        atList = [self getAtList:inputContent];
    } else if (self.storyType == 1) {
        [self.richEditorView.datas enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[JARichTextModel class]]) {
                JARichTextModel *textModel = (JARichTextModel *)obj;
                atList = [self getAtList:textModel.textContent];
            }
        }];
    }
    if (atList.count) {
        draftModel.atPersonInfoArray = atList;
    }
}

- (NSMutableArray *)getAtList:(NSString *)text {
    if (!text.length) {
        return [NSMutableArray new];
    }
    NSMutableArray *atList = [NSMutableArray new];
    NSArray *userHandles = [JADataHelper getRangesForUserHandles:text];
    for (NSTextCheckingResult *match in userHandles)
    {
        NSRange matchRange = [match range];
        NSString *string = [text substringWithRange:matchRange];
        for (JAConsumer *consumer in self.atPersonArray) {
            if ([string isEqualToString:[NSString stringWithFormat:@"@%@\b",consumer.name]]) {
                NSMutableDictionary *dic = [NSMutableDictionary new];
                dic[@"userId"] = consumer.userId;
                dic[@"userName"] = consumer.name;
                if (dic) {
                    [atList addObject:dic];
                    break;
                }
            }
        }
    }
    return atList;
}

#pragma mark - SetupUI
- (void)setupToolView {
    JAReleaseToolView *toolView = [[JAReleaseToolView alloc] initWithFrame:CGRectMake(0, JA_SCREEN_HEIGHT, JA_SCREEN_WIDTH, 79)];
    self.toolView = toolView;
    [self.view addSubview:toolView];
    
    [self.toolView.locationBGView addTarget:self action:@selector(locationSwitchAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolView.anonymousButton addTarget:self action:@selector(anonymousAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolView.keyboardButton addTarget:self action:@selector(keyboradButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.toolView.topicButton addTarget:self action:@selector(topicButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.toolView.atPersonButton addTarget:self action:@selector(atPersonButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.toolView.addPicButton addTarget:self action:@selector(addPhotoButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.toolView.anonymousButton.selected = self.isAnonymous;
}

- (void)setupScrollView {
//    UIView *circleView = [UIView new];
//    [self.view addSubview:circleView];
//    [circleView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.left.right.offset(0);
//        make.height.offset(44);
//    }];
//    self.circleView = circleView;
    
//    UILabel *releaseLabel = [UILabel new];
//    releaseLabel.backgroundColor = [UIColor clearColor];
//    releaseLabel.font = JA_MEDIUM_FONT(16);
//    releaseLabel.textColor = HEX_COLOR(JA_BlackTitle);
//    releaseLabel.text = @"发布到";
//    [circleView addSubview:releaseLabel];
//    [releaseLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(circleView.mas_centerY);
//        make.left.offset(15);
//    }];
//
//    UIButton *selectCircleButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    selectCircleButton.titleLabel.font = JA_MEDIUM_FONT(16);
//    [selectCircleButton setTitle:@"请选择圈子" forState:UIControlStateNormal];
//    [selectCircleButton setTitleColor:HEX_COLOR(JA_Green) forState:UIControlStateNormal];
//    [selectCircleButton addTarget:self action:@selector(selectCircleButtonAction) forControlEvents:UIControlEventTouchUpInside];
//    [circleView addSubview:selectCircleButton];
//    [selectCircleButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(circleView.mas_centerY);
//        make.left.equalTo(releaseLabel.mas_right).offset(10);
//        make.width.lessThanOrEqualTo(@160);
//    }];
//    self.selectCircleButton = selectCircleButton;
//
//    UIImageView *triangleImageView = [UIImageView new];
//    triangleImageView.image = [UIImage imageNamed:@"release_triangle"];
//    [circleView addSubview:triangleImageView];
//    [triangleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(circleView.mas_centerY);
//        make.left.equalTo(self.selectCircleButton.mas_right).offset(5);
//    }];
//
//    UIView *lineView = [UIView new];
//    lineView.backgroundColor = HEX_COLOR(JA_Line);
//    [circleView addSubview:lineView];
//    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(circleView.mas_bottom);
//        make.left.right.offset(0);
//        make.height.offset(1);
//    }];
    if (self.storyType == 0) {
        self.voiceContentView = [[JAVoiceContentView alloc] initWithSuperVC:self];
        [self.view addSubview:self.voiceContentView];
        [self.voiceContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top);
            make.left.right.offset(0);
            make.height.offset(JA_SCREEN_HEIGHT-JA_StatusBarAndNavigationBarHeight-JA_TabbarSafeBottomMargin-44-44);
        }];
        
        self.voiceContentView.scrollView.delegate = self;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
        [self.voiceContentView.scrollView addGestureRecognizer:tap];
        
        self.voiceContentView.wordCountL.text = [NSString stringWithFormat:@"0/%zd",self.maxContentLength];
        
        [self.voiceContentView.addPhotoButton addTarget:self action:@selector(addPhotoButtonAction) forControlEvents:UIControlEventTouchUpInside];
        
        // 录音
#warning TODO:
        [self.voiceContentView setNeedsLayout];
        [self.voiceContentView layoutIfNeeded];
        [self.voiceContentView.voiceBGView.waveView wave_animateWithTotalArray:self.allPeakLevelQueue progress:0];
        self.voiceContentView.voiceBGView.durationLabel.text = [NSString stringWithFormat:@"%02d:%02d",(int)self.time/60,(int)self.time%60];
//        [self.voiceContentView.voiceBGView.playButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        UITapGestureRecognizer *playTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playButtonAction)];
        [self.voiceContentView.voiceBGView addGestureRecognizer:playTap];
        int h = 40;
        int w = h;
        NSString *url = [[JAUserInfo userInfo_getUserImfoWithKey:User_ImageUrl] ja_getFitImageStringWidth:w height:h];
        [self.voiceContentView.voiceBGView.headImageView ja_setImageWithURLStr:url];
    } else if (self.storyType == 1) {
        JARichEditorView *richEditorView = [JARichEditorView new];
        @WeakObj(self);
        richEditorView.hiddenActionButtons = ^(BOOL hidden) {
            @StrongObj(self);
            [self.toolView setHiddenActionButtons:hidden];
        };
        richEditorView.pushSearchTopicVC = ^{
            @StrongObj(self);
            [self pushSearchTopicVC:YES];
        };
        richEditorView.pushAtPersonVC = ^{
            @StrongObj(self);
            [self pushAtPersonVC:YES];
        };
        [self.view addSubview:richEditorView];
        [richEditorView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(circleView.mas_bottom);
             make.top.equalTo(self.view.mas_top);
            make.left.right.offset(0);
            make.height.offset(JA_SCREEN_HEIGHT-JA_StatusBarAndNavigationBarHeight-JA_TabbarSafeBottomMargin-44-44);
        }];
        self.richEditorView = richEditorView;
    }
}

#pragma mark - Notification
- (void)keyboardDidShow:(NSNotification *)notification  {
    self.toolView.keyboardButton.selected = YES;
}

- (void)keyboardDidHidden {
    self.toolView.keyboardButton.selected = NO;
}

- (void)onKeyWillShowNote:(NSNotification *)note{
    NSValue *value = [note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect rect = [value CGRectValue];
    CGRect keyboardRectInkeyView = [self.view convertRect:rect fromView:nil];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    [UIView animateWithDuration:[duration doubleValue] animations:^{
        if (rect.origin.y == JA_SCREEN_HEIGHT) {
            self.toolView.y = keyboardRectInkeyView.origin.y-self.toolView.height-JA_TabbarSafeBottomMargin;
            if (self.storyType == 0) {
                [self.toolView setHiddenActionButtons:NO];
            } else if (self.storyType == 1) {
                [self.toolView setHiddenActionButtons:YES];
            }
        } else {
            self.toolView.y = keyboardRectInkeyView.origin.y-self.toolView.height;
        }
        [self.richEditorView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top);
            make.left.right.offset(0);
            make.height.offset(self.toolView.y-44);
        }];
        [self.view layoutIfNeeded];
    }];
}

- (void)playSingleProcess_refreshUI
{
    if ([JANewPlaySingleTool shareNewPlaySingleTool].totalDuration <= 0) {
        return;
    }
    // 计算进度
    CGFloat p = [JANewPlaySingleTool shareNewPlaySingleTool].currentDuration / [JANewPlaySingleTool shareNewPlaySingleTool].totalDuration;
    [self.voiceContentView.voiceBGView.waveView wave_animateWithTotalArray:self.allPeakLevelQueue progress:p];
    NSTimeInterval curDuration = [JANewPlaySingleTool shareNewPlaySingleTool].totalDuration - [JANewPlaySingleTool shareNewPlaySingleTool].currentDuration;
    if (curDuration > 0) {
        self.voiceContentView.voiceBGView.durationLabel.text = [NSString stringWithFormat:@"%02d:%02d",(int)curDuration/60,(int)curDuration%60];
    }
}

- (void)playSingleFinish_refreshUI
{
    [self.voiceContentView.voiceBGView.waveView wave_animateWithTotalArray:self.allPeakLevelQueue progress:0];
    self.voiceContentView.voiceBGView.playButton.selected = NO;
    self.voiceContentView.voiceBGView.durationLabel.text = [NSString stringWithFormat:@"%02d:%02d",(int)self.time/60,(int)self.time%60];
}

#pragma mark - ButtonAction
// 选择圈子
- (void)selectCircleButtonAction {
    JASelectCircleViewController *vc = [JASelectCircleViewController new];
    @WeakObj(self);
    vc.selectedCircleBlock = ^(JACircleModel *model) {
        @StrongObj(self);
//        [self.selectCircleButton setTitle:model.circleName forState:UIControlStateNormal];
        self.circleModel = model;
    };
    vc.postBlock = ^{
//      发布
         @StrongObj(self);
        [self savePostDataAndNeedSend:YES];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

// 开启定位
- (void)locationSwitchAction:(UIButton *)sender {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (kCLAuthorizationStatusDenied == status || kCLAuthorizationStatusRestricted == status)
    {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"打开[定位服务权限]来允许茉莉确定您的位置"
                                                                                 message:@"请在系统设置中开启定位服务(设置>隐私>定位服务>开启)"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            //跳转到定位权限页面
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if( [[UIApplication sharedApplication]canOpenURL:url] ) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }];
        [alertController addAction:cancel];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        sender.selected = !sender.selected;
        if (sender.selected) {
            NSString *city = [JAConfigManager shareInstance].city;
            if (city.length) {
                //                self.locationLabel.text = city;
                [self.toolView showLocationTitle:city isOpen:YES];
            } else {
                @WeakObj(self);
                [[XDLocationTool sharedXDLocationTool] getCurrentLocation:^(CLLocation *location, CLPlacemark *pl, NSString *error) {
                    @StrongObj(self);
                    if (location) {
                        
                        [JAConfigManager shareInstance].location = location;
                        if (pl) {
                            //获取城市
                            NSString *city = pl.locality;
                            if (!city) {
                                //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                                city = pl.administrativeArea;
                            }
                            [JAConfigManager shareInstance].city = city;
                            NSString *province = pl.administrativeArea;
                            if (!province) {
                                //四大直辖市的城市信息无法通过administrativeArea获得只能通过locality来获得
                                province = pl.locality;
                            }
                            [JAConfigManager shareInstance].province = province;
                            [JAConfigManager shareInstance].area = pl.subLocality;
                            //                            self.locationLabel.text = city;
                            [self.toolView showLocationTitle:city isOpen:YES];
                        }
                    } else {
                        CLLocation *location = [CLLocation new];
                        [JAConfigManager shareInstance].location = location;
                    }
                }];
            }
            
            
        } else {
            //            self.locationLabel.text = @"分享地理位置";
            [self.toolView showLocationTitle:@"你在哪里?" isOpen:NO];
        }
    }
}

- (void)anonymousAction:(UIButton *)sender {
    UIAlertController *alert = nil;
    if (sender.selected) {
        alert = [UIAlertController alertControllerWithTitle:@"确定停用匿名？" message:@"停用匿名后，您在该主帖的所有回复都将切换为实名状态" preferredStyle:UIAlertControllerStyleAlert];
    } else {
        alert = [UIAlertController alertControllerWithTitle:@"确定启用匿名？" message:@"启用匿名后，您在该主帖的所有回复都将切换为匿名状态" preferredStyle:UIAlertControllerStyleAlert];
    }
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        sender.selected = !sender.selected;
    }];
    
    [alert addAction:action1];
    [alert addAction:action2];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)keyboradButtonAction {
    if (self.toolView.keyboardButton.selected) {
        [self.view endEditing:YES];
    } else {
        [self.voiceContentView.contentTextView becomeFirstResponder];
        [self.richEditorView ja_becomeFirstResponder];
    }
}

- (void)topicButtonAction {
    [self pushSearchTopicVC:NO];
}

- (void)pushSearchTopicVC:(BOOL)isAuto {
    @WeakObj(self);
    JAVoiceReleaseTopicViewController *vc = [JAVoiceReleaseTopicViewController new];
    
    vc.selectedTopic = ^(JAVoiceTopicModel *topicModel) {
        @StrongObj(self);
        if (isAuto && topicModel.title.length) {
            NSString *firstChar = [topicModel.title substringToIndex:1];
            if ([firstChar isEqualToString:@"#"]) {
                topicModel.title = [topicModel.title substringFromIndex:1];
            }
        }
        NSString *insertString = [NSString stringWithFormat:@"%@ ", topicModel.title];
        if (self.storyType == 0) {
            self.dontChangeRange = YES;
            self.lastRange = NSMakeRange(self.voiceContentView.contentTextView.selectedRange.location+insertString.length, self.voiceContentView.contentTextView.selectedRange.length);

            NSMutableString *mutableString = [[NSMutableString alloc] initWithString:self.voiceContentView.contentTextView.text];
            [mutableString insertString:insertString atIndex:self.voiceContentView.contentTextView.selectedRange.location];
            self.voiceContentView.contentTextView.text = mutableString;
        } else if (self.storyType == 1) {
            [self.richEditorView appendText:insertString];
        }
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)atPersonButtonAction {
    [self pushAtPersonVC:NO];
}

- (void)pushAtPersonVC:(BOOL)isAuto {
    @WeakObj(self);
    JACommonSearchPeopleVC *vc = [JACommonSearchPeopleVC new];
    vc.fromType = 1;
    vc.selectBlock = ^(JAConsumer *consumer) {
        @StrongObj(self);
        NSString *insertString = nil;
        if (isAuto) {
            insertString = [NSString stringWithFormat:@"%@\b ", consumer.name];
        }else{
            insertString = [NSString stringWithFormat:@"@%@\b ", consumer.name];
        }
        if (self.storyType == 0) {
            // 插入@后需要修改光标位置
            self.dontChangeRange = YES;
            self.lastRange = NSMakeRange(self.voiceContentView.contentTextView.selectedRange.location+insertString.length,                           self.voiceContentView.contentTextView.selectedRange.length);
            
            NSMutableString *mutableString = [[NSMutableString alloc] initWithString:self.voiceContentView.contentTextView.text];
            [mutableString insertString:insertString atIndex:self.voiceContentView.contentTextView.selectedRange.location];
            self.voiceContentView.contentTextView.text = mutableString;
        } else if (self.storyType == 1) {
            [self.richEditorView appendText:insertString];
        }
        // 将@过的人填入数组保存，为发布时给后台拼接数据做准备
        [self.atPersonArray addObject:consumer];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)addPhotoButtonAction {
    NSInteger imageCount = 0;
    if (self.storyType == 0) {
        imageCount = self.localImageInfoArray.count;
    } else if (self.storyType == 1) {
        imageCount = [self.richEditorView addImageCount];
    }
    if (imageCount >= self.maxImageCount)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"最多可选%zd张图片",self.maxImageCount] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    JFImagePickerController *picker = [[JFImagePickerController alloc] initWithRootViewController:self];
    picker.maxCount = self.maxImageCount - imageCount;
    picker.pickerDelegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

// 播放录音
- (void)playButtonAction{
//    sender.selected = !sender.selected;
    self.voiceContentView.voiceBGView.playButton.selected = !self.voiceContentView.voiceBGView.playButton.selected;
    NSString *recordFile = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"record"] stringByAppendingPathExtension:@"mp3"];
    if (self.localAudioUrl.length) {
        recordFile = [NSHomeDirectory() stringByAppendingPathComponent:self.localAudioUrl];
    }
    [[JANewPlaySingleTool shareNewPlaySingleTool] playSingleTool_playSingleMusicWithFileUrlString:recordFile model:nil playType:JANewPlaySingleToolType_local];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

#pragma mark - JFImagePicker Delegate -
- (void)imagePickerDidFinished:(JFImagePickerController *)picker
{
    [self loadAssets:picker.assets];
    // cancel picker
    [self imagePickerDidCancel:picker];
}

- (void)imagePickerDidTakePhotoFinished:(JFImagePickerController *)picker image:(UIImage *)image
{
    if (self.storyType == 0) {
        [self addImage:image];
        [self reloadImages];
    } else if (self.storyType == 1) {
        [self.richEditorView handleInsertImage:image];
    }
    // cancel picker
    [self imagePickerDidCancel:picker];
}

- (void)imagePickerDidCancel:(JFImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    [JFImagePickerController clear];
}

- (void)loadAssets:(NSArray *)assets
{
    @WeakObj(self)
    for (ALAsset *asset in assets)
    {
        [[JFImageManager sharedManager] imageWithAsset:asset resultHandler:^(CGImageRef imageRef, BOOL longImage) {
            @StrongObj(self)
            UIImage *image = [UIImage imageWithCGImage:imageRef];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.storyType == 0) {
                    [self addImage:image];
                    [self reloadImages];
                } else if (self.storyType == 1) {
                    [self.richEditorView handleInsertImage:image];
                }
            });
        }];
    }
}

- (void)reloadImages {
    [self.voiceContentView.photoScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    CGFloat offsetX = 0;
    CGFloat lastOffsetX = 0;
    for (int i=0; i<self.localImageInfoArray.count; i++) {
        offsetX = i*(80+12)+15;
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(offsetX, 0, 80, 85)];
        contentView.backgroundColor = [UIColor clearColor];
        [self.voiceContentView.photoScrollView addSubview:contentView];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, 80, 80)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        JARichImageModel *imageModel = self.localImageInfoArray[i];
        imageView.image = imageModel.image;
        [contentView addSubview:imageView];
        
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteButton setImage:[UIImage imageNamed:@"release_removephoto"] forState:UIControlStateNormal];
        [deleteButton setImage:[UIImage imageNamed:@"release_removephoto"] forState:UIControlStateHighlighted];
        [deleteButton addTarget:self action:@selector(deleteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        deleteButton.tag = i;
        deleteButton.frame = CGRectMake(imageView.right-18, 0, 20, 20);
        [contentView addSubview:deleteButton];
        
        lastOffsetX = contentView.right;
    }
    if (self.localImageInfoArray.count<self.maxImageCount) {
        self.voiceContentView.addPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        if (self.localImageInfoArray.count) {
            self.voiceContentView.addPhotoButton.frame = CGRectMake(lastOffsetX+7, 5, 80, 80);
        } else {
            self.voiceContentView.addPhotoButton.frame = CGRectMake(15, 5, 80, 80);
        }
        [self.voiceContentView.addPhotoButton setImage:[UIImage imageNamed:@"release_addphoto"] forState:UIControlStateNormal];
        [self.voiceContentView.addPhotoButton addTarget:self action:@selector(addPhotoButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self.voiceContentView.photoScrollView addSubview:self.voiceContentView.addPhotoButton];
        
        self.voiceContentView.photoScrollView.contentSize = CGSizeMake(self.voiceContentView.addPhotoButton.right+15, 85);
    } else {
        self.voiceContentView.photoScrollView.contentSize = CGSizeMake(lastOffsetX+15, 85);
    }
    if (self.voiceContentView.photoScrollView.contentSize.width>JA_SCREEN_WIDTH) {
        [self.voiceContentView.photoScrollView setContentOffset:CGPointMake(self.voiceContentView.photoScrollView.contentSize.width-JA_SCREEN_WIDTH, 0) animated:NO];
    }
    if (self.localImageInfoArray.count) {
        self.voiceContentView.photoScrollView.hidden = NO;
    } else {
        self.voiceContentView.photoScrollView.hidden = YES;
    }
}

// 语音帖删除图片
- (void)deleteButtonAction:(UIButton *)sender {
    NSInteger index = sender.tag;
    if (index < self.localImageInfoArray.count) {
        JARichImageModel *imageModel = self.localImageInfoArray[index];
        [JARichContentUtil deleteImageContent:imageModel];
        [self.localImageInfoArray removeObjectAtIndex:index];
        [self reloadImages];
    }
}

// 语音帖添加图片
- (void)addImage:(UIImage *)image {
    if (image) {
        NSString* localImageName = [JARichContentUtil saveImageToLocal:image];
        JARichImageModel *imageModel = [JARichImageModel new];
        imageModel.image = image;
        imageModel.imageSize = image.size;
        imageModel.localImageName = localImageName;
        [self.localImageInfoArray addObject:imageModel];
    }
}

@end

