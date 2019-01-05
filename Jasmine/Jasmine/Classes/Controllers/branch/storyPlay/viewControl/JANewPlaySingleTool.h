//
//  JANewPlaySingleTool.h
//  Jasmine
//
//  Created by 刘宏亮 on 2018/6/1.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JANotiModel.h"

typedef NS_ENUM(NSUInteger, JANewPlaySingleToolType) {
    JANewPlaySingleToolType_comment, // 单条评论 
    JANewPlaySingleToolType_reply,   // 单条回复
    JANewPlaySingleToolType_noti,    // 通知界面           3.0版本能用之前的逻辑，临时不改
    JANewPlaySingleToolType_local,  // 本地file(eg:试听)   3.0版本能用之前的逻辑，临时不改
};

@interface JANewPlaySingleTool : NSObject

+ (instancetype)shareNewPlaySingleTool;


/// 播放器的状态
@property (nonatomic, assign, readonly) NSInteger playType;   // 0未播放 1 播放 2暂停 3 缓冲中...

/// 播放器的播放类型
@property (nonatomic, assign, readonly) JANewPlaySingleToolType musicType;  // 音乐类型

/// 当前播放曲目 (根据类型获取当前播放的music)
@property (nonatomic, strong, readonly) JANewCommentModel *currentMusic_comment;
@property (nonatomic, strong, readonly) JANewReplyModel *currentMusic_reply;
@property (nonatomic, strong, readonly) JANotiModel *currentMusic_noti;
@property (nonatomic, strong, readonly) NSString *currentMusic_local;

@property (nonatomic, assign) NSTimeInterval currentDuration;
@property (nonatomic, assign) NSTimeInterval totalDuration;

/// 播放
- (void)playSingleTool_playSingleMusicWithFileUrlString:(NSString *)file model:(id)model playType:(JANewPlaySingleToolType)type;
/// 暂停
- (void)playSingleTool_pause;

@end
