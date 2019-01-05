//
//  JALabelSelectNetRequest.h
//  Jasmine
//
//  Created by xujin on 2018/5/28.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JANetRequest.h"
#import "JALabelSelectGroupModel.h"

@interface JALabelSelectNetRequest : JANetRequest

- (instancetype)initRequest_labelsWithParameter:(NSDictionary *)parameter;
- (instancetype)initRequest_saveLabelsWithParameter:(NSDictionary *)parameter;
- (instancetype)initRequest_syncLabelsWithParameter:(NSDictionary *)parameter;

@end
