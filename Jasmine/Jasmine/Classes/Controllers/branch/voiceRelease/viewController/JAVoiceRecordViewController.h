//
//  JAVoiceReocrdViewController.h
//  Jasmine
//
//  Created by xujin on 30/08/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JABaseViewController.h"
#import "JACircleModel.h"
#import "JAVoiceTopicModel.h"

@interface JAVoiceRecordViewController : JABaseViewController

@property (nonatomic, assign) NSInteger storyType; // 0语音帖1图文帖
@property (nonatomic, assign) NSInteger fromType; // 0发帖1投稿
// v2.6.0
@property (nonatomic, copy) NSString *noticeString; // 投稿提示文案
@property (nonatomic, strong) JACircleModel *circleModel; // 圈子信息
@property (nonatomic, strong) JAVoiceTopicModel *topicModel; // 话题信息

@end
