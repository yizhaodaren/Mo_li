//
//  JAAudioRecorder.h
//  Jasmine
//
//  Created by xujin on 04/05/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol JAAudioRecorderDelegate <NSObject>

- (void)audioRecoderDidUpdateVolume:(CGFloat)value;
- (void)audioRecoderDidFinishRecording:(AVAudioRecorder *)recorder success:(BOOL)success;

@end


@interface JAAudioRecorder : NSObject

@property (nonatomic, weak) id<JAAudioRecorderDelegate>delegate;
@property (nonatomic, strong) AVAudioRecorder *audioRecorder;
@property (nonatomic, strong, readonly) NSString *mp3FilePath;
@property (nonatomic, strong, readonly) NSString *cafFilePath;
@property (nonatomic, assign, readonly) BOOL isRecording;

+ (JAAudioRecorder *)shareInstance;

- (void)start;
- (void)pause;
- (void)continueRecord;
- (void)stop;
- (NSString *)audioDirectory;
- (BOOL)haveVoice;
// outputPath 在设置时必须是新的路径，不允许此路径已存在
- (BOOL)cropAudio:(NSString *)inputPath
           output:(NSString *)outputPath
        startTime:(int64_t)startTime
          entTime:(int64_t)endTime
         complete:(void(^)(BOOL ret))complete;
- (void)audioMerge:(NSMutableArray <NSURL *>*)dataSource
           destUrl:(NSURL *)destUrl
          complete:(void(^)(BOOL ret))complete;

- (void)removeCafFile;
- (void)removeMp3File;
- (void)converCafToMp3:(void(^)(BOOL complete))completion;


@end
