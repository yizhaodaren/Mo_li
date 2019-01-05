//
//  JAInputView.m
//  Jasmine
//
//  Created by 刘宏亮 on 2017/12/7.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAInputView.h"
#import "JAInputToolBar.h"
#import "JARecordInputView.h"
#import "JAUserApiRequest.h"
#import "JAInputHideButton.h"
#import "JACommonSearchPeopleVC.h"
#import "JADataHelper.h"
#import "CYLTabBarController.h"

#define kTopMargn ((iPhoneX) ? 88 : 64)
#define kBottomMargn 0 //((iPhoneX && _inputInitial == JAInputInitialLocalTypeHiden) ? 34 : 0)

@interface JAInputView ()<JAInputToolBarDelegate,JARecordInputViewDelegate>

@property (nonatomic, strong) JAInputHideButton *hideButton;  // 隐藏按钮
@property (nonatomic, strong) UIButton *wordKeyBoardButton;  // 文字键盘按钮
@property (nonatomic, strong) JAInputToolBar *toolBar;
@property (nonatomic, strong) JARecordInputView *recordInputView;

@property (nonatomic, assign) CGFloat keyBoardHeight;


@property (nonatomic, strong) UIView *coverView;   // 遮罩 view

@property (nonatomic, assign) BOOL hasVoiceFile;  // 是否有有音频文件

// 2.6.0
@property (nonatomic, assign) NSRange lastRange; // 改变颜色后，光标会跳转到尾部
@property (nonatomic, assign) BOOL dontMove;
@property (nonatomic, assign) NSRange frontSelectRange;

@property (nonatomic, strong) NSMutableArray *allAtPerson;
@end

@implementation JAInputView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _allAtPerson = [NSMutableArray array];
        
        self.clipsToBounds = YES;
        self.keyBoardHeight = 252 + kBottomMargn;
        [self setupInputViewUI];
        self.backgroundColor = [UIColor whiteColor];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardhiden:) name:UIKeyboardWillHideNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateToolBarFrame) name:@"JAToolBarDidChangeFrameNotification" object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupInputViewUI
{
    
    self.toolBar = [[JAInputToolBar alloc] init];
    self.toolBar.nim_textView.enablesReturnKey = NO;
    self.toolBar.width = JA_SCREEN_WIDTH;
    self.toolBar.height = 50;
    self.toolBar.delegate = self;
    [self.toolBar.publishButton addTarget:self action:@selector(clickPublishButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolBar.recordButton addTarget:self action:@selector(clickRecordButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolBar.atButton addTarget:self action:@selector(clickatButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.toolBar];
    
    self.recordInputView = [[JARecordInputView alloc] init];
    self.recordInputView.y = self.toolBar.bottom + 1;
    self.recordInputView.delegate = self;
    [self addSubview:self.recordInputView];
    
    // 2.5.7 透明的按钮 -- 改变功能，根据点击区域
    self.hideButton = [JAInputHideButton buttonWithType:UIButtonTypeCustom];
    self.hideButton.backgroundColor = HEX_COLOR_ALPHA(0x000000, 0.0);
    self.hideButton.width = JA_SCREEN_WIDTH - 50;
    self.hideButton.height = 50;
    [self.hideButton addTarget:self action:@selector(clickHideButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.hideButton];
    
    self.inputInitial = JAInputInitialLocalTypeShow;
}

#pragma mark - 点击发布按钮（上传音频文件）
- (void)clickPublishButton:(UIButton *)btn
{
    if (!btn.selected) {
        
        if (self.hasVoiceFile) {
            [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"请输入文字标题"];
        }else{
            [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"请输入回复内容"];
        }
        return;
    }

    [self publishVoice];
}
#pragma mark - 点击键盘切换按钮
- (void)clickRecordButton:(UIButton *)btn
{
    if (btn.selected) {
        [self.toolBar.nim_textView becomeFirstResponder];
    }else{
        [self.toolBar.nim_textView resignFirstResponder];
    }

}

#pragma mark - 点击@按钮
- (void)clickatButton:(UIButton *)btn
{
    [self pushAtPersonVC:NO];
}

#pragma mark - 1 底部透明按钮的点击
- (void)clickHideButton:(JAInputHideButton *)btn
{
//    if (!IS_LOGIN) {
//        [JAAPPManager app_modalLogin];
//        return;
//    }
//
//    // 2.5.7 之前的功能
////    if (self.hasVoiceFile) {   // 有音频文件弹出文字键盘
////        [self.recordInputView becomeRecordInputView];
////        [self animateChangeFrame:self.toolBar.height + 252 + kBottomMargn duration:0.25];
////        [self.toolBar.nim_textView becomeFirstResponder];
////    }else{
////        [self.recordInputView becomeRecordInputView];
////        [self animateChangeFrame:self.toolBar.height + 252 + kBottomMargn duration:0.25];
////    }
////
////    if ([self.delegate respondsToSelector:@selector(inputViewClickSelf:)]) {
////        [self.delegate inputViewClickSelf:self];
////    }
//
//    // 2.5.7 之后的功能
////    CGRect rect = [self.toolBar.recordButton convertRect:self.toolBar.recordButton.frame toView:btn];
////    - (CGRect)convertRect:(CGRect)rect toView:(UIView *)view;
//
//    BOOL leftB = CGRectContainsPoint(self.toolBar.recordButton.frame, btn.touchPoint);
//    BOOL leftAt = CGRectContainsPoint(self.toolBar.atButton.frame, btn.touchPoint);
//
//    if (leftB) {  // 点击录音按钮弹起录制键盘
//
//        [self.recordInputView becomeRecordInputView];
//        [self animateChangeFrame:self.toolBar.height + 252 + kBottomMargn duration:0.25];
//
//    }else if (leftAt){  // 点击@按钮
//
//        [self pushAtPersonVC:NO];
//
//    }else{    // 点击右边弹起文字键盘
//
//        [self.recordInputView becomeRecordInputView];
//        [self animateChangeFrame:self.toolBar.height + 252 + kBottomMargn duration:0.25];
//        [self.toolBar.nim_textView becomeFirstResponder];
//
//    }
//    if ([self.delegate respondsToSelector:@selector(inputViewClickSelf:)]) {
//        [self.delegate inputViewClickSelf:self];
//    }
}


// 弹起文字键盘
- (void)callInputKeyBoard
{
    if (!IS_LOGIN) {
        [JAAPPManager app_modalLogin];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[JA_Property_BindingType] = @"回复";
        [JASensorsAnalyticsManager sensorsAnalytics_jumpRegistOrLoginPage:dic];
        return;
    }
    [self.recordInputView becomeRecordInputView];
    [self animateChangeFrame:self.toolBar.height + 252 + kBottomMargn duration:0.25];
    [self.toolBar.nim_textView becomeFirstResponder];
}
// 弹起录音键盘
- (void)callRecordKeyBoard
{
    if (!IS_LOGIN) {
        [JAAPPManager app_modalLogin];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[JA_Property_BindingType] = @"回复";
        [JASensorsAnalyticsManager sensorsAnalytics_jumpRegistOrLoginPage:dic];
        
        return;
    }
    [self.recordInputView becomeRecordInputView];
    [self animateChangeFrame:self.toolBar.height + 252 + kBottomMargn duration:0.25];
}

#pragma mark - 2 文字键盘弹起
- (void)keyBoardShow:(NSNotification *)note
{
    if (!self.window || self.hidden) {
        return;
    }
    
    if (![self isDisplayedInScreen]){
        return;
    }
    
    CGRect frame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.keyBoardHeight = frame.size.height;
    // 弹起
    [self animateChangeFrame:self.keyBoardHeight + self.toolBar.height + kBottomMargn duration:0.0];

    self.toolBar.recordButton.selected = NO;
}

#pragma mark - 3 文字键盘退下
- (void)keyBoardhiden:(NSNotification *)note
{
    if (![self isDisplayedInScreen]){
        return;
    }

    self.toolBar.recordButton.selected = YES;
    // 弹起
//    [self animateChangeFrame:252 + kBottomMargn + self.toolBar.height duration:0.0];
 
}

#pragma mark - 4 toolbar 输入文字高度的变化
- (void)updateToolBarFrame
{
    if (self.isRespondStatus) {
        
        [self animateChangeFrame:self.keyBoardHeight + self.toolBar.height + kBottomMargn duration:0.25];
    }else{
        [self animateChangeFrame:0 duration:0.25];
    }
    
}

- (void)animateChangeFrame:(CGFloat)height duration:(CGFloat)time
{
    if (self.height != height) {
        
        [UIView animateWithDuration:time animations:^{
            self.height = height;
            if ([self.delegate respondsToSelector:@selector(inputViewFrameChangeWithHeight:)]) {
                [self.delegate inputViewFrameChangeWithHeight:self.height];
            }

            self.toolBar.y = 0;
            self.hideButton.y = 0;
            self.recordInputView.y = self.toolBar.bottom + 1;
            self.hideButton.height = self.toolBar.height;

            CGFloat bottomM = 0;
            if (iPhoneX && !self.isRespondStatus) {
                bottomM = 34;
            }
            self.y = self.superview.height - self.height - bottomM;
            self.recordInputView.y = self.toolBar.bottom + 1;
        }];
    }
    
    if (self.isRespondStatus) {
        self.hideButton.hidden = YES;
        if (!self.toolBar.nim_textView.isFirstResponder) {
            self.toolBar.recordButton.selected = YES;
        }
    }else{
        self.hideButton.hidden = NO;
        self.toolBar.recordButton.selected = NO;
    }
    
    if (self.hasVoiceFile) {
        self.hasVoiceFile = YES;
    }else{
        self.hasVoiceFile = NO;
    }
    
    if (height > 0 && self.isRespondStatus) {
        UIViewController *v = [self currentViewController];
        [self addCover:NO height:v.view.height - height];
    }else{
        [self addCover:YES height:0];
    }
}


#pragma mark - 录制键盘的代理
- (void)recordInputViewWithFaile
{
//    [self addCover:YES height:0];
    [self.recordInputView resetInputRecord];
}

// 录制完成
- (void)recordInputViewWithFinishButton:(JARecordInputView *)recordInputView duration:(NSString *)durationString textResult:(NSMutableArray *)text
{
    // 1 把音频防止上面
    self.hasVoiceFile = YES;
    
    // 展示解析的文字
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (text.count && durationString.floatValue < JA_IFLY_Time) {
            NSString *string = nil;
            NSString *oldT = self.toolBar.nim_textView.text;
            if (oldT.length) {
                string = [NSString stringWithFormat:@"%@%@",oldT,[text componentsJoinedByString:@""]];
            }else{
                string = [text componentsJoinedByString:@""];
            }
            self.toolBar.nim_textView.text = string;
            self.toolBar.publishButton.selected = YES;
        }else{
            self.placeHolderText = @"请输入文字标题";   // 有两处该标题
        }
    });
    
//    [self addCover:YES height:0];
    
    if ([self.delegate respondsToSelector:@selector(input_sensorsAnalyticsFinishRecordWithRecordDuration:)]) {   // 神策统计完成
        [self.delegate input_sensorsAnalyticsFinishRecordWithRecordDuration:self.recordInputView.voiceDuration];
    }
    
}

// 重录按钮
- (void)recordInputViewWithCancleButton:(JARecordInputView *)recordInputView
{
    if (self.hasVoiceFile) {
        self.hasVoiceFile = NO;
    }
    
    if (self.toolBar.nim_textView.text.length) {
        self.toolBar.nim_textView.text = nil;
        self.toolBar.publishButton.selected = NO;
    }
    
    if ([self.delegate respondsToSelector:@selector(input_sensorsAnalyticsCancleRecordWithRecordDuration:)]) {   // 神策统计取消
        [self.delegate input_sensorsAnalyticsCancleRecordWithRecordDuration:self.recordInputView.voiceDuration];
    }
}

// 开始录制按钮
- (void)recordInputViewWithRecordButton:(JARecordInputView *)recordInputView buttonStatus:(JARecordStatusType)statusType
{
//    [self addCover:NO height:JA_SCREEN_HEIGHT - (252 + kBottomMargn)];
    if ([self.delegate respondsToSelector:@selector(input_sensorsAnalyticsBeginRecord)]) {  // 神策统计开始录音
        [self.delegate input_sensorsAnalyticsBeginRecord];
    }
}

#pragma mark - 跳转@控制器
- (void)pushAtPersonVC:(BOOL)isAuto {
    @WeakObj(self);
    JACommonSearchPeopleVC *vc = [JACommonSearchPeopleVC new];
    vc.fromType = 1;
    vc.selectBlock = ^(JAConsumer *consumer) {
        @StrongObj(self);

        NSMutableString *mutableString = [[NSMutableString alloc] initWithString:self.toolBar.nim_textView.text];
//        NSString *insertString = [NSString stringWithFormat:@"@%@\b ", consumer.name];
        NSString *insertString = nil;
        if (isAuto) {
            
            insertString = [NSString stringWithFormat:@"%@\b ", consumer.name];
        }else{
            insertString = [NSString stringWithFormat:@"@%@\b ", consumer.name];
        }
        [mutableString insertString:insertString atIndex:self.toolBar.nim_textView.selectedRange.location];
        [self.allAtPerson addObject:consumer];
        self.dontMove = YES;
        self.lastRange = NSMakeRange(self.toolBar.nim_textView.selectedRange.location+insertString.length,                           self.toolBar.nim_textView.selectedRange.length);
        self.toolBar.nim_textView.text = mutableString;
        
        // 弹窗键盘
        if (self.toolBar.recordButton.selected || !self.isRespondStatus) {
            [self.recordInputView becomeRecordInputView];
            [self animateChangeFrame:self.toolBar.height + 252 + kBottomMargn duration:0.25];
            [self.toolBar.nim_textView becomeFirstResponder];
        }
        
    };
    [[AppDelegateModel getBaseNavigationViewControll] pushViewController:vc animated:YES];
}

#pragma mark - 工具条（自定义textview）的代理

- (void)textViewDidChangeSelection_toolBar:(JAGrowingTextView *)growingTextView
{
    
//     判断光标的变化
    if (growingTextView.selectedRange.length > 0) {  // 两个光标

        if (self.frontSelectRange.location == 0 && self.frontSelectRange.length == 0) {
            self.frontSelectRange = growingTextView.selectedRange;
        }
        
        if (self.frontSelectRange.location != growingTextView.selectedRange.location) {  // 移动第一个光标

            NSArray *userHandles = [JADataHelper getRangesForUserHandles:growingTextView.text];
            for (NSTextCheckingResult *match in userHandles)
            {
                NSRange matchRange = [match range];
                if (growingTextView.selectedRange.location > matchRange.location && growingTextView.selectedRange.location < matchRange.location+matchRange.length) {
                    growingTextView.selectedRange = NSMakeRange(matchRange.location+matchRange.length, self.frontSelectRange.location + self.frontSelectRange.length);
                    break;
                }
            }


            self.frontSelectRange = growingTextView.selectedRange;
        }else{  // 移动第二个光标

            NSArray *userHandles = [JADataHelper getRangesForUserHandles:growingTextView.text];
            for (NSTextCheckingResult *match in userHandles)
            {
                NSRange matchRange = [match range];
                if (growingTextView.selectedRange.location + growingTextView.selectedRange.length > matchRange.location && growingTextView.selectedRange.location + growingTextView.selectedRange.length < matchRange.location+matchRange.length) {
                    growingTextView.selectedRange = NSMakeRange(growingTextView.selectedRange.location, matchRange.location+matchRange.length);
                    break;
                }
            }

            self.frontSelectRange = growingTextView.selectedRange;
        }

    }else{   // 一个光标

        NSArray *userHandles = [JADataHelper getRangesForUserHandles:growingTextView.text];
        for (NSTextCheckingResult *match in userHandles)
        {
            NSRange matchRange = [match range];
            if (growingTextView.selectedRange.location > matchRange.location && growingTextView.selectedRange.location < matchRange.location+matchRange.length) {
                growingTextView.selectedRange = NSMakeRange(matchRange.location+matchRange.length, growingTextView.selectedRange.length);
                break;
            }
        }
    }
    
}



- (void)textViewDidChange
{
    if (self.dontMove) {
        self.dontMove = NO;
    } else {
        self.lastRange = self.toolBar.nim_textView.selectedRange;
    }
    NSMutableAttributedString *placeholder = [[NSMutableAttributedString alloc] initWithString:self.toolBar.nim_textView.text];
    [placeholder addAttribute:NSFontAttributeName
                        value:JA_REGULAR_FONT(15)
                        range:NSMakeRange(0, self.toolBar.nim_textView.text.length)];

    NSArray *userHandles = [JADataHelper getRangesForUserHandles:self.toolBar.nim_textView.text];
    // Add all our ranges to the result
    for (NSTextCheckingResult *match in userHandles)
    {
        NSRange matchRange = [match range];
        [placeholder addAttribute:NSForegroundColorAttributeName
                            value:HEX_COLOR(0x54C7FC)
                            range:matchRange];
        [placeholder addAttribute:NSFontAttributeName
                            value:JA_REGULAR_FONT(15)
                            range:matchRange];
    }
    self.toolBar.nim_textView.attributedText = placeholder;
    self.toolBar.nim_textView.selectedRange = self.lastRange;
    
    if (self.toolBar.nim_textView.text.length) {
        self.toolBar.publishButton.selected = YES;
    }else{
        self.toolBar.publishButton.selected = NO;
    }
}

// 发布按钮
- (BOOL)shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)replacementText
{
    
    if ([replacementText isEqualToString:@"@"]) {
        if (range.length > 0) {
            NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:replacementText];
            [self.toolBar.nim_textView.textStorage replaceCharactersInRange:range withAttributedString:attributedString];
        }
        [self pushAtPersonVC:YES];
    }
    // 如果删除的是“\b”
    NSString *subString = [self.toolBar.nim_textView.text substringWithRange:range];
    if ([subString isEqualToString:@"\b"]) {
        NSRange headRange = [[self.toolBar.nim_textView.text substringToIndex:range.location] rangeOfString:@"@" options:NSBackwardsSearch];
        if (headRange.location != NSNotFound) {
            self.toolBar.nim_textView.text = [self.toolBar.nim_textView.text stringByReplacingCharactersInRange:NSMakeRange(headRange.location, range.location-headRange.location+1) withString:@""];
            self.toolBar.nim_textView.selectedRange = NSMakeRange(headRange.location, self.toolBar.nim_textView.selectedRange.length);
            return NO;
        }
    }
    
    if ([replacementText isEqualToString:@"\n"]){
        
        [self publishVoice];
        
        return NO;
    }
    
    return YES;
}

#pragma mark - 获取需要的atList;
- (NSArray *)getAtListWithContent:(NSString *)content
{
    NSMutableArray *atList = [JADataHelper getAtListWithContent:content atPersonArray:self.allAtPerson];
    
    [self.allAtPerson removeAllObjects];
    
    return atList;
}

// 发布
- (void)publishVoice
{
    if (self.toolBar.nim_textView.text.length > JA_ReplyInput_words) {
        NSString *str = [NSString stringWithFormat:@"文字回复不能超过%ld个字符",JA_ReplyInput_words];
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:str];
        return;
    }
    
    NSString *trimmString = [self.toolBar.nim_textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (!trimmString.length) {
        self.toolBar.nim_textView.text = nil;
        self.toolBar.publishButton.selected = NO;
        if (self.hasVoiceFile) {
            [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"请输入文字标题"];
        }else{
            [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"请输入回复内容"];
        }
        return;
    }
    
    // 先停止试听
    [self.recordInputView clickPublishButton_stopListen];
    
    // 退下键盘
    [self registAllInput];
    
    if (self.hasVoiceFile) { // 发布音频
        // 上传音频文件 到 阿里云  获取音频文件
        NSString *recordFile = [self getVoiceFile];
        // 上传到阿里云
        NSData *mp3Data = [NSData dataWithContentsOfFile:recordFile];
        if (mp3Data.length) {
            [MBProgressHUD showMessage:nil];
            [[JAUserApiRequest shareInstance] ali_upLoadData:mp3Data fileType:@"mp3" finish:^(NSString *filePath) {
                [MBProgressHUD hideHUD];
                if (filePath.length) {
                    NSString *imageUrl = [NSString stringWithFormat:@"%@",filePath];
                    if ([self.delegate respondsToSelector:@selector(inputViewVoiceFileUploadFinishWithUrlString:fileTime:fileText:soundWave:atArray:result:standbyObj:)]) {
                        [self.delegate inputViewVoiceFileUploadFinishWithUrlString:imageUrl fileTime:[self getVoiceFileDuration] fileText:[self getVoiceFileWord] soundWave:[self getVoiceFileSample] atArray:[self getAtListWithContent:[self getVoiceFileWord]] result:YES standbyObj:nil];
                    }
                } else {
                    if ([self.delegate respondsToSelector:@selector(inputViewVoiceFileUploadFinishWithUrlString:fileTime:fileText:soundWave:atArray:result:standbyObj:)]) {
                        [self.delegate inputViewVoiceFileUploadFinishWithUrlString:nil fileTime:nil fileText:[self getVoiceFileWord] soundWave:nil atArray:[self getAtListWithContent:[self getVoiceFileWord]] result:NO standbyObj:nil];
                    }
                }
            }];
        }else{
            [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"无效的音频文件,请重录"];
        }
        
    }else{  // 发布文字
        if ([self.delegate respondsToSelector:@selector(inputViewVoiceFileUploadFinishWithUrlString:fileTime:fileText:soundWave:atArray:result:standbyObj:)]) {
            [self.delegate inputViewVoiceFileUploadFinishWithUrlString:nil fileTime:nil fileText:[self getVoiceFileWord] soundWave:nil atArray:[self getAtListWithContent:[self getVoiceFileWord]] result:YES standbyObj:nil];
        }
    }

}

#pragma mark - 上传音频文件需要的音频信息
- (NSString *)getVoiceFile
{
    if (self.hasVoiceFile) {
        return self.recordInputView.recordManager.recordFile;
    }else{
        return nil;
    }
}

// 获取时长
- (NSString *)getVoiceFileDuration
{
    CGFloat voiceDuration = self.recordInputView.voiceDuration;
    NSString *time = [NSString stringWithFormat:@"%02d:%02d",(int)(voiceDuration)/60,(int)(voiceDuration)%60];
    return time;
}

// 获取文字描述
- (NSString *)getVoiceFileWord
{
    return self.toolBar.nim_textView.text;
}

// 获取音频的采样点
- (NSMutableArray *)getVoiceFileSample
{
    return self.recordInputView.allPeakLevelQueue;
}

#pragma mark - 对外方法
/// 唤起文字键盘或者录制键盘
- (void)callInputOrRecordKeyBoard
{
    if (!IS_LOGIN) {
        [JAAPPManager app_modalLogin];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[JA_Property_BindingType] = @"回复";
        [JASensorsAnalyticsManager sensorsAnalytics_jumpRegistOrLoginPage:dic];
        return;
    }
    
//    if (self.hasVoiceFile) {   // 有音频文件弹出文字键盘
//        [self.recordInputView becomeRecordInputView];
//        [self animateChangeFrame:self.toolBar.height + 252 + kBottomMargn duration:0.25];
//        [self.toolBar.nim_textView becomeFirstResponder];
//    }else{
//        [self.recordInputView becomeRecordInputView];
//        [self animateChangeFrame:self.toolBar.height + 252 + kBottomMargn duration:0.25];
//    }
    
    /// 2.5.7 直接弹出文字键盘
    [self.recordInputView becomeRecordInputView];
    [self animateChangeFrame:self.toolBar.height + 252 + kBottomMargn duration:0.25];
    [self.toolBar.nim_textView becomeFirstResponder];
}
/// 辞去键盘
- (void)registAllInput
{
    // 取消文字键盘
    if (self.toolBar.nim_textView.isFirstResponder) {
        
        [[[[UIApplication sharedApplication] delegate] window] endEditing:YES];
    }
    
    // 取消录制键盘 （高度 == 0）
    if (self.recordInputView.recordStatus != JARecordStatusTypeNone) {
        [self.recordInputView registRecordInputView];
    }
    
    // 改变高度
    if (_inputInitial == JAInputInitialLocalTypeHiden) {
        [self animateChangeFrame:0 duration:0.25];
    }else{
        [self animateChangeFrame:self.toolBar.height + kBottomMargn duration:0.25];
    }
    
    // 设置占位文字
    if (!self.isHasDraft) { // 没有数据（音频或者文字）
        self.placeHolderText = @"请输入回复内容";
    }
    
    // 设置键盘按钮的图片
    if (self.hasVoiceFile) {
        self.hasVoiceFile = YES;
    }else{
        self.hasVoiceFile = NO;
    }
    
    if (_coverView) {
        [_coverView removeFromSuperview];
        _coverView = nil;
    }
}

/// 销毁inputview
- (void)inputviewDealloc
{
    if (_coverView) {
        [_coverView removeFromSuperview];
        _coverView = nil;
    }
}

/// 获取是否是响应状态
- (BOOL)isRespondStatus
{
    if (self.toolBar.nim_textView.isFirstResponder || self.recordInputView.height > 0) {
        return YES;
    }
    return NO;
}

/// 获取是否有数据
- (BOOL)isHasDraft
{
    if (self.hasVoiceFile || self.toolBar.nim_textView.text.length) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isHasVoice
{
    if (self.hasVoiceFile) {
        return YES;
    }
    
    return NO;
}

- (NSString *)inputText
{
    if (self.toolBar.nim_textView.text.length) {
        return self.toolBar.nim_textView.text;
    }else{
        return @"回复楼主";
    }
}

/// 获取匿名状态
- (BOOL)anonymousStatus
{
    return self.isAnonymous;
}

/// 设置占位文字
- (void)setPlaceHolderText:(NSString *)placeHolderText
{
    _placeHolderText = placeHolderText;
    
    NSString *placeHolder = placeHolderText;
    NSMutableAttributedString *place = [[NSMutableAttributedString alloc] initWithString:placeHolder];
    [place addAttributes:@{NSFontAttributeName : JA_REGULAR_FONT(15), NSForegroundColorAttributeName : HEX_COLOR(0xCACACA)} range:[placeHolder rangeOfString:placeHolder]];
    self.toolBar.nim_textView.placeholderAttributedText = place;
}

/// 清空携带的数据
- (void)resetInputOfDraftWithPlacrHolder:(NSString *)placeHolderText
{
    
    self.hasVoiceFile = NO;
    
    if (self.toolBar.nim_textView.text.length) {
        self.toolBar.nim_textView.text = nil;
        self.toolBar.publishButton.selected = NO;
    }
    
    [self.recordInputView resetInputRecord];
    
    // 删除文件
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSString *pcmFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/record_pcm"];
    NSString *mp3FilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/record.mp3"];
    
    BOOL isExists = [manager fileExistsAtPath:pcmFilePath];
    if (isExists) {
        [manager removeItemAtPath:pcmFilePath error:nil];
    }
    BOOL isExists1 = [manager fileExistsAtPath:mp3FilePath];
    if (isExists1) {
        [manager removeItemAtPath:mp3FilePath error:nil];
    }
    
    if (placeHolderText.length) {
        NSString *placeHolder = placeHolderText;
        NSMutableAttributedString *place = [[NSMutableAttributedString alloc] initWithString:placeHolder];
        [place addAttributes:@{NSFontAttributeName : JA_REGULAR_FONT(15), NSForegroundColorAttributeName : HEX_COLOR(0xCACACA)} range:[placeHolder rangeOfString:placeHolder]];
        self.toolBar.nim_textView.placeholderAttributedText = place;
    }
}

#pragma mark - 懒加载
- (void)addCover:(BOOL)hide height:(CGFloat)height;
{
    if (_coverView == nil) {

        _coverView = [[UIView alloc] init];
        _coverView.backgroundColor = [UIColor clearColor];
        _coverView.width = JA_SCREEN_WIDTH;
        UIViewController *v = [self currentViewController];
        [v.view addSubview:_coverView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickCover_registAllKeyBoard)];
        [_coverView addGestureRecognizer:tap];
        
        UISwipeGestureRecognizer *swipe1=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(clickCover_registAllKeyBoard)];
        
        //默认是UISwipeGestureRecognizerDirectionRight
        swipe1.direction=UISwipeGestureRecognizerDirectionUp;
        [_coverView addGestureRecognizer:swipe1];
        
        UISwipeGestureRecognizer *swipe2=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(clickCover_registAllKeyBoard)];
        
        //默认是UISwipeGestureRecognizerDirectionRight
        swipe2.direction=UISwipeGestureRecognizerDirectionDown;
        [_coverView addGestureRecognizer:swipe2];
    }
 
    _coverView.height = height;
    _coverView.hidden = hide;
}

- (void)clickCover_registAllKeyBoard
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"clickCover_regist" object:self];
    [_coverView removeFromSuperview];
    _coverView = nil;
}


#pragma mark - 展示录音红点
- (void)setHasVoiceFile:(BOOL)hasVoiceFile
{
    _hasVoiceFile = hasVoiceFile;
    
    if (hasVoiceFile) {
        [self.toolBar.recordButton setImage:[UIImage imageNamed:@"branch_detail_recordRed"] forState:UIControlStateNormal];
    }else{
        [self.toolBar.recordButton setImage:[UIImage imageNamed:@"branch_detail_record"] forState:UIControlStateNormal];
    }
}

#pragma mark -  获取当前控制器

- (UIViewController *) findBestViewController:(UIViewController *)vc {
    if (vc.presentedViewController) {
        // Return presented view controller
        return [self findBestViewController:vc.presentedViewController];
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        // Return right hand side
        UISplitViewController* svc = (UISplitViewController*) vc;
        if (svc.viewControllers.count > 0)
            return [self findBestViewController:svc.viewControllers.lastObject];
        else
            return vc;
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        // Return top view
        UINavigationController* svc = (UINavigationController*) vc;
        if (svc.viewControllers.count > 0)
            return [self findBestViewController:svc.topViewController];
        else
            return vc;
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        // Return visible view
        UITabBarController* svc = (UITabBarController*) vc;
        if (svc.viewControllers.count > 0)
            return [self findBestViewController:svc.selectedViewController];
        else
            return vc;
    } else {
        // Unknown view controller type, return last child view controller
        return vc;
    }
}

- (UIViewController *) currentViewController {
    MMDrawerController *vc = (MMDrawerController *)[AppDelegate sharedInstance].window.rootViewController;
    JABaseNavigationController *nav = (JABaseNavigationController *)vc.centerViewController;
    CYLTabBarController *tab = (CYLTabBarController *)nav.childViewControllers.firstObject;
    return [self findBestViewController:tab];
}
@end
