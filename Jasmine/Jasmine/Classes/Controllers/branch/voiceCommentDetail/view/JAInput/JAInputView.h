//
//  JAInputView.h
//  Jasmine
//
//  Created by 刘宏亮 on 2017/12/7.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, JAInputInitialLocalType) {
    JAInputInitialLocalTypeShow,
    JAInputInitialLocalTypeHiden,
    
};

@class JAInputView;
@protocol JAInputViewDelegate <NSObject>
- (void)inputViewFrameChangeWithHeight:(CGFloat)height;   // 获取键盘的高高度

- (void)inputViewVoiceFileUploadFinishWithUrlString:(NSString *)fileUrlString  // 音频文件上传完成
                                           fileTime:(NSString *)timeString
                                           fileText:(NSString *)text
                                          soundWave:(NSMutableArray *)soundWaveArr
                                            atArray:(NSArray *)atArray
                                             result:(BOOL)result
                                         standbyObj:(id)standbyObj;

//- (void)inputViewClickSelf:(JAInputView *)input;

/*神策需要的点击*/
- (void)input_sensorsAnalyticsBeginRecord;   // 开始录制
- (void)input_sensorsAnalyticsFinishRecordWithRecordDuration:(CGFloat)duration;   // 完成录制
- (void)input_sensorsAnalyticsCancleRecordWithRecordDuration:(CGFloat)duration;   // 重新录制
@end

@interface JAInputView : UIView
/// 是否是响应的状态
@property (nonatomic, assign, readonly) BOOL isRespondStatus;
/// 是否有草稿(音频或者文字)
@property (nonatomic, assign, readonly) BOOL isHasDraft;
/// 键盘初始位置(隐藏 或者 底部50)
@property (nonatomic, assign) JAInputInitialLocalType inputInitial;
/// 代理
@property (nonatomic, weak) id <JAInputViewDelegate> delegate;
/// 设置占位文字
@property (nonatomic, strong) NSString *placeHolderText;

/// 设置匿名的状态
@property (nonatomic, assign) BOOL isAnonymous;
/// 获取按钮的状态
@property (nonatomic, assign, readonly) BOOL anonymousStatus;

/// 辞去键盘
- (void)registAllInput;

/// 唤起文字键盘或者录制键盘
- (void)callInputOrRecordKeyBoard;

/// 清空携带的数据
- (void)resetInputOfDraftWithPlacrHolder:(NSString *)placeHolderText;

/// 销毁inputview
- (void)inputviewDealloc;


/* ------------------------------------------------ 3.0帖子、评论详情用 ---------------------------------------- */
// 是否有音频数据
@property (nonatomic, assign, readonly) BOOL isHasVoice;
// 文字数据
@property (nonatomic, strong, readonly) NSString *inputText;
// 弹起文字键盘
- (void)callInputKeyBoard;
// 弹起录音键盘
- (void)callRecordKeyBoard;
/* ------------------------------------------------ 3.0帖子、评论详情用 ---------------------------------------- */
@end
