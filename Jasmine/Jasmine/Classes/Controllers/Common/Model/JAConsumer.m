//
//  JAConsumer.m
//  Jasmine
//
//  Created by moli-2017 on 2017/6/9.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAConsumer.h"

@implementation JAConsumer

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
             @"consumerId":@"id",
             };
}

+ (NSDictionary *)mj_objectClassInArray
{
    return @{
             @"medalList":[JAMedalModel class]
             };
}

- (CGFloat)cellHeight
{
    if (_cellHeight == 0) {
       
        if (self.introduce.length) {
            
            // 计算高度
            CGSize maxS = CGSizeMake(JA_SCREEN_WIDTH - 40, MAXFLOAT);
            CGFloat height = [self.introduce boundingRectWithSize:maxS options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : JA_LIGHT_FONT(13)} context:nil].size.height;
            
//            _cellHeight = 105 + height + 148;
            _cellHeight = 105 + height;
        }else{
//            _cellHeight = 105 + 18 + 148;
            _cellHeight = 105 + 18;
        }
    }
    
    return _cellHeight;
}
@end
