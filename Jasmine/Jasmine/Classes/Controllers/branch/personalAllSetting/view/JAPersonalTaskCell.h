//
//  JAPersonalTaskCell.h
//  Jasmine
//
//  Created by moli-2017 on 2017/9/8.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JATaskRowModel.h"
@interface JAPersonalTaskCell : UITableViewCell
@property (nonatomic, strong) JATaskRowModel *model;

@property (nonatomic, strong) void(^showAllBlock)(JAPersonalTaskCell *cell);
@property (nonatomic, strong) void(^jumpvc)(JAPersonalTaskCell *cell);
@end
