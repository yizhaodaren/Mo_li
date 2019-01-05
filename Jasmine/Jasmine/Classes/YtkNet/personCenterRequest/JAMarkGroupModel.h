//
//  JAMarkGroupModel.h
//  Jasmine
//
//  Created by moli-2017 on 2018/7/17.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JANetBaseModel.h"
#import "JAMarkModel.h"

@interface JAMarkGroupModel : JANetBaseModel
@property (nonatomic, strong) NSArray *crownList;
@property (nonatomic, strong) JAMarkModel *userCrown;
@property (nonatomic, strong) NSString *rule;
@end
