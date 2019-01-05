//
//  JASpeechRecognizerManager.h
//  Jasmine
//
//  Created by xujin on 13/01/2018.
//  Copyright © 2018 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JASpeechRecognizerManager : NSObject

@property (nonatomic, copy) NSString *pcmFilePath;
@property (nonatomic, copy) NSString *mp3FilePath;
@property (nonatomic, strong) NSMutableString *result; // 语音解析出的结果

+ (JASpeechRecognizerManager *)shareInstance;
- (void)setup;
- (void)createSpeechRecognizer;
- (void)createPcmRecord;
- (void)startRecord;
- (void)stopRecord;
- (void)resetRecord;

@end
