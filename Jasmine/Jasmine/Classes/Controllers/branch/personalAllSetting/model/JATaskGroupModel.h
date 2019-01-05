//
//  JATaskGroupModel.h
//  Jasmine
//
//  Created by moli-2017 on 2017/9/8.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JATaskRowModel.h"
@interface JATaskGroupModel : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray *taskList;


@end
