//
//  JAVoiceFocusCell.h
//  Jasmine
//
//  Created by moli-2017 on 2017/8/30.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JANotiModel.h"
@interface JAVoiceFocusCell : UITableViewCell
@property (nonatomic, strong) JANotiModel *model;
@property (nonatomic, strong) void(^jumpPersonalCenterBlock)(JAVoiceFocusCell *cell);
@end
