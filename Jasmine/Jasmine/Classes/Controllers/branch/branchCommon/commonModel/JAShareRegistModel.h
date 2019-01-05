//
//  JAShareRegistModel.h
//  Jasmine
//
//  Created by moli-2017 on 2017/11/30.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JABaseModel.h"

@interface JAShareRegistModel : JABaseModel

@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *logo;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *uuid;

//2.5.2 小程序
@property (nonatomic, strong) NSString *miniProgramId;
@property (nonatomic, strong) NSString *miniProgramPath;
@end
