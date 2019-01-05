//
//  JARichImageTableViewCell.h
//  Jasmine
//
//  Created by xujin on 2018/6/9.
//  Copyright © 2018 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JARichImageModel.h"

@interface JARichImageTableViewCell : UITableViewCell

@property (nonatomic, strong) JARichImageModel *data;
@property (nonatomic, strong) void(^showBigPicture)(void);  // 查看大图退出键盘

@end
