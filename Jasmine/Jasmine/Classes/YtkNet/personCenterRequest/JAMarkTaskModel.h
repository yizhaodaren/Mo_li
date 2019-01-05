//
//  JAMarkTaskModel.h
//  Jasmine
//
//  Created by moli-2017 on 2018/7/17.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JANetBaseModel.h"

@interface JAMarkTaskModel : JANetBaseModel
@property (nonatomic, strong) NSString *taskName;
@property (nonatomic, strong) NSString *taskStatus;
@end
