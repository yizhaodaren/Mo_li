//
//  JAContributeCell.h
//  Jasmine
//
//  Created by moli-2017 on 2018/4/10.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JANewVoiceModel.h"

@interface JAContributeCell : UITableViewCell
@property (nonatomic, strong) void(^playVoiceBlock)(JAContributeCell *cell);
@property (nonatomic, strong) JANewVoiceModel *storyModel;
@end
