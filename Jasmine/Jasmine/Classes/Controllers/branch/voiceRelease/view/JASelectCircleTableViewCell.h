//
//  JASelectCircleTableViewCell.h
//  Jasmine
//
//  Created by xujin on 2018/5/29.
//  Copyright © 2018 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JACircleModel.h"

@interface JASelectCircleTableViewCell : UITableViewCell

@property (nonatomic, strong) JACircleModel *data;
@property (nonatomic,strong) UIButton *selectBtn;//选与否按钮
- (void)hiddenLineView:(BOOL)hidden;

@end
