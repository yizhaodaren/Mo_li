//
//  JARelationshipTableViewCell.h
//  Jasmine
//
//  Created by xujin on 08/07/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAConsumer.h"

@interface JARelationshipTableViewCell : UITableViewCell

@property (nonatomic, strong) UIButton *focusButton;
@property (nonatomic, strong) JAConsumer *data;
@property (nonatomic, copy) void(^focusActionBlock)(JARelationshipTableViewCell * cell);

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier isFriend:(BOOL)isFriend;
@end
