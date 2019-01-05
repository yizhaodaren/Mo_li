//
//  JAAudioRecorder.m
//  Jasmine
//
//  Created by xujin on 04/05/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JAAudioRecorder.h"
#import "LameManager.h"
#import <CoreAudio/CoreAudioTypes.h>
#import <lame/lame.h>

#define MAXRecordTime 3600

@interface JAAudioRecorder () <AVAudioRecorderDelegate>

@property (nonatomic, strong) AVAudioSession *session;

@end

@implementation JAAudioRecorder

+ (JAAudioRecorder *)shareInstance
{
    static JAAudioRecorder *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil)
        {
            instance = [[JAAudioRecorder alloc] init];
        }
    });
    return instance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        //新建一个数据类
//        NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
//        NSString *mesID = [NSString stringWithFormat:@"%ld",(long)interval];
        NSString *mesID = [NSProcessInfo processInfo].globallyUniqueString;

        //设置路径,这里要设置录音路径
        NSString *dir = [self audioDirectoryPath];
        NSString *filePath = [dir stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.caf",mesID]];
        _cafFilePath = filePath;
        
        //转码路径
        NSString *mp3FilePath = [dir stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.mp3",mesID]];
        _mp3FilePath = mp3FilePath;

        NSMutableDictionary *recordSettings = [[NSMutableDictionary alloc]init];
        [recordSettings setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM]  forKey:AVFormatIDKey];
        [recordSettings setValue:[NSNumber numberWithFloat:44100]              forKey:AVSampleRateKey];
        [recordSettings setValue:[NSNumber numberWithInt:2]                      forKey:AVNumberOfChannelsKey];
        
        [recordSettings setValue:[NSNumber numberWithInt:16]                     forKey:AVLinearPCMBitDepthKey];
        [recordSettings setValue:[NSNumber numberWithBool:NO]                    forKey:AVLinearPCMIsBigEndianKey];
        [recordSettings setValue:[NSNumber numberWithBool:NO]                    forKey:AVLinearPCMIsFloatKey];
//        //设置录音格式  AVFormatIDKey==kAudioFormatLinearPCM
//        [recordSettings setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM ] forKey:AVFormatIDKey];
//        
//        //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
//        [recordSettings setValue:[NSNumber numberWithFloat:44100] forKey:AVSampleRateKey];
//        
//        //录音通道数，caf转mp3必须用双声道
//        [recordSettings setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
//        
//        //线性采样位数  8、16、24、32
//        [recordSettings setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
//        
//        //录音的质量
//        [recordSettings setValue:[NSNumber numberWithInt:AVAudioQualityMax] forKey:AVEncoderAudioQualityKey];
        
        self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:filePath] settings:recordSettings error: nil];
        self.audioRecorder.delegate = self;
        //监听 音量大小
        self.audioRecorder.meteringEnabled = YES;

    }
    return self;
}
- (NSString *)audioDirectory
{
    return [self audioDirectoryPath];
}

- (BOOL)isRecording {
    return self.audioRecorder.isRecording;
}

//获取录音路径
- (NSString *)audioDirectoryPath
{
    NSString *documentsFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [documentsFolder stringByAppendingPathComponent:@"JAAudio"];
    //如果不存在 就创建一个
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath])
    {
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return filePath;
}

- (BOOL)haveVoice {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:_cafFilePath])
    {
        return YES;
    }
    return NO;
}

// 开始录音
- (void)start
{
    NSLog(@"本地url = %@",_cafFilePath);

    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker|AVAudioSessionCategoryOptionMixWithOthers error:nil];
    
    if(session == nil) {
        NSLog(@"Error creating session: %@", [sessionError description]);
    } else {
        [session setActive:YES error:nil];
    }
    self.session = session;

    if ([[NSFileManager defaultManager] fileExistsAtPath:_cafFilePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:_cafFilePath error:nil];
    }
    
    [self.audioRecorder prepareToRecord];
    [self.audioRecorder recordForDuration:MAXRecordTime];
    
//    [self.recoderTimer fire];

//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [self conventToMp3];
//    });
}

// 继续录音
- (void)continueRecord
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker|AVAudioSessionCategoryOptionMixWithOthers error:nil];
    
    if(session == nil) {
        NSLog(@"Error creating session: %@", [sessionError description]);
    } else {
        [session setActive:YES error:nil];
    }
    
    [self.audioRecorder record];
    
//    [self.recoderTimer fire];
}

// 暂停录音
- (void)pause
{
    [self.audioRecorder pause];
    //    [self.recoderTimer invalidate];
    //    self.recoderTimer = nil;
}

// 停止录音
- (void)stop
{
    [self.audioRecorder stop];
//    [self.recoderTimer invalidate];
//    self.recoderTimer = nil;
}


// 实时转换mp3
- (void)conventToMp3 {
    
    NSURL *URL = self.audioRecorder.url;
    NSLog(@"本地url = %@",[URL path]);
    NSString *cafFilePath = [URL path];
    
    NSString *filename = [[cafFilePath lastPathComponent] stringByDeletingPathExtension];
    NSString *mp3FilePath = [[self audioDirectoryPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3", filename]];
    _mp3FilePath = mp3FilePath;
    
    @try {
        
        int read, write;
        
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:NSASCIIStringEncoding], "rb");
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:NSASCIIStringEncoding], "wb");
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE * 2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 44100);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        long curpos;
        BOOL isSkipPCMHeader = NO;
        
        do {
            
            curpos = ftell(pcm);
            
            long startPos = ftell(pcm);
            
            fseek(pcm, 0, SEEK_END);
            long endPos = ftell(pcm);
            
            long length = endPos - startPos;
            
            fseek(pcm, curpos, SEEK_SET);
            
            
            if (length > PCM_SIZE * 2 * sizeof(short int)) {
                
                if (!isSkipPCMHeader) {
                    //Uump audio file header, If you do not skip file header
                    //you will heard some noise at the beginning!!!
                    fseek(pcm, 4 * 1024, SEEK_SET);
                    isSkipPCMHeader = YES;
                    //                    DWDLog(@"skip pcm file header !!!!!!!!!!");
                }
                
                read = (int)fread(pcm_buffer, 2 * sizeof(short int), PCM_SIZE, pcm);
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
                fwrite(mp3_buffer, write, 1, mp3);
                //                DWDLog(@"read %d bytes", write);
            }
            
            else {
                
                [NSThread sleepForTimeInterval:0.05];
                //                DWDLog(@"sleep");
                
            }
            
        } while (self.isRecording);
        
        read = (int)fread(pcm_buffer, 2 * sizeof(short int), PCM_SIZE, pcm);
        write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
        //        DWDLog(@"read %d bytes and flush to mp3 file", write);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
        
        //        self.isFinishConvert = YES;
    }
    @catch (NSException *exception) {
        //        DWDLog(@"%@", [exception description]);
    }
    @finally {
        //        DWDLog(@"convert mp3 finish!!!");
    }
}

- (void)removeMp3File {
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.mp3FilePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:self.mp3FilePath error:nil];
    }
}

- (void)removeCafFile {
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.cafFilePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:self.cafFilePath error:nil];
    }
}

#pragma mark - 录音回调

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    if (flag) {
        BOOL success = NO;
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.cafFilePath]) {
            success = YES;
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(audioRecoderDidFinishRecording:success:)]) {
            [self.delegate audioRecoderDidFinishRecording:recorder success:success];
        }
        //这样就可以在录音完成后恢复原来的设置。背景音乐就会播放了
        [self.session setActive:NO error:nil];
    } else {
        [self removeCafFile];
    }
}

- (void)converCafToMp3:(void(^)(BOOL complete))completion {
    [LameManager encodeAudioFile:self.cafFilePath output:self.mp3FilePath complete:^{
        // 删除原始音频文件
        [self removeCafFile];
        if (completion) {
            completion(YES);
        }
    } failure:^(NSString *reason) {
        if (completion) {
            completion(NO);
        }
    }];
}

//录音失败。
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    NSLog(@"录音失败 error = %@",error);
}

- (void)updateAudioDisplay
{
    [self.audioRecorder updateMeters];
    
    float   level;                // The linear 0.0 .. 1.0 value we need.
    float   minDecibels = -80.0f; // Or use -60dB, which I measured in a silent room.
    float   decibels    = [self.audioRecorder averagePowerForChannel:0];
    
    if (decibels < minDecibels)
    {
        level = 0.0f;
    }
    else if (decibels >= 0.0f)
    {
        level = 1.0f;
    }
    else
    {
        float   root            = 2.0f;
        float   minAmp          = powf(10.0f, 0.05f * minDecibels);
        float   inverseAmpRange = 1.0f / (1.0f - minAmp);
        float   amp             = powf(10.0f, 0.05f * decibels);
        float   adjAmp          = (amp - minAmp) * inverseAmpRange;
        
        level = powf(adjAmp, 1.0f / root);
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioRecoderDidUpdateVolume:)])
    {
        [self.delegate audioRecoderDidUpdateVolume:level];
    }
}


//- (NSTimer *)recoderTimer
//{
//    if (_recoderTimer == nil)
//    {
//        _recoderTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(updateAudioDisplay) userInfo:nil repeats:YES];
//    }
//    return _recoderTimer;
//}


/*
 剪切开始工作
 
 大概流程
 1、获得视频总时长，处理时间，数组格式返回音频数据
 2、创建导出会话
 3、设计导出时间范围，淡出时间范围
 4、设计新音频配置数据，文件路径，类型等
 5、开始剪切
 */
- (BOOL)cropAudio:(NSString *)inputPath
           output:(NSString *)outputPath
        startTime:(int64_t)startTime
          entTime:(int64_t)endTime
         complete:(void(^)(BOOL ret))complete
{
    
    //获取歌曲地址
    NSURL *assetURL = [NSURL fileURLWithPath:inputPath];
    
    //初始化音频媒体文件
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:assetURL options:nil];
    
    //获取视频总时长,单位秒
//    CMTime assetTime = [avAsset duration];
//    
//    //返回float64格式
//    Float64 duration = CMTimeGetSeconds(assetTime);
    
    // get the first audio track
    NSArray *tracks = [avAsset tracksWithMediaType:AVMediaTypeAudio];
    if ([tracks count] == 0)
    {
        if (complete) {
            complete(NO);
        }
        return NO;
    }
    AVAssetTrack *track = [tracks objectAtIndex:0];
    
    // create the export session
    // no need for a retain here, the session will be retained by the
    // completion handler since it is referenced there
    
    AVAssetExportSession *exportSession = [AVAssetExportSession
                                           exportSessionWithAsset:avAsset
                                           presetName:AVAssetExportPresetAppleM4A];
    
    if (nil == exportSession) {
        if (complete) {
            complete(NO);
        }
        return NO;
    }
    
    // create trim time range
    
    //CMTimeMake(第几帧， 帧率)
    CMTime beginTime = CMTimeMake(startTime, 1);
    
    //CMTimeMake(第几帧， 帧率)
    CMTime stopTime = CMTimeMake(endTime, 1);
    
    //导出时间范围
    CMTimeRange exportTimeRange = CMTimeRangeFromTimeToTime(beginTime, stopTime);
    
    // create fade in time range
    CMTime startFadeInTime = beginTime;
    
    CMTime endFadeInTime = CMTimeMake(endTime - 1, 1);
    
    //淡入时间范围
    CMTimeRange fadeInTimeRange = CMTimeRangeFromTimeToTime(startFadeInTime, endFadeInTime);
    
    
    // setup audio mix

    AVMutableAudioMix *exportAudioMix = [AVMutableAudioMix audioMix];
    
    //给track 返回一个可变的输入参数对象
    AVMutableAudioMixInputParameters *exportAudioMixInputParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:track];
    
    //设置指定时间范围内导出
    [exportAudioMixInputParameters setVolumeRampFromStartVolume:0.0 toEndVolume:1.0 timeRange:fadeInTimeRange];
    
    //返回导出数据转化为数组
    exportAudioMix.inputParameters = [NSArray arrayWithObject:exportAudioMixInputParameters];
    
    
    // configure export session  output with all our parameters
    
    exportSession.outputURL = [NSURL fileURLWithPath:outputPath]; // output path
    
    exportSession.outputFileType = AVFileTypeAppleM4A; // output file type
    
    exportSession.timeRange = exportTimeRange; // trim time range
    
    exportSession.audioMix = exportAudioMix; // fade in audio mix
    
    // perform the export
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{ //block
        
        //如果信号提示已经完成
        if (AVAssetExportSessionStatusCompleted == exportSession.status)
        {
            NSLog(@"剪辑成功:%@", outputPath);
            if (complete) {
                complete(YES);
            }
        }
        else
        {
            NSLog(@"编辑失败%ld", exportSession.status);
            if (complete) {
                complete(NO);
            }
        }
        
    }];
    return YES;
    
}

// 使用代码
//- (void)testMege
//{
//    NSString *wayPath = [[NSBundle mainBundle] pathForResource:@"MyWay" ofType:@"mp3"];
//    NSString *easyPath = [[NSBundle mainBundle] pathForResource:@"Easy" ofType:@"mp3"];
//    NSMutableArray *dataArr = [NSMutableArray array];
//    [dataArr addObject:[NSURL fileURLWithPath:wayPath]];
//    [dataArr addObject:[NSURL fileURLWithPath:easyPath]];
//    NSString *destPath = [[self audioDirectoryPath] stringByAppendingString:@"FlyElephant.m4a"];
//    
//    if ([[NSFileManager defaultManager] fileExistsAtPath:destPath]) {
//        [[NSFileManager defaultManager] removeItemAtPath:destPath error:nil];
//    }
//    [self audioMerge:dataArr destUrl:[NSURL fileURLWithPath:destPath]];
//}

- (void)audioMerge:(NSMutableArray <NSURL *>*)dataSource destUrl:(NSURL *)destUrl complete:(void(^)(BOOL ret))complete

{
    AVMutableComposition *mixComposition = [AVMutableComposition composition];
    
    // 开始时间
    CMTime beginTime = kCMTimeZero;
    // 设置音频合并音轨
    AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    NSError *error = nil;
    for (NSURL *sourceURL in dataSource)
    {
        //音频文件资源
        AVURLAsset  *audioAsset = [[AVURLAsset alloc] initWithURL:sourceURL options:nil];
        //需要合并的音频文件的区间
        CMTimeRange audio_timeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);
        // ofTrack 音频文件内容
        BOOL success = [compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] firstObject] atTime:beginTime error:&error];
        
        if (!success) {
            NSLog(@"Error: %@",error);
        }
        beginTime = CMTimeAdd(beginTime, audioAsset.duration);
    }
    // presetName 与 outputFileType 要对应  导出合并的音频
    AVAssetExportSession* assetExportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetAppleM4A];
    assetExportSession.outputURL = destUrl;
    assetExportSession.outputFileType = AVFileTypeAppleM4A;
    assetExportSession.shouldOptimizeForNetworkUse = YES;
    [assetExportSession exportAsynchronouslyWithCompletionHandler:^{
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSLog(@"%@",assetExportSession.error);
//        });
        if (complete) {
            complete(YES);
        }
    }];
}

@end
