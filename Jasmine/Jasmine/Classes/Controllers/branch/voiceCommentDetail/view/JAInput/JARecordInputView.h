//
//  JARecordInputView.h
//  Jasmine
//
//  Created by 刘宏亮 on 2017/12/13.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAInputRecordManager.h"

typedef NS_ENUM(NSUInteger, JARecordStatusType) {
    JARecordStatusTypeNone,     // 初始状态 高度 = 0
    JARecordStatusTypeResponse  // 响应状态 高度 > 0
};

@class JARecordInputView;
@protocol JARecordInputViewDelegate <NSObject>

// 录制失败按钮
- (void)recordInputViewWithFaile;

// 完成录制按钮
- (void)recordInputViewWithFinishButton:(JARecordInputView *)recordInputView duration:(NSString *)durationString textResult:(NSMutableArray *)text;
// 重新录制按钮
- (void)recordInputViewWithCancleButton:(JARecordInputView *)recordInputView;
// 开始录制按钮
- (void)recordInputViewWithRecordButton:(JARecordInputView *)recordInputView buttonStatus:(JARecordStatusType)statusType;
@end

@interface JARecordInputView : UIView
@property (nonatomic, assign, readonly) JARecordStatusType recordStatus;

@property (nonatomic, weak) id <JARecordInputViewDelegate> delegate;

@property (nonatomic, strong) JAInputRecordManager *recordManager; // 录音机

@property (nonatomic, assign) CGFloat voiceDuration;  // 音频总时长

@property (nonatomic, strong) NSMutableArray *allPeakLevelQueue; // 声波图采样点

/// 唤起录制键盘
- (void)becomeRecordInputView;

/// 辞去录制键盘
- (void)registRecordInputView;

/// 点击发布按钮停止试听
- (void)clickPublishButton_stopListen;

/// 恢复录制键盘的初始按钮状态
- (void)resetInputRecord;

@end
