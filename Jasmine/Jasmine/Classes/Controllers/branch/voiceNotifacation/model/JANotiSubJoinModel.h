//
//  JANotiSubJoinModel.h
//  Jasmine
//
//  Created by moli-2017 on 2017/9/5.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JABaseModel.h"

@interface JANotiSubJoinModel : JABaseModel

@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *audioPlayImg;
@property (nonatomic, strong) NSString *audioUrl;
@property (nonatomic, strong) NSString *createTime;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *isAgree;
@property (nonatomic, strong) NSString *sort;
@property (nonatomic, strong) NSString *storyId;
@property (nonatomic, strong) NSString *categoryId;
@property (nonatomic, assign) BOOL storyIsAnonymous;
@property (nonatomic, strong) NSString *storyUserId; 
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *typeId;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, assign) BOOL isAnonymous;
@property (nonatomic, strong) JANotiSubJoinModel *subjoin;
@end
