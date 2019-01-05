//
//  JARichTextTableViewCell.h
//  Jasmine
//
//  Created by xujin on 2018/6/9.
//  Copyright © 2018 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JARichTextModel.h"

@interface JARichTextTableViewCell : UITableViewCell

@property (nonatomic, strong) JARichTextModel *data;
@property (nonatomic, copy) void(^topicDetailBlock)(NSString *topicName);  // 跳转话题详情
@property (nonatomic, copy) void(^atPersonBlock)(NSString *userName);

@end
