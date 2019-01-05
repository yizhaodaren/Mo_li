//
//  JAFunctionToolV.h
//  Jasmine
//
//  Created by moli-2017 on 2017/5/12.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, JAParticularsReportType) {
    JAParticularsReportCollect,     // 收藏 举报
    JAParticularsCollectDelete,     // 收藏 删除
}; 

@interface JAFunctionToolV : UIView

@property(nonatomic, copy) void (^shareWitnIndex)(NSInteger index);
@property(nonatomic, copy) void (^funcWitnIndex)(NSInteger index,BOOL selected);

@property (nonatomic, weak) UIButton *collectButton;

- (instancetype)functionToolV:(JAParticularsReportType)type;
+ (instancetype)shareToolV;
+ (instancetype)webshareToolV;
- (void)show;
- (void)close;

@end
