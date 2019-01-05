//
//  JAVoiceAgreeCell.h
//  Jasmine
//
//  Created by moli-2017 on 2017/8/30.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JANotiModel.h"
@interface JAVoiceAgreeCell : UITableViewCell
@property (nonatomic, strong) JANotiModel *model;

@property (nonatomic, strong) void(^jumpPersonalCenterBlock)(JAVoiceAgreeCell *cell);

// v2.6.0
@property (nonatomic, copy) void(^topicDetailBlock)(NSString *topicName);
@property (nonatomic, copy) void(^atPersonBlock)(NSString *userName, NSArray *atList);

@end
