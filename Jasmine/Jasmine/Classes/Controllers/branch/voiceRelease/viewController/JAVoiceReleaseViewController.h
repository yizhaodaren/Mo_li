//
//  JAVocieReleaseViewController.h
//  Jasmine
//
//  Created by xujin on 31/08/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JABaseViewController.h"
#import "JACircleModel.h"
#import "JARichTitleModel.h"
#import "JAPostDraftModel.h"
#import "JAVoiceTopicModel.h"

@interface JAVoiceReleaseViewController : JABaseViewController

@property (nonatomic, assign) NSInteger storyType; // 0语音帖1图文帖
@property (nonatomic, assign) NSInteger fromType; // 0发帖7草稿箱进入

@property (nonatomic, assign) BOOL isAnonymous;

@property (nonatomic, assign) CGFloat time; // 音频时长
@property (nonatomic, copy) NSString *content; // 描述
@property (nonatomic, strong) NSMutableArray *allPeakLevelQueue; // 采样集合
// v2.5.5
@property (nonatomic, copy) NSString *city; // 城市名
@property (nonatomic, copy) NSString *localAudioUrl; // 音频地址
@property (nonatomic, strong) NSMutableArray *imageInfoArray; // 草稿箱存的图片信息

// v2.5.4
@property (nonatomic, assign) NSRange lastRange; // 改变颜色后，光标会跳转到尾部
// v2.6.0
@property (nonatomic, assign) BOOL dontChangeRange; // 插入话题或者at后，不修改上次的range
@property (nonatomic, assign) NSRange frontSelectRange;
@property (nonatomic, assign) NSInteger maxContentLength;

// v3.0.0
@property (nonatomic, strong) JARichTitleModel *titleModel;
@property (nonatomic, strong) NSMutableArray *richContentModels; // 图文贴数据源
@property (nonatomic, strong) JAPostDraftModel *postDraftModel;
@property (nonatomic, strong) JACircleModel *circleModel; // 圈子信息
@property (nonatomic, strong) JAVoiceTopicModel *topicModel; // 话题信息

- (void)pushSearchTopicVC:(BOOL)isAuto;
- (void)pushAtPersonVC:(BOOL)isAuto;
- (void)setRightButtonEnable:(BOOL)enable;

- (void)saveDraft:(BOOL)isSend;
@end
