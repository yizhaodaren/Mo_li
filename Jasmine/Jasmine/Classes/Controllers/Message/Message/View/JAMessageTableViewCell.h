//
//  JAMessageTableViewCell.h
//  Jasmine
//
//  Created by xujin on 20/05/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAMessageData.h"

@class EMConversation;

@protocol JAMessageTableViewCellDelegate <NSObject>

@optional
- (void)message_jumpPersonalCenterWithUserId:(NSString *)uid;

@end
@interface JAMessageTableViewCell : UITableViewCell

@property (nonatomic, strong) JAMessageData *data;

// 环信会话model
@property (nonatomic, strong) NIMRecentSession *conversation;
@property (nonatomic, weak) id <JAMessageTableViewCellDelegate> delegate;

@property (nonatomic, strong) NSString *chatName;
@property (nonatomic, strong) NSString *chatUid;
@end
