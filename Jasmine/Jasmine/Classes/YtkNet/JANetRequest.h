//
//  JANetRequest.h
//  Jasmine
//
//  Created by moli-2017 on 2018/5/23.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JANewBaseNetRequest.h"
#import "JANewBaseNetRequest.h"

typedef void(^JARequestCompletionBlock)(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel);

@interface JANetRequest : JANewBaseNetRequest

- (void)baseNetwork_startRequestWithcompletion:(JARequestCompletionBlock)completion failure:(JARequestCompletionBlock)failure;

@end
