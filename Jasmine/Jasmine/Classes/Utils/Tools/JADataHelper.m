//
//  JADataHelper.m
//  Jasmine
//
//  Created by xujin on 29/03/2018.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JADataHelper.h"

@implementation JADataHelper

/*
 {
 "atList": [{
 "userId": 7096,
 "userName": "稀饭"
 }, {
 "userId": 7024,
 "userName": "稀饭1"
 }, {
 "userId": 7025,
 "userName": "稀饭2"
 }]
 }
 */

+ (JAConsumer *)getConsumer:(NSString *)userName atList:(NSArray *)atList {
    JAConsumer *model = nil;
    if (userName.length && atList.count) {
        for (NSDictionary *dic in atList) {
            if ([userName isEqualToString:[NSString stringWithFormat:@"@%@\b",dic[@"userName"]]]) {
                model = [[JAConsumer alloc] init];
                model.userId = [NSString stringWithFormat:@"%@",dic[@"userId"]];
                model.name = dic[@"userName"];
                break;
            }
        }
    }
    return model;
}

+ (NSArray *)getRangesWithRegular:(NSString *)regular text:(NSString *)text{
    regular = [regular stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (!regular.length || !text.length) {
        return nil;
    }
    static NSRegularExpression *regex = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error = nil;
        regex = [[NSRegularExpression alloc] initWithPattern:regular options:0 error:&error];
    });
    NSArray *matches = [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    return matches;
}

+ (NSArray *)getRangesForUserHandles:(NSString *)text
{
    if (!text.length) {
        return nil;
    }
    static NSRegularExpression *regex = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error = nil;
        regex = [[NSRegularExpression alloc] initWithPattern:@"@[^@]+\b" options:0 error:&error];
    });
    NSArray *matches = [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    return matches;
}

+ (NSArray *)getRangesForHashtags:(NSString *)text
{
    if (!text.length) {
        return nil;
    }
    static NSRegularExpression *regex = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error = nil;
        regex = [[NSRegularExpression alloc] initWithPattern:@"#[^#\b]*[0-9a-zA-Z\\u4e00-\\u9fa5]+[^#\b]*#" options:0 error:&error];
    });
    NSArray *matches = [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    return matches;
}

+ (NSMutableArray *)getAtListWithContent:(NSString *)content atPersonArray:(NSArray *)atPersonArray {
    NSMutableArray *atList = [NSMutableArray new];
    NSArray *userHandles = [self getRangesForUserHandles:content];
    for (NSTextCheckingResult *match in userHandles)
    {
        NSRange matchRange = [match range];
        NSString *string = [content substringWithRange:matchRange];
        for (JAConsumer *consumer in atPersonArray) {
            if ([string isEqualToString:[NSString stringWithFormat:@"@%@\b",consumer.name]]) {
                NSMutableDictionary *dic = [NSMutableDictionary new];
                dic[@"userId"] = [NSString stringWithFormat:@"%@",consumer.userId];
                dic[@"userName"] = consumer.name;
                if (dic) {
                    [atList addObject:dic];
                    break;
                }
            }
        }
    }
    return atList;
}

// ❀正则匹配
+ (NSArray *)getRangesForFlowers:(NSString *)text {
    if (!text.length) {
        return nil;
    }
    static NSRegularExpression *regex = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error = nil;
        regex = [[NSRegularExpression alloc] initWithPattern:@"❀[^❀]+❀" options:0 error:&error];
    });
    NSArray *matches = [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    return matches;
}

@end
