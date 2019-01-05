//
//  JASampleHelper.m
//  Jasmine
//
//  Created by xujin on 13/12/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JASampleHelper.h"

static const CGFloat sampleWidth = 4.0;// 绘制的竖条和间距

@implementation JASampleHelper

+ (NSString *)getSampleStringWithAllPeakLevelQueue:(NSMutableArray *)allPeakLevelQueue {
    NSString *sampleString = nil;
    if (allPeakLevelQueue.count) {
        sampleString = [allPeakLevelQueue componentsJoinedByString:@","];
    }
    return sampleString;
}

+ (NSString *)getSampleZipStringWithAllPeakLevelQueue:(NSMutableArray *)allPeakLevelQueue {
    // 新增压缩样本字段（先gzip后base64）
    NSData *inputData = [[self getSampleStringWithAllPeakLevelQueue:allPeakLevelQueue] dataUsingEncoding:NSUTF8StringEncoding];
    NSData *compressedData = [inputData gzippedData];
    NSString *base64String = [compressedData base64EncodedStringWithOptions:0];
    return base64String;
}

+ (CGFloat)getViewWidthWithType:(JADisplayType)type {
    CGFloat viewWidth = 0;
    switch (type) {
        case JADisplayTypeStory:
            viewWidth = JA_SCREEN_WIDTH-12*2;
            break;
        case JADisplayTypeComment:
            viewWidth = JA_SCREEN_WIDTH-69;
            break;
        case JADisplayTypeNotification:
            viewWidth = JA_SCREEN_WIDTH-70;
            break;
        case JADisplayTypeCheckVoice:
            viewWidth = JA_SCREEN_WIDTH-12*2;
            break;
        case JADisplayTypeCheckComment:
            viewWidth = JA_SCREEN_WIDTH-70;
            break;
        case JADisplayTypeAll:
            viewWidth = JA_SCREEN_WIDTH;
            break;
        default:
            break;
    }
    return viewWidth;
}

+ (int)getAllCountWithViewWidth:(CGFloat)viewWidth {
    int allCount = (int)(viewWidth/sampleWidth);
    if (allCount%2 != 0) {
        allCount += 1;
    }
    return allCount;
}

+ (NSMutableArray *)getDisplayPeakLevelQueue:(NSString *)sampleZip sample:(NSString *)sample type:(JADisplayType)type{
    CGFloat viewWidth = [self getViewWidthWithType:type];
    return [self getDisplayPeakLevelQueue:sampleZip sample:sample viewWidth:viewWidth];
}

+ (NSMutableArray *)getDisplayPeakLevelQueue:(NSString *)sampleZip sample:(NSString *)sample viewWidth:(CGFloat)viewWidth {
    if (sampleZip.length) {
        // 存在压缩字段优先使用压缩字段
        NSData *zipData = [[NSData alloc] initWithBase64EncodedString:sampleZip options:0];
        NSData *outputData = [zipData gunzippedData];
        NSString *outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
        sample = outputString;
    }
    NSMutableArray *originalPeakLevelQueue = [[sample componentsSeparatedByString:@","] mutableCopy];
    [originalPeakLevelQueue removeObject:@""];
    NSMutableArray *displayPeakLevelQueue = [NSMutableArray arrayWithArray:originalPeakLevelQueue];
    int allCount = [self getAllCountWithViewWidth:viewWidth];
    if (originalPeakLevelQueue.count) {
        int halfCount = allCount/2;
        int diff = 0;
        if (originalPeakLevelQueue.count > allCount) {
            diff = halfCount;
        } else if (originalPeakLevelQueue.count < allCount &&
                   originalPeakLevelQueue.count > halfCount) {
            diff = (int)(allCount - originalPeakLevelQueue.count)+halfCount;
        } else {
            diff = (int)(allCount - originalPeakLevelQueue.count);
        }
        // 补充空点
        for (int i=0; i<diff; i++) {
            [displayPeakLevelQueue addObject:@(-1.0)];
        }
    } else {
        for (int i=0; i<allCount; i++) {
            [displayPeakLevelQueue addObject:@(-1.0)];
        }
    }
    return displayPeakLevelQueue;
}

+ (NSMutableArray *)getCurrentPeakLevelQueue:(NSMutableArray *)displayPeakLevelQueue type:(JADisplayType)type {
    CGFloat viewWidth = [self getViewWidthWithType:type];
    return [self getCurrentPeakLevelQueue:displayPeakLevelQueue viewWidth:viewWidth];
}

+ (NSMutableArray *)getCurrentPeakLevelQueue:(NSMutableArray *)displayPeakLevelQueue viewWidth:(CGFloat)viewWidth {
    int allCount = [self getAllCountWithViewWidth:viewWidth];
    NSMutableArray *currentPeakLevelArray = [NSMutableArray new];
    // 获取一屏幕的样本点
    for (int i=0; i<MIN(allCount, displayPeakLevelQueue.count); i++) {
        [currentPeakLevelArray addObject:displayPeakLevelQueue[i]];
    }
    return currentPeakLevelArray;
}

+ (NSMutableArray *)getAllPeakLevelQueueWithSampleZip:(NSString *)sampleZip {
    NSMutableArray *originalPeakLevelQueue = [NSMutableArray new];
    if (sampleZip.length) {
        NSData *zipData = [[NSData alloc] initWithBase64EncodedString:sampleZip options:0];
        NSData *outputData = [zipData gunzippedData];
        NSString *outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
        originalPeakLevelQueue = [[outputString componentsSeparatedByString:@","] mutableCopy];
        [originalPeakLevelQueue removeObject:@""];
    }
    return  originalPeakLevelQueue;
}

@end
