//
//  JAVoiceReleaseTopicViewController.h
//  Jasmine
//
//  Created by xujin on 23/02/2018.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JABaseViewController.h"
#import "JAVoiceTopicModel.h"

@interface JAVoiceReleaseTopicViewController : JABaseViewController

@property (nonatomic, copy) void (^selectedTopic)(JAVoiceTopicModel *topicModel);

@end
