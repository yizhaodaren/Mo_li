//
//  JADetailClickManager.h
//  Jasmine
//
//  Created by 刘宏亮 on 2017/12/14.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JANewVoiceModel.h"
#import "JANewCommentModel.h"
#import "JANewReplyModel.h"

typedef NS_ENUM(NSUInteger, JADetailClickType) {
    JADetailClickTypeNormal,     // 普通 - 所有的弹窗都带回复
    JADetailClickTypeNoReport,   // 没有举报
    JADetailClickTypeNoRecord,   // 没有回复
};

@interface JADetailClickManager : NSObject

/// 帖子的选项操作 (standbyParameter 为备用参数 传nil即可)
/*
 actionType =  1置顶  2取消置顶  3加精华 4取消加精华  5收藏  6取消收藏  7不感兴趣  8举报  9删除
 */
+ (void)detail_modalChooseWindowWithStory:(JANewVoiceModel *)storyModel standbyParameter:(id)standbyParameter needBlock:(void(^)(NSInteger actionType))finishBlock;


/// 评论的选项操作 (standbyParameter 为备用参数 传nil即可)
/*
 actionType =  1神回复  2取消神回复  3隐藏  4举报  5删除
 */
+ (void)detail_modalChooseWindowWithComment:(JANewCommentModel *)commentModel standbyParameter:(id)standbyParameter needBlock:(void(^)(NSInteger actionType))finishBlock;

/// 回复的选项操作 (standbyParameter 为备用参数 传nil即可)
/*
 actionType =  1举报  2删除
 */
+ (void)detail_modalChooseWindowWithReply:(JANewReplyModel *)replyModel standbyParameter:(id)standbyParameter needBlock:(void(^)(NSInteger actionType))finishBlock;
@end
