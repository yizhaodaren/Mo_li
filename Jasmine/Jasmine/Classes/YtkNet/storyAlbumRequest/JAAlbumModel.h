//
//  JAAlbumModel.h
//  Jasmine
//
//  Created by moli-2017 on 2018/5/23.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JANetBaseModel.h"
#import "JALightShareModel.h"

@interface JAAlbumModel : JANetBaseModel

@property (nonatomic, strong) NSString *createTime;
@property (nonatomic, strong) NSString *playCount;
@property (nonatomic, strong) NSString *subjectDesc;
@property (nonatomic, strong) NSString *storyCount;
@property (nonatomic, strong) NSString *subjectId;
@property (nonatomic, strong) NSString *subjectName;
@property (nonatomic, strong) NSString *subjectThumb;
@property (nonatomic, assign) BOOL isCollect;
@property (nonatomic, strong) JALightShareModel *shareMsg;

@property (nonatomic, assign) NSInteger storyNewCount;

@end
