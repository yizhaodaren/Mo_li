//
//  JANotiModel.h
//  Jasmine
//
//  Created by moli-2017 on 2017/9/5.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JABaseModel.h"
#import "JANotiContentModel.h"
#import "JANotiPersonModel.h"
@interface JANotiModel : JABaseModel

@property (nonatomic, strong) JANotiContentModel *content;
@property (nonatomic, strong) NSString *operation;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *msgContent;
@property (nonatomic, strong) JANotiPersonModel *user;
@property (nonatomic, strong) NSString *nick;
@property (nonatomic, strong) NSString *img;
@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, assign) BOOL readState;        // 已读状态

@property (nonatomic, assign) NSInteger playState;// 0未播放1播放2暂停3缓冲中
@property (nonatomic, assign) NSInteger playCommentState;// 0未播放1播放2暂停
@property (nonatomic, assign) NSInteger playReplyState;// 0未播放1播放2暂停
// 波形图数据
@property (nonatomic, strong) NSMutableArray *displayPeakLevelQueue;
@property (nonatomic, strong) NSMutableArray *currentPeakLevelQueue;

// 需要刷新的cell的高度（库里存的值和该值不一样就刷新）
@property (nonatomic, assign) NSInteger cellHeightVersion;
@end
