//
//  JACommonTopicCell.h
//  Jasmine
//
//  Created by moli-2017 on 2018/2/23.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAVoiceTopicModel.h"

@interface JACommonTopicCell : UITableViewCell

@property (nonatomic, strong) JAVoiceTopicModel *model;
@property (nonatomic, strong) NSArray *keyWordArr;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier type:(NSInteger)type;

@end
