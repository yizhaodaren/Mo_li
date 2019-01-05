//
//  JARuleModel.m
//  Jasmine
//
//  Created by moli-2017 on 2017/10/13.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JARuleModel.h"

@implementation JARuleModel

- (CGFloat)cellHeight
{
    if (_cellHeight == 0) {
        
        if (self.type.integerValue == 3) {
            
            // 计算高度
            CGSize maxS = CGSizeMake(JA_SCREEN_WIDTH - 30 - 104 - 40, MAXFLOAT);
            CGFloat height = [self.conditionBasic boundingRectWithSize:maxS options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : JA_REGULAR_FONT(14)} context:nil].size.height;
            
            _cellHeight = height + 20;
        }else{
            // 计算高度
            CGSize maxS = CGSizeMake(JA_SCREEN_WIDTH - 30 - 104 - 40, MAXFLOAT);
            CGFloat height = [self.actionType boundingRectWithSize:maxS options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : JA_REGULAR_FONT(14)} context:nil].size.height;
            
            _cellHeight = height + 20;
            
        }
    }
    
    return _cellHeight;
}

@end
