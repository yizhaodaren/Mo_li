//
//  JAMedalNetRequest.h
//  Jasmine
//
//  Created by 王树超 on 2018/7/14.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JANetRequest.h"

@interface JAMedalNetRequest : JANetRequest

//获取勋章列表
- (instancetype)initRequest_getMedalListWithParameter:(NSDictionary *)parameter userID:(NSString *)userID;
//勋章详情
- (instancetype)initRequest_MedalInfoWithParameter:(NSDictionary *)parameter MedalID:(NSString *)medalId WithUserID:(NSString *)userId;

//佩戴勋章
- (instancetype)initRequest_adornMedalWithParameter:(NSDictionary *)parameter MedalID:(NSString *)medalId WithUse:(NSString *)use;
@end
