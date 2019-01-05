//
//  JACheckNetRequest.h
//  Jasmine
//
//  Created by moli-2017 on 2018/6/6.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JANetRequest.h"

@interface JACheckNetRequest : JANetRequest

// 置顶
- (instancetype)initRequest_circleTopWithParameter:(NSDictionary *)parameter storyId:(NSString *)storyId;

// 加精华
- (instancetype)initRequest_essenceStoryWithParameter:(NSDictionary *)parameter storyId:(NSString *)storyId;

// 加神回复

// 隐藏

@end
