//
//  JANetRequest.m
//  Jasmine
//
//  Created by moli-2017 on 2018/5/23.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JANetRequest.h"
#import "NSDictionary+NTESJson.h"

@implementation JANetRequest

- (void)baseNetwork_startRequestWithcompletion:(JARequestCompletionBlock)completion failure:(JARequestCompletionBlock)failure
{
    [self requestWithcompletion:completion failure:failure];
}

- (void)requestWithcompletion:(JARequestCompletionBlock)completion failure:(JARequestCompletionBlock)failure
{
    
    [self startWithCompletionBlockWithSuccess:^(__kindof JANewBaseNetRequest * _Nonnull request) {
        NSLog(@"%@ \n %@",request,request.responseObject);
        Class modelClass = self.modelClass;
        
        // 获取数据类型
        id resBody = request.responseObject[@"resBody"];
        if (resBody) {
            if ([resBody isKindOfClass:[NSArray class]]) {   // 数组
                JANetBaseModel *model = [modelClass mj_objectWithKeyValues:request.responseObject];
                if (completion) {
                    completion(request,model);
                }
            }else if ([resBody isKindOfClass:[NSDictionary class]]){   // 字典
                JANetBaseModel *model = [modelClass mj_objectWithKeyValues:resBody];
                model.code = [request.responseObject[@"code"] integerValue];
                model.message = request.responseObject[@"message"];
                model.total = [request.responseObject jsonInteger:@"total"];
                if (completion) {
                    completion(request,model);
                }
            }else{
                if (completion) {
                    completion(request,nil);
                }
            }
        }else{  // 没有 resBody
            JANetBaseModel *model = [modelClass mj_objectWithKeyValues:request.responseObject];
            if (completion) {
                completion(request,model);
            }
        }
        
    } failure:^(__kindof JANewBaseNetRequest * _Nonnull request) {
        NSLog(@"%@ \n %@",request, request.error.localizedDescription);
        if (failure) {
            failure(request,nil);
        }
        
        if (self.isToast) {
            [[UIApplication sharedApplication].delegate.window ja_makeToast:request.error.localizedDescription];
        }
    }];
}
@end
