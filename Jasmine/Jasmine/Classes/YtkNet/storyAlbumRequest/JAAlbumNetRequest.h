//
//  JAAlbumNetRequest.h
//  Jasmine
//
//  Created by moli-2017 on 2018/5/23.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JANetRequest.h"
#import "JAAlbumGroupModel.h"
#import "JANewVoiceModel.h"
#import "JANewVoiceGroupModel.h"
@interface JAAlbumNetRequest : JANetRequest

- (instancetype)initRequest_albumListWithParameter:(NSDictionary *)parameter;

- (instancetype)initRequest_albumInfoWithParameter:(NSDictionary *)parameter subjectId:(NSString *)subjectId;

- (instancetype)initRequest_albumStoryListWithParameter:(NSDictionary *)parameter subjectId:(NSString *)subjectId;

- (instancetype)initRequest_collectAlbumListWithParameter:(NSDictionary *)parameter;

@end
