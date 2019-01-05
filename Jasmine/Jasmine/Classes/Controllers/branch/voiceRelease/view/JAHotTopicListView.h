//
//  JAHotTopicListView.h
//  Jasmine
//
//  Created by xujin on 23/02/2018.
//  Copyright © 2018 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAVoiceTopicModel.h"

@interface JAHotTopicListView : UIView

@property (nonatomic, copy) void (^tapTopic)(JAVoiceTopicModel *topicModel);
@property (nonatomic, copy) void (^hideKeyboard)(void);

@end
