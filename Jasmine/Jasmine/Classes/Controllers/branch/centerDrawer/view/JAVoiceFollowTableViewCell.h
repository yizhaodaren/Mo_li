//
//  JAVoiceFollowTableViewCell.h
//  Jasmine
//
//  Created by xujin on 15/09/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAVoiceFollowModel.h"

@interface JAVoiceFollowTableViewCell : UITableViewCell

@property (nonatomic, strong) UIButton *focusButton;
@property (nonatomic, strong) JAVoiceFollowModel *data;

@property (nonatomic, copy) void(^headActionBlock)(JAVoiceFollowTableViewCell * cell);
@property (nonatomic, copy) void(^followBlock)(JAVoiceFollowTableViewCell *cell);
@property (nonatomic, copy) void(^followCountBlock)(void);

@end
