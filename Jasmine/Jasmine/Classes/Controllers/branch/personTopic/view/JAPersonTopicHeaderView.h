//
//  JAPersonTopicHeaderView.h
//  Jasmine
//
//  Created by moli-2017 on 2018/2/23.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAVoiceTopicModel.h"

@interface JAPersonTopicHeaderView : UIView
@property (nonatomic, assign) CGFloat topOffY;  // 顶部偏移

@property (nonatomic, strong) JAVoiceTopicModel *topicM;

@end
