//
//  JAVoiceReplyCell.h
//  Jasmine
//
//  Created by moli-2017 on 2017/8/30.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JANotiModel.h"
@interface JAVoiceReplyCell : UITableViewCell

@property (nonatomic, strong) JANotiModel *model;

@property (nonatomic, strong) void(^jumpPersonalCenterBlock)(JAVoiceReplyCell *cell);
@property (nonatomic, strong) void(^jumpRecordBlock)(JAVoiceReplyCell *cell);
@property (nonatomic, strong) void(^playCommentOrReplyBlock)(JAVoiceReplyCell *cell);

// v2.6.0
@property (nonatomic, copy) void(^atPersonBlock)(NSString *userName, NSArray *atList);

@end
