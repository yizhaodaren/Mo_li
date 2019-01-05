//
//  JATaskRowModel.h
//  Jasmine
//
//  Created by moli-2017 on 2017/9/8.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JATaskRowModel : NSObject
@property (nonatomic, strong) NSString *taskId;
@property (nonatomic, strong) NSString *taskDescription;
@property (nonatomic, strong) NSString *taskFinishCount;
@property (nonatomic, strong) NSString *taskFlower;
@property (nonatomic, strong) NSString *taskMoney;
@property (nonatomic, strong) NSString *taskName;
@property (nonatomic, strong) NSString *taskRedpackage;
@property (nonatomic, strong) NSString *taskTitle;
@property (nonatomic, strong) NSString *taskType;
@property (nonatomic, strong) NSString *taskSort;
@property (nonatomic, strong) NSString *userFinishCount;
@property (nonatomic, strong) NSString *userFinishTime;
@property (nonatomic, strong) NSString *taskOpenType;
@property (nonatomic, strong) NSString *taskOpenUrl;
@property (nonatomic, strong) NSString *taskOpenTitle;
@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, assign) BOOL unfold;

//2.5.0 任务
@property (nonatomic, strong) NSString *taskContentType;
@property (nonatomic, strong) NSString *taskContent;
@end
