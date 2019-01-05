//
//  JAVoiceTopicModel.h
//  Jasmine
//
//  Created by moli-2017 on 2018/2/23.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JABaseModel.h"

@interface JAVoiceTopicModel : JABaseModel
@property (nonatomic, strong) NSString *discussCount;
@property (nonatomic, strong) NSString *topicId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *imgurl;
@property (nonatomic, strong) NSString *sort;
@property (nonatomic, strong) NSString *content;   // 子描述
@property (nonatomic, strong) NSString *headline;   // 短标题
@property (nonatomic, strong) NSString *userId;

@property (nonatomic, strong) NSString *shareCount;
@property (nonatomic, strong) NSString *shareImg;
@property (nonatomic, strong) NSString *shareTitle;
@property (nonatomic, strong) NSString *shareUrl;
@property (nonatomic, strong) NSString *shareWBContent;
@property (nonatomic, strong) NSString *shareWxContent;

@property (nonatomic, strong) NSString *localImgName;
@property (nonatomic, strong) NSString *localTitle;

@end
