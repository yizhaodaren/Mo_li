//
//  JAAlbumDetailViewController.h
//  Jasmine
//
//  Created by moli-2017 on 2018/5/23.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JABaseViewController.h"
@interface JAAlbumDetailViewController : JABaseViewController
@property (nonatomic, strong) NSString *subjectId;
@property (nonatomic, strong) void(^cancleCollectBlock)();

@property (nonatomic, strong) NSDictionary *albumRequestDic;

@property (nonatomic, strong) NSString *albumName;
@end
