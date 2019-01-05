//
//  JAMyInviteCell.h
//  Jasmine
//
//  Created by moli-2017 on 2017/8/20.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAMyInviteModel.h"
#import "JACallInviteFriendModel.h"
@interface JAMyInviteCell : UITableViewCell
@property (nonatomic, assign) NSInteger cellType;   // 0 : 排行榜  1： 唤醒好友榜
@property (nonatomic, strong) JAMyInviteModel *model;
@property (nonatomic, strong) JACallInviteFriendModel *callFriendModel;
@property (nonatomic, strong) void(^jumpPersonBlock)(JAMyInviteCell *cell);
@property (nonatomic, strong) void(^callPersonBlock)(JAMyInviteCell *cell);
@end
