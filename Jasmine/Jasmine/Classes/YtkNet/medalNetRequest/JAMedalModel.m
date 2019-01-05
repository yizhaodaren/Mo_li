//
//  JAMedalModel.m
//  Jasmine
//
//  Created by 王树超 on 2018/7/14.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAMedalModel.h"

@implementation JAMedalModel
MJCodingImplementation
// 自定义排序方法
- (NSComparisonResult)compareParkInfo:(JAMedalModel *)parkinfo{
    // 降序
    NSComparisonResult result =[[NSNumber numberWithInteger:[parkinfo.createTime integerValue]] compare:[NSNumber numberWithInteger:[self.createTime integerValue]]];
    if (result == NSOrderedSame) {
        // 可以按照其他属性进行排序
    }
    return result;
}
@end
