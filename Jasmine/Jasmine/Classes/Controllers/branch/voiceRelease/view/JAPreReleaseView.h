//
//  JAPreReleaseView.h
//  Jasmine
//
//  Created by xujin on 2018/5/28.
//  Copyright © 2018 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JACircleModel.h"
#import "JAVoiceTopicModel.h"

@interface JAPreReleaseView : UIView

@property (nonatomic, strong) JACircleModel *circleModel;
@property (nonatomic, strong) JAVoiceTopicModel *topicModel;

+ (void)showPreReleaseView;
+ (void)showPreReleaseViewWithTopic:(JAVoiceTopicModel *)topicModel;
+ (void)showPreReleaseViewWithCircle:(JACircleModel *)circleModel;

@end
