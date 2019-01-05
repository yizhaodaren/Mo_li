//
//  JACheckCommentModel.m
//  Jasmine
//
//  Created by xujin on 06/11/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JACheckCommentModel.h"

@implementation JACheckCommentModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
             @"minText":@"title",
             @"recognitionTime":@"content"
             };
}

@end
