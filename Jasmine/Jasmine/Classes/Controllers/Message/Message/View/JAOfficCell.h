//
//  JAOfficCell.h
//  Jasmine
//
//  Created by moli-2017 on 2017/7/9.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JAOfficModel;
@interface JAOfficCell : UITableViewCell
@property (nonatomic, strong) JAOfficModel *model;
@property (nonatomic, strong) void(^clickDetailBlock)(JAOfficCell *cell);
@property (nonatomic, strong) void(^clickmoliJunBlock)(JAOfficCell *cell);
@end
