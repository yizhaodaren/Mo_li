//
//  JAPasteboardHelper.m
//  Jasmine
//
//  Created by xujin on 2018/4/8.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JAPasteboardHelper.h"
#import "JADataHelper.h"
#import "JAUserApiRequest.h"
#import "JALaunchADManager.h"
#import "JAActivityRedPacketView.h"
#import "JACommandModel.h"

@implementation JAPasteboardHelper

+ (void)handleActiviey {
    // 广告页已展示完毕
    if ([JALaunchADManager shareInstance].adState == 1) {
        NSString *pasteboardStr = [UIPasteboard generalPasteboard].string;
        NSArray *array = [JADataHelper getRangesForFlowers:pasteboardStr];
        if (array.count) {
            [UIPasteboard generalPasteboard].string = @"";
            NSTextCheckingResult *match = array.firstObject;
            NSRange matchRange = [match range];
            NSString *secretStr = [pasteboardStr substringWithRange:matchRange];
            secretStr = [secretStr stringByReplacingOccurrencesOfString:@"❀" withString:@""];

            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"userId"] = @"0";
            dic[@"command"] = secretStr;
            [[JAUserApiRequest shareInstance] userSelectCommand:dic success:^(NSDictionary *result) {
                JACommandModel *model = [JACommandModel mj_objectWithKeyValues:result[@"commend"]];
                if (model) {
                    [JAActivityRedPacketView showActivity:model];
                }
            } failure:^(NSError *error) {
                
            }];
        }
    }
}

@end
