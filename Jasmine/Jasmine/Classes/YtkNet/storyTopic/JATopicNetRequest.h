//
//  JATopicNetRequest.h
//  Jasmine
//
//  Created by moli-2017 on 2018/6/5.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JANetRequest.h"
#import "JANewVoiceGroupModel.h"

@interface JATopicNetRequest : JANetRequest

/// 话题帖子列表
- (instancetype)initRequest_topicListWithParameter:(NSDictionary *)parameter;
@end
