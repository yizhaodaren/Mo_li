//
//  JARuleViewCell.h
//  Jasmine
//
//  Created by moli-2017 on 2017/10/13.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JARuleModel.h"

typedef NS_ENUM(NSUInteger, JARuleViewCellType) {
    JARuleViewCellTypeLeft,
    JARuleViewCellTypeRight
};

@interface JARuleViewCell : UITableViewCell

- (instancetype)ruleViewCellWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier type:(JARuleViewCellType)type;

@property (nonatomic, strong) JARuleModel *model;
@end
