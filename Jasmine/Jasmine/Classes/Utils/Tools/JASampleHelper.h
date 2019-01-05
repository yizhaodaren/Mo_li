//
//  JASampleHelper.h
//  Jasmine
//
//  Created by xujin on 13/12/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, JADisplayType) {
    JADisplayTypeStory,
    JADisplayTypeComment,
    JADisplayTypeNotification,
    JADisplayTypeCheckVoice,
    JADisplayTypeCheckComment,
    JADisplayTypeAll
};

@interface JASampleHelper : NSObject

+ (NSString *)getSampleStringWithAllPeakLevelQueue:(NSMutableArray *)allPeakLevelQueue;
+ (NSString *)getSampleZipStringWithAllPeakLevelQueue:(NSMutableArray *)allPeakLevelQueue;

+ (CGFloat)getViewWidthWithType:(JADisplayType)type;

+ (int)getAllCountWithViewWidth:(CGFloat)viewWidth;
+ (NSMutableArray *)getDisplayPeakLevelQueue:(NSString *)sampleZip sample:(NSString *)sample type:(JADisplayType)type;
+ (NSMutableArray *)getDisplayPeakLevelQueue:(NSString *)sampleZip sample:(NSString *)sample viewWidth:(CGFloat)viewWidth;

+ (NSMutableArray *)getCurrentPeakLevelQueue:(NSMutableArray *)displayPeakLevelQueue type:(JADisplayType)type;
+ (NSMutableArray *)getCurrentPeakLevelQueue:(NSMutableArray *)displayPeakLevelQueue viewWidth:(CGFloat)viewWidth;

+ (NSMutableArray *)getAllPeakLevelQueueWithSampleZip:(NSString *)sampleZip;

@end
