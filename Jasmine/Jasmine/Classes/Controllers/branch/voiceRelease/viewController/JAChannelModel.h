//
//  JAChannelModel.h
//  Jasmine
//
//  Created by xujin on 31/08/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JABaseModel.h"

@interface JAChannelModel : JABaseModel

@property (nonatomic, copy) NSString *channelId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *image;
@property (nonatomic, assign) NSInteger type;// 1只有在选择频道用，0、1在首页用
@property (nonatomic, assign) NSInteger sort;

@end
