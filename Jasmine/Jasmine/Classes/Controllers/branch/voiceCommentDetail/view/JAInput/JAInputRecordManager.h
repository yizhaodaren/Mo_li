//
//  JAInputRecordManager.h
//  Jasmine
//
//  Created by moli-2017 on 2017/12/20.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, JAInputRecordStatusType) {
    JAInputRecordStatusTypeNone,    // 空闲
    JAInputRecordStatusTypeRecording, // 录制中
    JAInputRecordStatusTypeRecordFinish, // 录制完成
    JAInputRecordStatusTypeListening, // 试听中
    JAInputRecordStatusTypeListenPause, // 试听暂停中
    JAInputRecordStatusTypeListenFinish, // 试听完成
    
};

@protocol JAInputRecordManagerDelegate <NSObject>

// 实时获取音量值、录制时间等
- (void)inputRecordWithDuration:(CGFloat)duration volume:(CGFloat)volume drawVolume:(CGFloat)drawVolume;

// 录制完成
- (void)inputRecordFinish;

// 录制失败
- (void)inputRecordFinishFaile;

// 试听的进度
- (void)inputListenWithPlayDuration:(CGFloat)duration;

@end

@interface JAInputRecordManager : NSObject

@property (nonatomic, strong) NSString *recordFile;   // 音频路径

@property (nonatomic, weak) id <JAInputRecordManagerDelegate> delegate;

@property (nonatomic, assign, readonly) JAInputRecordStatusType inputRecordStatus;

@property (nonatomic, strong) NSMutableArray *iflyResults;

// 2.6.2
@property (nonatomic, assign) NSInteger maxTime;  // 讯飞监听的最大时间  单位 s

/// 开始录制
- (void)inputRecordStart;

/// 结束录制
- (void)inputRecordStop;

/// 开始试听
- (void)inputRecordListenBegin;

/// 暂停试听
- (void)inputRecordListenPause;

/// 继续试听
- (void)inputRecordListenContinue;

/// 停止试听
- (void)inputRecordListenStop;

/// 停止讯飞识别
- (void)inputIflyStop;
// 移除文件
- (void)removeAvailFile;

@end
