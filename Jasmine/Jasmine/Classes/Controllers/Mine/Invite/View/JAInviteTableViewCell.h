//
//  JAInviteTableViewCell.h
//  Jasmine
//
//  Created by xujin on 20/05/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JAInviteData.h"
#define HEIGHT_INVITE_CELL 70

@interface JAInviteTableViewCell : UITableViewCell

// 控制block
/*
 * value
 * 0:邀请
 * 1:已邀请
 */
@property (nonatomic, copy) void(^controlBlock)(JAInviteTableViewCell *cell);

@property (nonatomic, strong) JAConsumer *data;

@end
