//
//  JARecommendNetRequest.h
//  Jasmine
//
//  Created by xujin on 2018/5/25.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JANetRequest.h"
#import "JAAlbumGroupModel.h"
#import "JANewVoiceGroupModel.h"
#import "JAVoiceFollowGroupModel.h"

@interface JARecommendNetRequest : JANetRequest

- (instancetype)initRequest_albumListWithParameter:(NSDictionary *)parameter;
- (instancetype)initRequest_storyListWithParameter:(NSDictionary *)parameter;
- (instancetype)initRequest_followListWithParameter:(NSDictionary *)parameter;
- (instancetype)initRequest_newStoryListWithParameter:(NSDictionary *)parameter;
- (instancetype)initRequest_peopleListWithParameter:(NSDictionary *)parameter;

@end
