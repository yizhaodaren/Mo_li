//
//  JADBTaskModel.h
//  Jasmine
//
//  Created by moli-2017 on 2017/9/11.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JABaseModel.h"

@interface JADBTaskModel : JABaseModel
@property (nonatomic, strong) NSString *taskId;
@property (nonatomic, strong) NSString *taskDescription;
@property (nonatomic, strong) NSString *taskFinishCount;
@property (nonatomic, strong) NSString *taskFlower;
@property (nonatomic, strong) NSString *taskMoney;
@property (nonatomic, strong) NSString *taskName;
@property (nonatomic, strong) NSString *taskRedpackage;
@property (nonatomic, strong) NSString *taskTitle;
@property (nonatomic, strong) NSString *taskType;
@property (nonatomic, strong) NSString *userFinishCount;
@property (nonatomic, strong) NSString *taskOpenType;
@property (nonatomic, strong) NSString *openTitle;
@end
