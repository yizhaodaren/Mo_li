//
//  JARichContentTableView.h
//  Jasmine
//
//  Created by xujin on 2018/6/9.
//  Copyright © 2018 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JANewVoiceModel.h"

@interface JARichContentTableView : UITableView

@property (nonatomic, strong) void(^showBigPicture)(void);  // 查看大图退出键盘
@property (nonatomic, copy) void(^headActionBlock)(void);
@property (nonatomic, copy) void(^followBlock)(UIButton *sener);
@property (nonatomic, copy) void(^topicDetailBlock)(NSString *topicName);
@property (nonatomic, copy) void(^atPersonBlock)(NSString *userName);

- (void)setupData:(JANewVoiceModel *)model;

@property (nonatomic, strong) JANewVoiceModel *refreshModel;  // 用来做刷新的model
@end
